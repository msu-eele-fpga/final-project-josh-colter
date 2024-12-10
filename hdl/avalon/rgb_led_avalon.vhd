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
		avs_address : in std_logic_vector(2 downto 0);
		avs_readdata : out std_logic_vector(31 downto 0);
		avs_writedata : in std_logic_vector(31 downto 0);

		-- external I/O; export to top-level
		button_push : in std_ulogic;
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
	
	component async_conditioner is 
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		async : in std_ulogic;
		sync : out std_ulogic
	);
	end component async_conditioner;
	
	--Signal to hold the output of the button press
	signal button_press_output : std_logic;

  -- The address width is 3 bits wide, so we can have up to 2^3 registers
  -- in our design. For real designs, *please* use better names than reg0, etc.
  -- *Always* give your registers a good default power-up value.
  signal button_press_register: std_logic := '0';
  signal duty_cycle1: std_logic_vector(17 downto 0) :=  (others => '0');
  signal duty_cycle2: std_logic_vector(17 downto 0) :=  (others => '0');
  signal duty_cycle3: std_logic_vector(17 downto 0) :=  (others => '0');
  signal period_reg: std_logic_vector(23 downto 0) :=  (others => '0');

begin

	async_conditioner_comp : component async_conditioner
	port map (
		clk => clk,
		rst => rst,
		async => button_push,
		sync => button_press_output
	);

	dut1 : component pwm_controller
		port map(
        clk          => clk,                  
        rst          => rst,                    
        period       => unsigned(period_reg), 
        duty_cycle   => duty_cycle1,  
        output       => output1                       
		);
		
	dut2 : component pwm_controller
		port map(
        clk          => clk,                  
        rst          => rst,                    
        period       => unsigned(period_reg), 
        duty_cycle   => duty_cycle2,  
        output       => output2                       
		);

	dut3 : component pwm_controller
		port map(
        clk          => clk,                  
        rst          => rst,                    
        period       => unsigned(period_reg), 
        duty_cycle   => duty_cycle3,  
        output       => output3                       
		);


  read : process (clk)
  begin
	 if rising_edge(clk) then
      case avs_address is
        when "000" =>
	       avs_readdata <= (others => '0');	  
          avs_readdata(17 downto 0) <= duty_cycle1;
        when "001" =>
          avs_readdata <= (others => '0');
          avs_readdata(17 downto 0) <= duty_cycle2;
        when "010" =>
          avs_readdata <= (others => '0');
          avs_readdata(17 downto 0) <= duty_cycle3;
        when "011" =>
          avs_readdata <= (others => '0');
          avs_readdata(23 downto 0) <= period_reg;
        when "100" =>
		    avs_readdata <= (others => '0');
          avs_readdata(0) <= button_press_register;
        when others =>
          avs_readdata <= (others => '0');
      end case;
    end if;
  end process read;

  write : process (clk, rst)
  begin

    if rst = '1' then
      -- Reset registers to their default values
      duty_cycle1 <= "010000000000000000"; --65536
      duty_cycle2 <= "010000000000000000";
      duty_cycle3 <= "010000000000000000";
      period_reg <= "000000000000001111101000"; --1000
		button_press_register <= '0';

    -- If the master asserts the write signal, a write is being performed
    elsif rising_edge(clk) and avs_write = '1' then

		case button_push is
			when '0' =>
				button_press_register <= '0';
			when '1' => 
				button_press_register <= '1';
			end case;

      case avs_address is
        when "000" =>
          duty_cycle1 <= avs_writedata(17 downto 0);
        when "001" =>
          duty_cycle2 <= avs_writedata(17 downto 0);
        when "010" =>
          duty_cycle3 <= (avs_writedata(17 downto 0));
        when "011" =>
          period_reg <= avs_writedata(23 downto 0);

       -- when "100" =>
		  
--          -- reg4 is only 8-bits wide, but we declared it as 32-bits.
--          -- We can either accept all 32-bits from the master, even if it
--          -- writes invalid values to the unused bits, or we can only read
--          -- the bottom 8 bits and force all other values to 0 (if the unused
--          -- bits should be set to 0). Either way, when we instantiate our
--          -- component in this file, we should only use the bottom 8-bits
--          -- in our port map for reg4. In that case, what we do here doesn't
--          -- matter to our hardware, but it does make a difference for what the
--          -- software would see for the unused bits.

        when others =>
          null;
      end case;
    end if;
  end process write;

end architecture;