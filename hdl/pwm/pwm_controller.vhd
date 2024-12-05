library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pwm_controller is
    generic (
		  CLK_PERIOD : time := 20 ns
    );
    port (
        clk          : in  std_logic;                    
        rst          : in  std_logic;                    
        period       : in  unsigned(24 - 1 downto 0);  
        duty_cycle   : in  std_logic_vector(18 - 1 downto 0);  
        output       : out std_logic                        
    );
end entity pwm_controller;

architecture Behavioral of pwm_controller is
    
    signal duty_cycle_int  : unsigned(18 - 1 downto 0);  
    signal on_time         : unsigned(24 - 1 downto 0);      
   -- signal counter         : unsigned(24 - 1 downto 0) := (to_unsigned(0, 24));      
    signal counter         : integer := 0;
	 --signal on_time_scaled : unsigned(23 downto 0);

	 constant N_BITS_SYS_CLK_FREQ : natural := natural(ceil(log2(real(1 ms / CLK_PERIOD))));
		
	constant SYS_CLK_FREQ : unsigned(N_BITS_SYS_CLK_FREQ - 1 downto 0) := to_unsigned((1 ms /CLK_PERIOD), N_BITS_SYS_CLK_FREQ);

	constant N_BITS_CLK_CYCLES_FULL : natural := N_BITS_SYS_CLK_FREQ + 24;

	constant N_BITS_CLK_CYCLES : natural := N_BITS_SYS_CLK_FREQ + 20;

	signal period_base_clk_full_prec : unsigned(N_BITS_CLK_CYCLES_FULL - 1 downto 0);

	--signal period_base_clk : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
	signal period_base_clk : unsigned(20 downto 0);
	
begin

	   period_base_clk_full_prec <= SYS_CLK_FREQ * period;
	
 	   period_base_clk <= period_base_clk_full_prec(N_BITS_CLK_CYCLES_FULL - 1 downto 19);

    process(clk, rst)
    begin
        if rst = '1' then
           -- counter <= (others => '0');
	    counter <= 0;
            on_time <= (others => '0');
            duty_cycle_int <= (others => '0');
            output <= '0';
        elsif rising_edge(clk) then
            
            duty_cycle_int <= unsigned(duty_cycle);

        
            on_time <= resize((duty_cycle_int * period_base_clk), 42)(41 downto 18);

            
            if to_unsigned(counter, 25) = period_base_clk then
               -- counter <= (others => '0');  
		  counter <= 0;  
            else
                counter <= counter + 1;  
            end if;

           
            if counter < on_time then
                output <= '1';  
            else
                output <= '0';  
            end if;
        end if;
    end process;
end architecture Behavioral;
