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
	
	--Signal to hold the output of the button press
	signal button_press_output : std_logic;

  -- The address width is 3 bits wide, so we can have up to 2^3 registers
  -- in our design. For real designs, *please* use better names than reg0, etc.
  -- *Always* give your registers a good default power-up value.
  signal button_press_register: std_logic := '0';

begin


  write : process (clk, rst)
  begin

    if rst = '1' then
      -- Reset registers to their default values
		button_press_register <= '0';

    -- If the master asserts the write signal, a write is being performed
    elsif rising_edge(clk) and avs_write = '1' then

      case avs_address is
        when "000" =>
				button_press_register <= avs_writedata(0);
        when others =>
          null;
      end case;
	 elsif rising_edge(clk)  and avs_read = '1' then
		case button_push is
			when '0' =>
				button_press_register <= '0';
			when '1' => 
				button_press_register <= '1';
			end case;
      case avs_address is
        when "000" =>
	       avs_readdata <= (others => '0');
          avs_readdata(0) <= button_press_register;
		  when others =>
          avs_readdata <= (others => '0');
      end case;
    end if;
  end process write;

end architecture;