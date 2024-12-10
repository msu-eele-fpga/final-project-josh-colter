library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity async_conditioner is
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		async : in std_ulogic;
		sync : out std_ulogic
	);
end entity async_conditioner;


architecture async_conditioner_arch of async_conditioner is

	component debouncer is 
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
	end component debouncer;

	component synchronizer is 
	port (
	      clk   : in    std_logic;
	      async : in    std_ulogic;
	      sync  : out   std_ulogic
	);
	end component synchronizer;

	component one_pulse is 
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		input : in std_ulogic;
		pulse : out std_ulogic
	);
	end component one_pulse;

	constant CLK_PERIOD : time := 20 ns;
	constant DEBOUNCE_TIME_1US : time    := 1000 ns;
	signal debounce_input : std_ulogic;
	signal one_pulse_input : std_ulogic; 

	begin 

	   synchronizer_comp : component synchronizer
		port map (
		   clk => clk,
		   async => async,
		   sync => debounce_input
		);

	   debouncer_comp : component debouncer
		generic map (
		   clk_period => CLK_PERIOD,
		   debounce_time => DEBOUNCE_TIME_1US
		)
		port map (
		   clk => clk,
		   rst => rst,
		   input => debounce_input,
		   debounced => one_pulse_input
		);

	   one_pulse_comp : component one_pulse
		port map (
		   clk => clk,
		   rst => async,
		   input => one_pulse_input,
		   pulse => sync
		);
	
	
	
end architecture;










