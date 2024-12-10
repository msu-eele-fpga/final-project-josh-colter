library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity one_pulse is
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		input : in std_ulogic;
		pulse : out std_ulogic
	);
end entity one_pulse;

architecture one_pulse_arch of one_pulse is

	type state_type is (wait_state, high_state, low_state);
	signal current_state : state_type;
	signal next_state : state_type;

	begin

	   -- Synchronous
	   state_memory : process (clk, rst)
		begin
		   if (rst = '1') then
			current_state <= wait_state;
		   elsif (rising_edge(clk)) then
			current_state <= next_state;
		   end if;
	   end process state_memory;

	   -- Combinational
	   next_state_logic : process (current_state, input, clk)
		begin
		 if (rising_edge(clk)) then
		   case current_state is
			when wait_state => 
			   if (input = '1') then
				next_state <= high_state;
			   else
				next_state <= wait_state;
			   end if;
			when high_state => 
			   next_state <= low_state;
			when low_state => 
			   if (input = '1') then
				next_state <= low_state;
			   else
				next_state <= wait_state;
			   end if;
		   end case;
			end if;
	   end process next_state_logic;

	   -- Combinational
	   output_logic : process (current_state, clk)
	     	begin
			if (rising_edge(clk)) then
		   case current_state is
			when wait_state => 
			   pulse <= '0';
			when high_state => 
			   pulse <= '1';
			when low_state => 
			   pulse <= '0';
		   end case;
			end if;
	   end process output_logic;

end architecture one_pulse_arch;