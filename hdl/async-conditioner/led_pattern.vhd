library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity led_pattern is
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
end entity led_pattern;

architecture led_pattern_arch of led_pattern is

	component async_conditioner is 
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		async : in std_ulogic;
		sync : out std_ulogic
	);
	end component async_conditioner;

	-- Fixed point math and signals ------------------------------------------
	
	constant N_BITS_SYS_CLK_FREQ : natural := natural(ceil(log2(real(1 sec / system_clock_period))));
		
	constant SYS_CLK_FREQ : unsigned(N_BITS_SYS_CLK_FREQ - 1 downto 0) := to_unsigned((1 sec /system_clock_period), N_BITS_SYS_CLK_FREQ);

	constant N_BITS_CLK_CYCLES_FULL : natural := N_BITS_SYS_CLK_FREQ + 8;

	constant N_BITS_CLK_CYCLES : natural := N_BITS_SYS_CLK_FREQ + 4;

	signal period_base_clk_full_prec : unsigned(N_BITS_CLK_CYCLES_FULL - 1 downto 0);

	signal period_base_clk : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);

--	-- for dividing
--	shift_right(period_base_clk, 1);

	-- state machine signals --------------------------------------------

	type state_type is (S0, S1, S2, S3, S4, SD);
	signal current_state : state_type;
	signal next_state : state_type;
	signal previous_state : state_type;
	signal mux_select : std_ulogic_vector(2 downto 0);
	signal button_press_output : std_logic;

	-- Led pattern control singal ------------------------------------------
	
	signal leds_p1 : std_ulogic_vector(6 downto 0) := "1000000";
	signal leds_p2 : std_ulogic_vector(6 downto 0) := "0000001";
	signal leds_p3 : std_ulogic_vector(6 downto 0) := "0000000";
	signal leds_p4 : std_ulogic_vector(6 downto 0) := "1111111";
	signal leds_p5 : std_ulogic_vector(6 downto 0) := "1000001";
	signal led_7 : std_ulogic := '0';
	-- signal leds    : std_ulogic_vector(7 downto 0);
	signal counter_p3 : unsigned(6 downto 0) := (others => '0');
	signal counter_p4 : unsigned(6 downto 0) := (others => '0');
	signal counter_p5 : unsigned(6 downto 0) := "1000001";

	-- Clock Generator signal ----------------------------------------------

	--signal current_rate : unsigned(39 downto 0) := (others => '0');
	signal temp_clk_p1 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
	signal cnt_p1 : unsigned(39 downto 0) := (others => '0');
	signal clk_p1 : std_logic := '0';
	signal prev_value_p1 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0) := (others => '0');

	signal temp_clk_p2 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
	signal cnt_p2 : unsigned(39 downto 0) := (others => '0');
	signal clk_p2 : std_logic := '0';
	signal prev_value_p2 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0) := (others => '0');

	signal temp_clk_p3 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
	signal cnt_p3 : unsigned(39 downto 0) := (others => '0');
	signal clk_p3 : std_logic := '0';
	signal prev_value_p3 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0) := (others => '0');

	signal temp_clk_p4 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
	signal cnt_p4 : unsigned(39 downto 0) := (others => '0');
	signal clk_p4 : std_logic := '0';
	signal prev_value_p4 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0) := (others => '0');

	signal temp_clk_p5 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
	signal cnt_p5 : unsigned(39 downto 0) := (others => '0');
	signal clk_p5 : std_logic := '0';
	signal prev_value_p5 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0) := (others => '0');

	signal temp_clk_b7 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
	signal cnt_b7 : unsigned(39 downto 0) := (others => '0');
	signal clk_b7 : std_logic := '0';
	signal prev_value_p7 : unsigned(N_BITS_CLK_CYCLES - 1 downto 0) := (others => '0');

	-- 1 second delay signals ------------------------------------------------------
	constant COUNTER_LIMIT : integer := 1000000000 ns / system_clock_period;
	signal counter : integer range 0 to 999999999 := 0;
	signal done : boolean := false;

	begin

	   async_conditioner_comp : component async_conditioner
		port map (
		   clk => clk,
		   rst => rst,
		   async => push_button,
		   sync => button_press_output
		);
		
	   period_base_clk_full_prec <= SYS_CLK_FREQ * base_period;
	
 	   period_base_clk <= period_base_clk_full_prec(N_BITS_CLK_CYCLES_FULL - 1 downto 4);

	   
	   temp_clk_p1 <= shift_right(period_base_clk, 1);
	  
	   temp_clk_p2 <= shift_right(period_base_clk, 2);
	   
	   temp_clk_p3 <= shift_left(period_base_clk, 1);
	   
	   temp_clk_p4 <= shift_right(period_base_clk, 3);
	   
	   temp_clk_p5 <= shift_right(period_base_clk, 2);

	   temp_clk_b7 <= period_base_clk;
	
	
	   -- Synchronous
	   state_memory : process (clk, rst)
		begin
		   if (rst = '1') then
			current_state <= S0;
		   elsif (rising_edge(clk)) then
			if (current_state /= SD) then
				previous_state <= current_state;
			end if;
			current_state <= next_state;
		   end if;
	   end process state_memory;

	   -- Combinational
	   next_state_logic : process (current_state, button_press_output, clk)
		begin
		 if (rising_edge(clk)) then
		   case current_state is
			when S0 => 
			   if (button_press_output = '1') then
				next_state <= SD;
			   end if;
			when S1 => 
			   if (button_press_output = '1') then
				next_state <= SD;
			   end if;
			when S2 => 
			   if (button_press_output = '1') then
				next_state <= SD;
			   end if;
			when S3 => 
			   if (button_press_output = '1') then
				next_state <= SD;
			   end if;
			when S4 => 
			   if (button_press_output = '1') then
				next_state <= SD;
			   end if;
			when SD => 
			   if (switches = "0000" and done = true) then
				next_state <= S0;
			   elsif (switches = "0001" and done = true) then
				next_state <= S1;
			   elsif (switches = "0010" and done = true) then
				next_state <= S2;
			   elsif (switches = "0011" and done = true) then
				next_state <= S3;
			   elsif (switches = "0100" and done = true) then
				next_state <= S4;
			   elsif ((switches = "1000" or switches = "1001" or switches = "1010" or switches = "1011" or switches = "1100" or switches = "1101" or switches = "1110" or switches = "1111") and done = true) then next_state <= previous_state; 
			   end if;
		   end case;
		 end if;
	   end process next_state_logic;

	   -- Combinational
	   output_logic : process (current_state, clk)
	     	begin
			if (rising_edge(clk)) then
		   case current_state is
			when S0 => 
			   mux_select <= "000";
			when S1 => 
			   mux_select <= "001";
			when S2 => 
			   mux_select <= "010";
			when S3 => 
			   mux_select <= "011";
			when S4 => 
			   mux_select <= "100";
			when SD => 
			   mux_select <= "111";
		   end case;
			end if;
	   end process output_logic;

---- Pattern one start ----------------------------------------------------------------------------------------------
	
	pattern1 : process (clk_p1)
	   begin
	      if(rising_edge(clk_p1)) then
			--if (clk_p1 = '1') then
		if(leds_p1 = "0000001") then
			leds_p1 <= "1000000";
		else
			leds_p1 <= std_ulogic_vector(shift_right(unsigned(leds_p1), 1));
		end if;
				else 
			--leds_p1 <= ("0000000");
		end if;
	      --end if;
	end process pattern1;

	clock_gen_p1 : process (clk, rst, period_base_clk)
		begin
		   if rst = '1' then
				cnt_p1 <= (others => '0');
		   elsif rising_edge(clk) then
				cnt_p1 <= cnt_p1 + 1;
				if (cnt_p1 = temp_clk_p1) then
					clk_p1 <= not clk_p1;
					cnt_p1 <= (others => '0');
				end if;
		   end if;
			if(prev_value_p1 /= temp_clk_p1) then
				cnt_p1 <= (others => '0');
				prev_value_p1 <= temp_clk_p1;
			end if;
	end process clock_gen_p1;

---- Pattern one End ------------------------------------------------------------------------------------------------


---- Pattern two start ----------------------------------------------------------------------------------------------
	
	pattern2 : process (clk_p2)
	   begin
	      if(rising_edge(clk_p2)) then
			-- if (clk_p2 = '1') then
		if (leds_p2 = "1000000") then
			leds_p2 <= "0000001";
		else
			leds_p2 <= std_ulogic_vector(shift_left(unsigned(leds_p2), 1));
		end if;
				else 
			--leds_p2 <= ("0000000");
		 --end if;
	      end if;
	end process pattern2;

	clock_gen_p2 : process (clk, rst)
		begin
		   if rst = '1' then
			cnt_p2 <= (others => '0');
		   elsif rising_edge(clk) then
			cnt_p2 <= cnt_p2 + 1;
			if (cnt_p2 = temp_clk_p2) then
			   clk_p2 <= not clk_p2;
			   cnt_p2 <= (others => '0');
			end if;
		   end if;
			if(prev_value_p2 /= temp_clk_p2) then
				cnt_p2 <= (others => '0');
				prev_value_p2 <= temp_clk_p2;
			end if;
	end process clock_gen_p2;

---- Pattern two End ------------------------------------------------------------------------------------------------

---- Pattern three start ----------------------------------------------------------------------------------------------
	
	pattern3 : process (clk_p3)
	   begin
	      if (rising_edge(clk_p3)) then
			 --if (clk_p3 = '1') then
		if (counter_p3 = "1111111") then
			leds_p3(6 downto 0) <= (std_ulogic_vector(counter_p3));
			counter_p3 <= (others => '0');
		else
			leds_p3(6 downto 0) <= (std_ulogic_vector(counter_p3));
			counter_p3 <= counter_p3 + 1;
		end if;
				else 
			--leds_p3 <= ("0000000");
		-- end if;
	      end if;
	end process pattern3;

	clock_gen_p3 : process (clk, rst)
		begin
		   if rst = '1' then
			cnt_p3 <= (others => '0');
		   elsif rising_edge(clk) then
			cnt_p3 <= cnt_p3 + 1;
			if (cnt_p3 = temp_clk_p3) then
			   clk_p3 <= not clk_p3;
			   cnt_p3 <= (others => '0');
			end if;
		   end if;
			if(prev_value_p3 /= temp_clk_p3) then
				cnt_p3 <= (others => '0');
				prev_value_p3 <= temp_clk_p3;
			end if;
	end process clock_gen_p3;

---- Pattern three End ------------------------------------------------------------------------------------------------


---- Pattern four start ----------------------------------------------------------------------------------------------
	
	pattern4 : process (clk_p4)
	   begin
	      if(rising_edge(clk_p4)) then
			--if(clk_p4 = '1') then
		if(counter_p4 = "0000000") then
			leds_p4(6 downto 0) <= (std_ulogic_vector(counter_p4));
			counter_p4 <= (others => '1');
		else
			leds_p4(6 downto 0) <= (std_ulogic_vector(counter_p4));
			counter_p4 <= counter_p4 - 1;
		end if;
				else 
			--leds_p4 <= ("0000000");
		-- end if;
	      end if;
	end process pattern4;

	clock_gen_p4 : process (clk, rst)
		begin
		   if rst = '1' then
			cnt_p4 <= (others => '0');
		   elsif rising_edge(clk) then
			cnt_p4 <= cnt_p4 + 1;
			if (cnt_p4 = temp_clk_p4) then
			   clk_p4 <= not clk_p4;
			   cnt_p4 <= (others => '0');
			end if;
		   end if;
			if(prev_value_p4 /= temp_clk_p4) then
				cnt_p4 <= (others => '0');
				prev_value_p4 <= temp_clk_p4;
			end if;
	end process clock_gen_p4;

---- Pattern four End ------------------------------------------------------------------------------------------------

---- Pattern five start ----------------------------------------------------------------------------------------------
	
	pattern5 : process (clk_p5)
	   begin
	      if(rising_edge(clk_p5)) then
			-- if (clk_p5 = '1') then
				if (counter_p5 = "0001000") then
					leds_p5(6 downto 0) <= (std_ulogic_vector(counter_p5));
					counter_p5 <= counter_p5 + 57;
				elsif (counter_p5 = "1000001") then
					leds_p5(6 downto 0) <= (std_ulogic_vector(counter_p5));
					counter_p5 <= counter_p5 - 31;
				elsif (counter_p5 = "0100010") then
					leds_p5(6 downto 0) <= (std_ulogic_vector(counter_p5));
					counter_p5 <= counter_p5 - 14;
				elsif (counter_p5 = "0010100") then
					leds_p5(6 downto 0) <= (std_ulogic_vector(counter_p5));
					counter_p5 <= counter_p5 - 12;
				end if;
			--leds_p5 <= ("0000000");
		-- end if;
	   end if;
	end process pattern5;

	clock_gen_p5 : process (clk, rst)
		begin
		   if rst = '1' then
			cnt_p5 <= (others => '0');
		   elsif rising_edge(clk) then
			cnt_p5 <= cnt_p5 + 1;
			if (cnt_p5 = temp_clk_p5) then
			   clk_p5 <= not clk_p5;
			   cnt_p5 <= (others => '0');
			end if;
		   end if;
			if(prev_value_p5 /= temp_clk_p5) then
				cnt_p5 <= (others => '0');
				prev_value_p5 <= temp_clk_p5;
			end if;
	end process clock_gen_p5;

---- Pattern five End ------------------------------------------------------------------------------------------------

---- Transition state Start ------------------------------------------------------------------------------------------------
	transitionState : process (mux_select, clk)
	   begin
--			if(mux_select = "111") then
--				counter <= 0;
--			end if;
			if(rising_edge(clk)) then
				if (mux_select="111") then
			
				if(counter = COUNTER_LIMIT) then
					counter <= 0;
					done <= true;
				else 
					counter <= counter + 1;
					done <= false;
				end if;
				end if;
		end if;
	end process transitionState;

---- Transition state END ------------------------------------------------------------------------------------------------

----- Seventh bit start ------------------------------------------------------------------------------------

	seventhState : process (clk_b7)
	   begin
		if(rising_edge(clk_b7)) then
		-- if (clk_b7 = '1') then 
			led_7 <= not led_7;
		 else
			--led_7 <= '0';
		-- end if;
		end if;
	end process seventhState;


	clock_gen_b7 : process (clk, rst)
		begin
		   if rst = '1' then
			cnt_b7 <= (others => '0');
		   elsif rising_edge(clk) then
			cnt_b7 <= cnt_b7 + 1;
			if (cnt_b7 = temp_clk_b7) then
			   clk_b7 <= not clk_b7;
			   cnt_b7 <= (others => '0');
			end if;
		   end if;
			if(prev_value_p7 /= temp_clk_b7) then
				cnt_b7 <= (others => '0');
				prev_value_p7 <= temp_clk_b7;
			end if;
	end process clock_gen_b7;


----- Seventh bit end -------------------------------------------------------------------------------

	led_mux : process (clk)
	   begin
	      if (rising_edge(clk)) then
		if(mux_select = "000") then
		   led(6 downto 0) <= leds_p1;
		elsif (mux_select = "001") then
		   led(6 downto 0) <= leds_p2;
		elsif (mux_select = "010") then
		   led(6 downto 0) <= leds_p3;
		elsif (mux_select = "011") then
		   led(6 downto 0) <= leds_p4;
		elsif (mux_select = "100") then
		   led(6 downto 0) <= leds_p5;
		elsif (mux_select = "111") then
		   led(6 downto 0) <= "000" & switches;
			
		end if;

		led(7) <= led_7;
	      end if;
		--led <= leds;

	end process led_mux;
	
end architecture led_pattern_arch;