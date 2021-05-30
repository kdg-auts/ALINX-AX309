-- project: lab2 - switch & led with beep
-- file: lab2_beep_demo.vhd
-- description:
--    top-level module, combines 4 instances of switch_led_tester module
--    for each switch on dev board; each module forms independent control
--    group for apropriate switch-led couple

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab2_beep_demo is
	generic (
		BOARD_CLK_FREQ : natural := 50000000; -- CLK frequency in Hz
		SND_MODE: std_logic := '0' -- output generation mode: '0' = constant, '1' = waveform
	);
	port (
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		SWI : in  STD_LOGIC_VECTOR (3 downto 0);
		LED : out  STD_LOGIC_VECTOR (3 downto 0);
		BPO : out STD_LOGIC
	);
end lab2_beep_demo;

architecture lab2_beep_demo_arch of lab2_beep_demo is

	constant short_beep_period : natural := BOARD_CLK_FREQ/5; -- 200 ms
	constant long_beep_period : natural := BOARD_CLK_FREQ; -- 1 sec
	constant sound_freq_period : natural := BOARD_CLK_FREQ/2000; -- 0.5 ms (Fsnd = 2 kHz) 
	
	signal RST_sig : STD_LOGIC;
	signal SWI_sig : STD_LOGIC_VECTOR (3 downto 0);
	signal LED_sig : STD_LOGIC_VECTOR (3 downto 0);
	signal BEEP_MODE_U1_sig : STD_LOGIC_VECTOR (1 downto 0);
	signal BEEP_MODE_U2_sig : STD_LOGIC_VECTOR (1 downto 0);
	signal BEEP_MODE_U3_sig : STD_LOGIC_VECTOR (1 downto 0);
	signal BEEP_MODE_U4_sig : STD_LOGIC_VECTOR (1 downto 0);
	signal BEEP_RUN_U1_sig : STD_LOGIC;
	signal BEEP_RUN_U2_sig : STD_LOGIC;
	signal BEEP_RUN_U3_sig : STD_LOGIC;
	signal BEEP_RUN_U4_sig : STD_LOGIC;
	signal beep_mode_sig : STD_LOGIC_VECTOR (1 downto 0);
	signal beep_start_sig : STD_LOGIC;
	signal BPO_sig : STD_LOGIC;
begin

	unit1: entity work.switch_led_beep_tester(switch_led_beep_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(0),
		LED_OUT => LED_sig(0),
		BEEP_MODE => BEEP_MODE_U1_sig,
		BEEP_RUN => BEEP_RUN_U1_sig
	);

	unit2: entity work.switch_led_beep_tester(switch_led_beep_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(1),
		LED_OUT => LED_sig(1),
		BEEP_MODE => BEEP_MODE_U2_sig,
		BEEP_RUN => BEEP_RUN_U2_sig
	);

	unit3: entity work.switch_led_beep_tester(switch_led_beep_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(2),
		LED_OUT => LED_sig(2),
		BEEP_MODE => BEEP_MODE_U3_sig,
		BEEP_RUN => BEEP_RUN_U3_sig
	);

	unit4: entity work.switch_led_beep_tester(switch_led_beep_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(3),
		LED_OUT => LED_sig(3),
		BEEP_MODE => BEEP_MODE_U4_sig,
		BEEP_RUN => BEEP_RUN_U4_sig
	);

	beep_resolver: entity work.beep_resolver(beep_resolver_arch)
	port map (
		CLK => CLK,
		RST => RST_sig,
		BM1_IN => BEEP_MODE_U1_sig,
		BR1_IN => BEEP_RUN_U1_sig,
		BM2_IN => BEEP_MODE_U2_sig,
		BR2_IN => BEEP_RUN_U2_sig,
		BM3_IN => BEEP_MODE_U3_sig,
		BR3_IN => BEEP_RUN_U3_sig,
		BM4_IN => BEEP_MODE_U4_sig,
		BR4_IN => BEEP_RUN_U4_sig,
		MODE_OUT => beep_mode_sig,
		START_OUT => beep_start_sig
	);

	beep_drv: entity work.beep_driver(beep_driver_arch)
	generic map (
		SND_MODE => SND_MODE,
		SHB_PERIOD => short_beep_period,
		LOB_PERIOD => long_beep_period,
		SND_PERIOD => sound_freq_period
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		START => beep_start_sig,
		MODE => beep_mode_sig,
		BEEP => BPO_sig
	);

	-- input adaptation (positive or negative logic format depending on dev board schematic)
	-- switches/keys operate with negative logic (0 = press, 1 = release)
	RST_sig <= not RST;
	SWI_sig <= not SWI;
	-- LEDs operate with positive logic (0 = off, 1 = on)
	LED <= LED_sig;
	BPO <= not BPO_sig;

end lab2_beep_demo_arch;

