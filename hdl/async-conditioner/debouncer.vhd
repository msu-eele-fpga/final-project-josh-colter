library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity debouncer is
	generic (
		clk_period : time := 20 ns;
		debounce_time : time
	);
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		input : in std_ulogic;
		debounced : out std_ulogic
	);
end entity debouncer;


architecture debouncer_arch of debouncer is

	constant DEBOUNCE_CYCLES : integer := integer(debounce_time / clk_period);

	signal clock_count : integer := 0;
	signal post_clock_flag : std_logic := '0';
	signal debounce_input : std_logic := '0';

	begin
		-- Debouncer process

		debounce_proc : process (clk, rst)
		   begin
			if rst = '1' then
			   clock_count <= 0;
			   debounce_input <= '0';
			   debounced <= '0';
			   post_clock_flag <= '0';
			elsif rising_edge(clk) then
			   if post_clock_flag = '0' then
				if debounce_input = '1' then
				   if clock_count < (DEBOUNCE_CYCLES - 1) then
				      clock_count <= clock_count + 1;
				   elsif input = '0' then
				      post_clock_flag <= '1';
				      clock_count <= 0;
				      debounce_input <= '0';
				      debounced <= input;
				   else
				      debounced <= input;
				   end if;
				else
				   debounced <= input;
				  debounce_input <= input;
				end if; 
			   else
			   	if clock_count < (DEBOUNCE_CYCLES - 1) then
				      clock_count <= clock_count + 1;
				else
				   clock_count <= 0;
				   post_clock_flag <= '0';
				end if;
			   end if;
			end if;
	   	end process debounce_proc;
			

		

	   

end architecture debouncer_arch;