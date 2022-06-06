-- project: lab3 - hexled demo
-- file: lab3_hexled_demo_tb.vhd
-- description:
--    testbench for functional verification of lab3_hexled_demo module

--!! TO DO: implement 7-segment value decoder

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity lab3_hexled_demo_tb is
end entity;

architecture lab3_hexled_demo_tb_arch of lab3_hexled_demo_tb is

	-- additional signals and parameters
	constant clk_period : time := 20 ns;
	constant virtual_clk_frq : natural := 4000; -- imitation of clk freq (is used to calculate all delay intervals)
    constant BTN_PRESS : std_logic := '0'; -- value imitates button pressing (due to inverse logic)
    constant BTN_RELEASE : std_logic := '1'; -- value imitates button release (due to inverse logic)
    constant BTN_HOLD_PERIOD : time := clk_period*100;
    constant BTN_BETW_PERIOD : time := clk_period*200;
	
	-- stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic;
	signal rst : std_logic;
	signal swi_test : std_logic_vector(3 downto 0) := (others => BTN_RELEASE);
	signal sw_prev, sw_next, sw_right, sw_left : std_logic := BTN_RELEASE;

	-- observed signals - signals mapped to the output ports of tested entity
	signal segment_data : std_logic_vector(7 downto 0);
	signal digit_select : std_logic_vector(5 downto 0);
	signal led_state : std_logic_vector(3 downto 0);
	signal beep_sound : std_logic;

begin

	-- Unit Under Test declaration, generic and port mapping
	UUT: entity work.lab3_hexled_demo(lab3_hexled_demo_arch)
	generic map (
		BOARD_CLK_FREQ => virtual_clk_frq,
		SND_MODE => '1' -- output generation mode: '0' = constant, '1' = waveform
	)
	port map (
		CLK => clk,
		RST => rst,
		SWI => swi_test,
		SEG => segment_data,
		DIG => digit_select,
		LDO => led_state,
		BPO => beep_sound
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

	swi_test <= (sw_prev, sw_next, sw_right, sw_left);

	-- test signal values generator
	stim_gen_proc: process
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
        wait for BTN_BETW_PERIOD;

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
        wait for BTN_BETW_PERIOD;

		-- position 1 value 31 - go to position 5 backwards (cause overflow)
		sw_right <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_right <= BTN_RELEASE;
		wait for BTN_BETW_PERIOD; -- position 0 value 31
		sw_right <= BTN_PRESS;
		wait for BTN_HOLD_PERIOD;
		sw_right <= BTN_RELEASE;
        wait for BTN_BETW_PERIOD;

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
        wait for BTN_BETW_PERIOD;

		wait; -- stop forever
	end process;

end architecture;