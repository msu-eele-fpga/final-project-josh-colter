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

  -- The address width is 3 bits wide, so we can have up to 2^3 registers
  -- in our design. For real designs, *please* use better names than reg0, etc.
  -- *Always* give your registers a good default power-up value.
  signal duty_cycle: std_logic_vector(17 downto 0) :=  (others => '0');
  signal period_reg: std_logic_vector(23 downto 0) :=  (others => '0');
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

    -- If the master asserts the read signal, a read is being performed
   --if rising_edge(clk) and avs_read = '1' then
	 if rising_edge(clk) then

      -- Each address specifies the offset/address of your register in
      -- *32-bit words*, not bytes. This is a bit confusing at times because
      -- the rest of the system, including software you'll write, always uses -- memory addresses in bytes.
      case avs_address is

        -- The order of the regsiters is arbitrary and up to you; you get to
        -- choose the register memory map.
        when "00" =>
	       avs_readdata <= (others => '0');	  
          avs_readdata(17 downto 0) <= duty_cycle;

        when "01" =>
          -- If the register doesn't use all 32-bits, we can either declare
          -- the register signal as the true number of bits and then perform
          -- any padding operations here, or we can declare the register signal
          -- as 32-bits and do bit-slicing/indexing in the port map. We do the
          -- former in this case.

          -- Assuming reg1 is an unisgned value and doesn't need to be
          -- sign-extended, we can set all the bits to 0 and then overwrite
          -- the relevant bits with the actual register value.
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
      -- Reset registers to their default values
      duty_cycle <= "010000000000000000";
      period_reg <= "000000000000001111101000";

    -- If the master asserts the write signal, a write is being performed
    elsif rising_edge(clk) and avs_write = '1' then

      case avs_address is

        -- Make sure you choose the same register/address order as you did in
        -- the read process!
        when "00" =>
          duty_cycle <= avs_writedata(17 downto 0);

        when "01" =>
          period_reg <= avs_writedata(23 downto 0);

        when others =>
          -- For all unused addresses, do nothing
          null;

      end case;

    end if;

  end process write;

end architecture;