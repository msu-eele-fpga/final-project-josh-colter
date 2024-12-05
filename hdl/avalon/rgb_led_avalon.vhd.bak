library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_patterns_avalon is
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
		push_button : in std_ulogic;
		switches : in std_ulogic_vector(3 downto 0);
		led : out std_ulogic_vector(7 downto 0)
	);
end entity led_patterns_avalon;


architecture led_patterns_avalon_arch of led_patterns_avalon is

	component led_pattern is
	generic (
		system_clock_period : time := 20 ns
	);
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		push_button : in std_ulogic;
		switches : in std_ulogic_vector(3 downto 0);
		hps_led_control : in boolean;
		base_period : in unsigned(7 downto 0);
		led_reg : in std_ulogic_vector(7 downto 0);
		led : out std_ulogic_vector(7 downto 0)
	);
	end component led_pattern;

  -- The address width is 3 bits wide, so we can have up to 2^3 registers
  -- in our design. For real designs, *please* use better names than reg0, etc.
  -- *Always* give your registers a good default power-up value.
  signal reg0: std_logic := '0';
  signal reg1: std_logic_vector(3 downto 0) := "1011";
  signal reg2: signed(7 downto 0) := (others => '0');
  signal reg3: std_logic_vector(7 downto 0) := "00010000";
  signal reg0Bool : boolean := true;

  -- reg4 is actually only using bits 7 downto 0, so it's 8-bits wide, but
  -- we declare it as 32-bits.logic
  signal reg4: std_logic_vector(31 downto 0) := (others => '0');
  signal led_connection: std_ulogic_vector(7 downto 0);

begin

	 dut : component led_pattern
	    port map (
	      clk   => clk,
	      rst => rst,
	      push_button  => push_button,
	      switches => switches,
	      hps_led_control => reg0Bool,
	      base_period => unsigned(reg3),
	      led_reg => std_ulogic_vector(reg2),
	      led => led_connection
	 );

  -- To do anything useful, your registers should be hooked up to a component,
  -- so you'll typically instantiate your component here.

  
	 with reg0Bool select
		led <= led_connection when true,
		       std_ulogic_vector(reg2) when false;

  read : process (clk)
  begin

    -- If the master asserts the read signal, a read is being performed
    if rising_edge(clk) and avs_read = '1' then

      -- Each address specifies the offset/address of your register in
      -- *32-bit words*, not bytes. This is a bit confusing at times because
      -- the rest of the system, including software you'll write, always uses -- memory addresses in bytes.
      case avs_address is

        -- The order of the regsiters is arbitrary and up to you; you get to
        -- choose the register memory map.
        when "00" =>
	       avs_readdata <= (others => '0');	  
          avs_readdata(0) <= reg0;

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
          avs_readdata(3 downto 0) <= reg1;

        when "10" =>
          -- If the register is a signed number, we can do sign-extension as
          -- shown below.
          avs_readdata <= std_logic_vector(resize(reg2, 32));

        when "11" =>
          -- We can also do sign-extension this way, if for some reason you
          -- *really* don't want to declare the register as signed (which you
          -- *reall* should do).
          avs_readdata <= (others => reg3(reg3'left));
          avs_readdata(7 downto 0) <= reg3;

--        when "100" =>
--          -- reg4 is only 8-bits wide, but we declared it as 32-bits. This
--          -- simplifies the read transacation, but complicates our
--          -- component's port map and write process.
--          avs_readdata <= reg4;

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
      reg0 <= '0';
      reg1 <= "1011";
      reg2 <= (others => '0');
      reg3 <= "00010000";
      reg4 <= (others => '0');

    -- If the master asserts the write signal, a write is being performed
    elsif rising_edge(clk) and avs_write = '1' then

      case avs_address is

        -- Make sure you choose the same register/address order as you did in
        -- the read process!
        when "00" =>
          reg0 <= avs_writedata(0);
   	  case reg0 is
		when '1' =>
			reg0Bool <= true;
		when '0' => 
			reg0Bool <= false;
	  end case;

        when "01" =>
          -- Since reg1 is only 4-bits wide, and we defined the register
          -- such that we're using the bottom 4 bits, we only use the bottom
          -- 4 bits of the writedata signal. If the master writes anything in
          -- the other bits, we ignore that (silently, which is not very nice
          -- to the master...)
          reg1 <= avs_writedata(3 downto 0);

        when "10" =>
          reg2 <= signed(avs_writedata(7 downto 0));

        when "11" =>
          reg3 <= avs_writedata(7 downto 0);

--        when "100" =>
--          -- reg4 is only 8-bits wide, but we declared it as 32-bits.
--          -- We can either accept all 32-bits from the master, even if it
--          -- writes invalid values to the unused bits, or we can only read
--          -- the bottom 8 bits and force all other values to 0 (if the unused
--          -- bits should be set to 0). Either way, when we instantiate our
--          -- component in this file, we should only use the bottom 8-bits
--          -- in our port map for reg4. In that case, what we do here doesn't
--          -- matter to our hardware, but it does make a difference for what the
--          -- software would see for the unused bits.
--          reg4 <= (others => '0');
--          reg4 <= avs_writedata(8 downto 0);

        when others =>
          -- For all unused addresses, do nothing
          null;

      end case;

    end if;

  end process write;

end architecture;