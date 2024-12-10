library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
    port (
      clk   : in    std_logic;
      async : in    std_ulogic;
      sync  : out   std_ulogic
    );
end entity synchronizer;

architecture synchronizer_arch of synchronizer is
	signal temp : std_logic;

	begin

		synchronizer_proc : process (clk)
		   begin
		      if (rising_edge(clk)) then
		         temp <= async;
			 sync <= temp;
		      end if;
		end process;



end architecture;