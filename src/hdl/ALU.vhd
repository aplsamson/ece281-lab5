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
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|     AND     001
--|     OR      010
--|     LS      011
--|     RS      100
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
    
    port(
        i_A  : in STD_LOGIC_VECTOR(7 downto 0);
        i_B  : in STD_LOGIC_VECTOR(7 downto 0);
        i_op : in STD_LOGIC_VECTOR(2 downto 0);
        
        o_result : out STD_LOGIC_VECTOR(7 downto 0);
        o_flag   : out STD_LOGIC_VECTOR(2 downto 0) := "000"
        
    );
    
end ALU;

architecture behavioral of ALU is 
  
	-- declare components and signals
	
	signal w_A, w_B : std_logic_vector(7 downto 0);
	signal w_Cout   : std_logic;
	signal w_result : STD_LOGIC_VECTOR(7 downto 0);
	signal w_shift  : STD_LOGIC_VECTOR(2 downto 0);
	
	
	impure function add_sub(A, B : std_logic_vector) return signed is
            variable sum : integer;
            
            
            begin
                
                sum := to_integer(signed(A)) + to_integer(signed(B));
                
                
                return (to_signed(sum, 8));
             
    end add_sub;
    
          
    impure function and_or(A, B : std_logic_vector) return std_logic_vector is
            
            begin
                          
             if(i_op = "001") then
                return A and B;
             elsif(i_op = "101") then
                return A or B;
             end if; 
                       
    end and_or;
	
	
	impure function leftShift(A : std_logic_vector) return std_logic_vector is
	   variable shift : integer;
       begin
       
        shift := to_integer(unsigned(i_B(2 downto 0)));
        
        if (shift = 0) then
            return A;
        elsif (shift = 1) then
            return A(6 downto 0) & ("0");
        elsif (shift = 2) then
            return A(5 downto 0) & ("00");
        elsif (shift = 3) then
            return A(4 downto 0) & ("000");
        elsif (shift = 4) then
            return A(3 downto 0) & ("0000");
        elsif (shift = 5) then
            return A(2 downto 0) & ("00000");
        elsif (shift = 6) then
            return A(1 downto 0) & ("000000");
        elsif (shift = 7) then
            return A(0) & ("0000000");
        else
            return "00000000";
        end if;
        
     end leftShift;
     
     impure function rightShift(A : std_logic_vector) return std_logic_vector is
            variable shift : integer;
        begin
            
         shift := to_integer(unsigned(i_B(2 downto 0)));
         
         if (shift = 0) then
             return A;
         elsif (shift = 1) then
             return "0" & A(7 downto 1);
         elsif (shift = 2) then
             return "00" & A(7 downto 2);
         elsif (shift = 3) then
             return "000" & A(7 downto 3);
         elsif (shift = 4) then
             return "0000" & A(7 downto 4);
         elsif (shift = 5) then
             return "00000" & A(7 downto 5);
         elsif (shift = 6) then
             return "000000" & A(7 downto 6);
         elsif (shift = 7) then
             return "0000000" & A(7);
         else
             return "00000000";
         end if;
         
      end rightShift;

  
begin
	
	-- CONCURRENT STATEMENTS ----------------------------
  
	
	w_result <= (std_logic_vector(add_sub(i_A, i_B)(7 downto 0))) when (i_op = "000") else 
	            (and_or(i_A, i_B)) when (i_op = "001") or (i_op = "010") else
	            (leftShift(i_A)) when (i_op = "011") else
	            (rightShift(i_A)) when (i_op = "100");
	            
	
	o_flag(0) <= '1' when (w_result = "00000000") else '0'; -- zero flag
	o_flag(1) <= w_Cout; -- carry flag
	o_flag(2) <= w_result(7) when (i_op = "000"); -- negative flag
	
	o_result <= w_result;
	            
	            
	            
	   
	
end behavioral;
