--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port (
        clk  : in std_logic;
        btnU : in std_logic;
        btnC : in std_logic;
        sw   : in std_logic_vector(7 downto 0);
        
        led  : out std_logic_vector(3 downto 0);
        seg  : out std_logic_vector(6 downto 0);
        an   : out std_logic_vector(3 downto 0)
        );
    
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
	
	--- TDM
	component TDM4 is
        generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk        : in  STD_LOGIC;
               i_reset      : in  STD_LOGIC; -- asynchronous
               i_D3         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D2         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D1         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D0         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_data       : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_sel        : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0)    -- selected data line (one-cold)
        );
    end component;
   
   --- TWOS COMP
    component twoscomp_decimal is
       port (
           i_binary: in std_logic_vector(7 downto 0);
           o_negative: out std_logic_vector(3 downto 0);
           o_hundreds: out std_logic_vector(3 downto 0);
           o_tens: out std_logic_vector(3 downto 0);
           o_ones: out std_logic_vector(3 downto 0)
       );
    end component;
    
    --- SEVEN SEG DECODER
    component sevenSegDecoder is
        Port ( i_D : in STD_LOGIC_VECTOR (3 downto 0);
               o_S : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
    
    --- CLOCK DIVIDER
    component clock_divider is
        generic ( constant k_DIV : natural := 2    ); -- How many clk cycles until slow clock toggles
                                                   -- Effectively, you divide the clk double this 
                                                   -- number (e.g., k_DIV := 2 --> clock divider of 4)
        port (  i_clk    : in std_logic;
                i_reset  : in std_logic;           -- asynchronous
                o_clk    : out std_logic           -- divided (slow) clock
        );
    end component;
    
    ---ALU
    component ALU is
        port(
            i_A  : in STD_LOGIC_VECTOR(7 downto 0);
            i_B  : in STD_LOGIC_VECTOR(7 downto 0);
            i_op : in STD_LOGIC_VECTOR(2 downto 0);
            
            o_result : out STD_LOGIC_VECTOR(7 downto 0);
            o_flag   : out STD_LOGIC_VECTOR(2 downto 0) := "000"
            
        );
        
    end component;
    
    --- CONTROLLER
    component Controller_fsm is 
        port(
      
              i_clk, i_reset, i_adv   : in    std_logic;
              o_cycle                 : out   std_logic_vector(3 downto 0)
        
        );
    end component;
    
    
    --- SIGNALS:
    
    
    signal w_clk       : std_logic := '0';
    
    signal w_cycle     : STD_LOGIC_VECTOR (3 downto 0);
    signal w_reset     : std_logic := '0';
    
    signal w_A         : STD_LOGIC_VECTOR (7 downto 0);
    signal w_op        : STD_LOGIC_VECTOR (2 downto 0);
    signal w_B         : STD_LOGIC_VECTOR (7 downto 0);
    signal w_result    : STD_LOGIC_VECTOR (7 downto 0);
    signal w_flag      : STD_LOGIC_VECTOR (2 downto 0);
    
    signal w_tdm_clk, w_cont_clk   : std_logic := '0';
    signal w_bin                   : STD_LOGIC_VECTOR (7 downto 0);
    signal w_sign                  : STD_LOGIC_VECTOR (3 downto 0);
    signal w_hund      : STD_LOGIC_VECTOR (3 downto 0);
    signal w_tens      : STD_LOGIC_VECTOR (3 downto 0);
    signal w_ones      : STD_LOGIC_VECTOR (3 downto 0);
    signal w_sel       : STD_LOGIC_VECTOR (3 downto 0);
    
    signal w_TDM_7SD   : STD_LOGIC_VECTOR (3 downto 0);
    
    
    
  
begin
	-- PORT MAPS ----------------------------------------
    
    
	time_div_mux: TDM4
	   port map(
	       
	       i_reset => btnU, --- change to a signal
	       i_clk   => w_tdm_clk,
	       i_D3    => w_sign,
	       i_D2    => w_hund,
	       i_D1    => w_tens,
	       i_D0    => w_ones,
	       o_data  => w_TDM_7SD,
	       o_sel   => w_sel
	 );
	 
	 TCD: twoscomp_decimal
            port map(
                i_binary   => w_bin,
                o_negative => w_sign,
                o_hundreds => w_hund,
                o_tens     => w_tens,
                o_ones     => w_ones
            );
            
     SSD: sevenSegDecoder
            port map( 
                i_D => w_TDM_7SD,
                o_S => seg
            );
            
      
     clock_div_tdm: clock_divider 
        generic map ( k_DIV => 100000 ) 
            port map(
               i_clk   => w_clk,
               i_reset => btnU, --- change to w_reset 
               o_clk   => w_tdm_clk
            );
     
     clock_div_controller: clock_divider
        generic map( k_DIV => 25000000) 
            port map(
               i_clk   => w_clk,
               i_reset => '0',
               o_clk   => w_cont_clk
            );
            
      ALU_inst: ALU
        port map (
            i_A  => w_A,
            i_B  => w_B,
            i_op => w_op,
            
            o_result => w_result,
            o_flag   => w_flag
                    
         );
         
    Controller: Controller_fsm 
        port map (
           
            i_clk   => w_cont_clk, 
            i_reset => btnU, -- change to w_reset
            i_adv  => btnC,
            o_cycle => w_cycle
             
            );
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	w_A <= sw(7 downto 0) when w_cycle = "0001"
	   else w_A;
	w_B <= sw(7 downto 0) when w_cycle = "0010"
        else w_A;
	
	w_bin <=   w_A(7 downto 0) when (w_cycle = "0001") else
               w_B(7 downto 0) when (w_cycle = "0010") else
               w_result        when (w_cycle = "0100") else
               "00000000" when (w_cycle = "1000") else
               "00000000";
	
--	anodes: process(w_tdm_clk, w_cycle)
--	begin
--	   if w_cycle = "1000" then
--	       an <= "1111";
--	   else
--	       an <= w_sel;
--	   end if;
--	end process;
	
	an <= "1111" when w_cycle = "1000" else
	        w_sel;
    led(3 downto 0) <= w_cycle;
	
end top_basys3_arch;
