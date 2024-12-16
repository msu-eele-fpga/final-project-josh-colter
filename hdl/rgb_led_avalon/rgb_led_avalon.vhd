library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_led_avalon is
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;

		-- avalon memory-mapped slave interface
		avs_read : in std_logic;
		avs_write : in std_logic;
		avs_address : in std_logic_vector(1 downto 0);
		avs_readdata : out std_logic_vector(31 downto 0);
		avs_writedata : in std_logic_vector(31 downto 0);

		-- external I/O; export to top-level
		output1 : out std_logic;
		output2 : out std_logic;
		output3 : out std_logic
	);
end entity rgb_led_avalon;


architecture rgb_led_avalon_arch of rgb_led_avalon is

	Component pwm_controller is
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
	end Component pwm_controller;


  signal duty_cycle_red: std_logic_vector(17 downto 0) :=  (others => '0');
  signal duty_cycle_green: std_logic_vector(17 downto 0) :=  (others => '0');
  signal duty_cycle_blue: std_logic_vector(17 downto 0) :=  (others => '0');
  signal period_reg: std_logic_vector(23 downto 0) :=  (others => '0');

begin

	dut1 : component pwm_controller
		port map(
        clk          => clk,                  
        rst          => rst,                    
        period       => unsigned(period_reg), 
        duty_cycle   => duty_cycle_red,  
        output       => output1                       
		);
		
	dut2 : component pwm_controller
		port map(
        clk          => clk,                  
        rst          => rst,                    
        period       => unsigned(period_reg), 
        duty_cycle   => duty_cycle_green,  
        output       => output2                       
		);

	dut3 : component pwm_controller
		port map(
        clk          => clk,                  
        rst          => rst,                    
        period       => unsigned(period_reg), 
        duty_cycle   => duty_cycle_blue,  
        output       => output3                       
		);

  read : process (clk)
  begin

	 if rising_edge(clk) then

      case avs_address is

        --read duty cycle 1
        when "00" =>
	       avs_readdata <= (others => '0');	  
          avs_readdata(17 downto 0) <= duty_cycle_red;

        --read duty cycle 2
        when "01" =>
          avs_readdata <= (others => '0');
          avs_readdata(17 downto 0) <= duty_cycle_green;

        --read duty cycle 3
        when "10" =>
          avs_readdata <= (others => '0');
          avs_readdata(17 downto 0) <= duty_cycle_blue;

        --read period
        when "11" =>
          avs_readdata <= (others => '0');
          avs_readdata(23 downto 0) <= period_reg;

        when others =>
          -- For all unused addresses, we should return 0.
          avs_readdata <= (others => '0');

      end case;

    end if;

  end process read;

  write : process (clk, rst)
  begin

    if rst = '1' then
      -- Default values: 500ms period, 50% duty cycle
      duty_cycle_red <= "010000000000000000";
      duty_cycle_green <= "010000000000000000";
      duty_cycle_blue <= "010000000000000000";
      period_reg <= "000000100000000000000000";
      reg4 <= (others => '0');

    --using if/elsif here to assure values aren't assigned twice if reset and avs_write are asserted
    elsif rising_edge(clk) and avs_write = '1' then

      case avs_address is

        --write duty cycle 1
        when "00" =>
          duty_cycle_red <= avs_writedata(17 downto 0);

        --write duty cycle 2
        when "01" =>
          duty_cycle_green <= avs_writedata(17 downto 0);

        --write duty cycle 3
        when "10" =>
          duty_cycle_blue <= (avs_writedata(17 downto 0));

        --write period
        when "11" =>
          period_reg <= avs_writedata(23 downto 0);

        when others =>
          -- For all unused addresses, do nothing
          null;

      end case;

    end if;

  end process write;

end architecture;