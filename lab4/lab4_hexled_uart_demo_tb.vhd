-- project: lab4 - hexled with uart demo
-- file: lab4_hexled_uart_demo_tb.vhd
-- description:
--    testbench for functional verification of lab4_hexled_uart_demo module

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity lab4_hexled_uart_demo_tb is
end entity;

architecture lab4_hexled_uart_demo_tb_arch of lab4_hexled_uart_demo_tb is

	-- additional signals and parameters
	constant clk_period : time := 20 ns;
	constant virtual_clk_frq : natural := 50000; -- imitation of clk freq (is used to calculate all delay intervals)
    constant BTN_PRESS : std_logic := '0'; -- value imitates button pressing (due to inverse logic)
    constant BTN_RELEASE : std_logic := '1'; -- value imitates button release (due to inverse logic)
    constant BTN_HOLD_PERIOD : time := clk_period*800; -- not less than 14 000 ns
    constant BTN_BETW_PERIOD : time := clk_period*1400; -- not less than 24 000 ns
	signal hexdigit : string(1 to 3) := "   ";
	type hexdisplay_type is array(0 to 5) of string(1 to 3);
	signal hexdisplay : hexdisplay_type := (others => (others => 'X'));
	signal transmit_data_reg : std_logic_vector(7 downto 0) := (others => '0');
	
	-- stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic;
	signal rst : std_logic;
	signal rx_input : std_logic := '1';	-- default line state for UART
	signal swi_test : std_logic_vector(3 downto 0) := (others => BTN_RELEASE); 
	--signal sw_prev, sw_next, sw_right, sw_left : std_logic := BTN_RELEASE;
	alias sw_prev : std_logic is swi_test(3);
	alias sw_next : std_logic is swi_test(2);
	alias sw_right : std_logic is swi_test(1);
	alias sw_left : std_logic is swi_test(0);

	-- observed signals - signals mapped to the output ports of tested entity
	signal segment_data : std_logic_vector(7 downto 0);
	signal digit_select : std_logic_vector(5 downto 0);
	signal led_state : std_logic_vector(3 downto 0);
	signal beep_sound : std_logic;
	signal tx_output : std_logic;

begin

	-- Unit Under Test declaration, generic and port mapping
	UUT: entity work.lab4_hexled_uart_demo(lab4_hexled_uart_demo_arch)
	generic map (
		BOARD_CLK_FREQ => virtual_clk_frq,
		SND_MODE => '1', -- output generation mode: '0' = constant, '1' = waveform 
		BAUD_PERIOD => 2 -- reduced due to simulation purposes (2 CLK periods)
	)
	port map (
		CLK => clk,
		RST => rst,
		SWI => swi_test,
		SEG => segment_data,
		DIG => digit_select,
		LDO => led_state,
		BPO => beep_sound,
		RXI => rx_input,
		TXO => tx_output
	);

	-- clock waveform generator
	clk_gen_proc: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- reset signal generator
	rst_gen_proc: process
	begin
		rst <= '0';
		wait for clk_period*2;
		rst <= '1';
		wait;
	end process;

	--swi_test <= (sw_prev, sw_next, sw_right, sw_left);

	-- imitating external UART entity
	rx_driver: process
		function get_data(r1, r2: real) return std_logic_vector is
			variable pos, code : integer;
		begin
			--report "random nums: " & real'image(rand1) & " " & real'image(rand2);
			pos := integer(trunc(r1*6.0));
			code := integer(trunc(r2*32.0));
			return std_logic_vector(to_unsigned(pos, 3)) & std_logic_vector(to_unsigned(code, 5));
		end function;
		variable seed1, seed2 : positive;
		variable rand1, rand2 : real;
		constant BAUD_BIT_LENGTH : time := 640 ns;
		constant TX_PAUSE : time := 12 us;
	begin
		wait until rst = '1'; -- work only after reset
		wait for 10 us;
		-- first tight transmitting states at the beginning
		for k in 0 to 5 loop
			uniform(seed1, seed2, rand1);
			uniform(seed1, seed2, rand2);
			transmit_data_reg <= get_data(rand1, rand2);
			-- begin transmitting
			rx_input <= '0';
			wait for BAUD_BIT_LENGTH;
			for i in 0 to transmit_data_reg'high loop
				rx_input <= transmit_data_reg(i);
				wait for BAUD_BIT_LENGTH;
			end loop;
			rx_input <= '1';
			wait for BAUD_BIT_LENGTH;
			wait for TX_PAUSE;
		end loop;
		-- second sparce transmitting during all test period
		for k in 0 to 5 loop
			wait for TX_PAUSE*30;
			uniform(seed1, seed2, rand1);
			uniform(seed1, seed2, rand2);
			transmit_data_reg <= get_data(rand1, rand2);
			-- begin transmitting
			rx_input <= '0';
			wait for BAUD_BIT_LENGTH;
			for i in 0 to transmit_data_reg'high loop
				rx_input <= transmit_data_reg(i);
				wait for BAUD_BIT_LENGTH;
			end loop;
			rx_input <= '1';
			wait for BAUD_BIT_LENGTH;
			
		end loop;
	end process;	
	
	-- imitating button pressing
	button_press_proc: process
	begin
		wait until rst = '1'; -- work only after reset
        wait for BTN_BETW_PERIOD;
		
		-- position 0 value 0 - increment value once
		sw_next <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_next <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD;

		-- position 0 value 1 - decrement value twice (cause owerflow to value 31)
		sw_prev <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_prev <= BTN_RELEASE;
		wait for BTN_BETW_PERIOD;
		sw_prev <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_prev <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD*20;

		-- position 0 value 31 - go to position 1
		sw_left <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_left <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD;

		-- position 1 value 0 - increment value once
		sw_next <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_next <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD;

		-- position 1 value 1 - decrement value twice (cause overflow to value 31)
		sw_prev <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_prev <= BTN_RELEASE;
		wait for BTN_BETW_PERIOD;
		sw_prev <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_prev <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD*20;

		-- position 1 value 31 - go to position 5 backwards (cause overflow)
		sw_right <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_right <= BTN_RELEASE;
		wait for BTN_BETW_PERIOD; -- position 0 value 31
		sw_right <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_right <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD*20;

		-- position 5 value 0 - increment value once
		sw_next <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_next <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD;

		-- position 5 value 1 - decrement value twice (cause overflow to value 31)
		sw_prev <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_prev <= BTN_RELEASE;
		wait for BTN_BETW_PERIOD;
		sw_prev <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_prev <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD*20;

		wait; -- stop forever
	end process;
	
	-- hexdisplay 
	hexdigit_decoder1: hexdigit(1 to 2) <= 
		" 0" when segment_data(6 downto 0) = "1000000" else	
		" 1" when segment_data(6 downto 0) = "1111001" else
		" 2" when segment_data(6 downto 0) = "0100100" else	
		" 3" when segment_data(6 downto 0) = "0110000" else	
		" 4" when segment_data(6 downto 0) = "0011001" else	
		" 5" when segment_data(6 downto 0) = "0010010" else	
		" 6" when segment_data(6 downto 0) = "0000010" else	
		" 7" when segment_data(6 downto 0) = "1111000" else
		" 8" when segment_data(6 downto 0) = "0000000" else
		" 9" when segment_data(6 downto 0) = "0010000" else	
		" A" when segment_data(6 downto 0) = "0001000" else	
		" b" when segment_data(6 downto 0) = "0000011" else	
		" C" when segment_data(6 downto 0) = "1000110" else	
		" d" when segment_data(6 downto 0) = "0100001" else	 
		" E" when segment_data(6 downto 0) = "0000110" else	
		" F" when segment_data(6 downto 0) = "0001110" else	
		"^ " when segment_data(6 downto 0) = "1111111" else	-- empty      
		"^f" when segment_data(6 downto 0) = "1011111" else	-- seg F      
		"^e" when segment_data(6 downto 0) = "1101111" else	-- seg E      
		"^d" when segment_data(6 downto 0) = "1110111" else	-- seg D      
		"^c" when segment_data(6 downto 0) = "1111011" else	-- seg C      
		"^b" when segment_data(6 downto 0) = "1111101" else	-- seg B      
		"^a" when segment_data(6 downto 0) = "1111110" else	-- seg A      
		"^g" when segment_data(6 downto 0) = "0111111" else	-- seg G      
		"^H" when segment_data(6 downto 0) = "0001001" else	-- "H"        
		"^L" when segment_data(6 downto 0) = "1000111" else	-- "L"        
		"^U" when segment_data(6 downto 0) = "1000001" else	-- "U"        
		"^P" when segment_data(6 downto 0) = "1001000" else	-- "cyr P"       
		"^°" when segment_data(6 downto 0) = "0011100" else	-- sup o      
		"^o" when segment_data(6 downto 0) = "0100011" else	-- sub o      
		"^=" when segment_data(6 downto 0) = "0110110" else	-- 3 hor. bars 
		"^|" when segment_data(6 downto 0) = "1001001" else -- "1111" -- 2 vert. bars (II) 
		"XX";	
	hexdigit_decoder2: hexdigit(3) <= 
	    ' ' when segment_data(7) = '1' else
		'.' when segment_data(7) = '0' else	
		'X';
		
	hexdisplay_refresh: process(digit_select)
	begin
		if rising_edge(digit_select(0)) and hexdisplay(0) /= hexdigit then
			hexdisplay(0) <= hexdigit;
		end if;
		if rising_edge(digit_select(1)) and hexdisplay(1) /= hexdigit then
			hexdisplay(1) <= hexdigit;
		end if;
		if rising_edge(digit_select(2)) and hexdisplay(2) /= hexdigit then
			hexdisplay(2) <= hexdigit;
		end if;
		if rising_edge(digit_select(3)) and hexdisplay(3) /= hexdigit then
			hexdisplay(3) <= hexdigit;
		end if;
		if rising_edge(digit_select(4)) and hexdisplay(4) /= hexdigit then
			hexdisplay(4) <= hexdigit;
		end if;
		if rising_edge(digit_select(5)) and hexdisplay(5) /= hexdigit then
			hexdisplay(5) <= hexdigit;
		end if;

	end process;

end architecture;