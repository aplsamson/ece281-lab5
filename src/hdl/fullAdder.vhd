--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2018 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : fullAdder.vhd
--| AUTHOR(S)     : Andres Samson
--| CREATED       : 01/30/2019 Last Modified 06/24/2020
--| DESCRIPTION   : 
--|
--| DOCUMENTATION : None
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : sevenSegDecoder.vhd
--|
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


entity fullAdder is
	port(
		
		i_A1    : in std_logic;
		i_B1    : in std_logic;
		i_Cin   : in std_logic;
		
		o_S1    : out std_logic;
		o_Cout1 : out std_logic
		
	);
end fullAdder;

architecture fullAdder_arch of fullAdder is 
	
  -- declare the component of your top-level design
  
    component halfAdder is
     port(
        i_A     : in  std_logic; -- 1-bit input port
        i_B     : in  std_logic; 
        o_S     : out std_logic;  -- 1-bit output port
        o_Cout  : out std_logic                         -- (NOTE: NO semicolon on LAST port only!)
        
     ); -- the semicolon is here instead    
   end component;
  
  

  -- declare any signals you will need
  
    signal w_Cin : std_logic := '0';
    signal w_S1  : std_logic := '0';
    
    signal w_Cout1 : std_logic := '0';
    signal w_Cout2 : std_logic := '0';
  
begin
	-- PORT MAPS --------------------
	
	halfAdder1_inst: halfAdder
	port map(
	   i_A     => i_A1,
	   i_B     => i_B1,
	   o_S     => w_S1,
	   o_Cout  => w_Cout1
	);
	 
	 halfAdder2_inst: halfAdder
	 port map(
	    i_A     => w_S1,
	    i_B     => w_Cin,
	    o_S     => o_S1,
	    o_Cout  => w_Cout2
	 );
	 
    
   o_Cout1 <= w_Cout1 or w_Cout2;

end fullAdder_arch;
