library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_controller_avalon is
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
		servo_PWM : out std_logic
	);
end entity servo_controller_avalon;


architecture servo_controller_avalon_arch of servo_controller_avalon is

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

begin

	PWM : component pwm_controller
		port map(
        clk          => clk,                  
        rst          => rst,                    
        period       => unsigned(period_reg), 
        duty_cycle   => duty_cycle,  
        output       => servo_PWM                       
		);

	

  read : process (clk)
  begin

        --Read duty cycle
        when "00" =>
	       avs_readdata <= (others => '0');	  
          avs_readdata(17 downto 0) <= duty_cycle;

        --Read period
        when "01" =>
          avs_readdata <= (others => '0');
          avs_readdata(23 downto 0) <= period_reg;

        when others =>
          -- For all unused addresses, return 0.
          avs_readdata <= (others => '0');

      end case;

    end if;

  end process read;

  write : process (clk, rst)
  begin

    if rst = '1' then
      -- Default to half second period, max servo PWM
      duty_cycle <= "010000000000000000";
      period_reg <= "000000000000001111101000";

    elsif rising_edge(clk) and avs_write = '1' then

      case avs_address is

        --Write duty cycle
        when "00" =>
          duty_cycle <= avs_writedata(17 downto 0);

        --Write period
        when "01" =>
          period_reg <= avs_writedata(23 downto 0);

        when others =>
          -- For all unused addresses, do nothing
          null;

      end case;

    end if;

  end process write;

end architecture;