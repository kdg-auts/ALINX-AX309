-- project: lab2 - switch & led with beep
-- file: switch_led_beep_tester.vhd
-- description:
--    this module combines switch_driver and led_driver modules together 
--    into unified cell for one button and one LED; this module peforms 
--    different actions of led indications acording to different modes of 
--    pressing bound button; sound and indication modes are controlled 
--    by control_fsm

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity switch_led_beep_tester is
	generic (
		BOARD_CLK_FREQ : natural := 50 * 10**6 -- in Hz
	);
	port (
		CLK : in std_logic;
		RST : in std_logic;
		SW_IN : in std_logic; -- switch/key input
		LED_OUT : out std_logic; -- led output
		BEEP_MODE : out std_logic_vector(1 downto 0);
		BEEP_RUN : out std_logic
	);
end switch_led_beep_tester;

architecture switch_led_beep_tester_arch of switch_led_beep_tester is
	signal RIE_sig : std_logic;
	signal FAE_sig : std_logic;
	signal LPR_sig : std_logic;
	signal LED_MODE_sig : std_logic_vector(1 downto 0);
	signal LED_sig : std_logic;
	signal RST_sig : std_logic;
	signal BEEP_MODE_sig : std_logic_vector(1 downto 0);
	signal BEEP_RUN_sig : std_logic;

	constant interval_1sec : natural := BOARD_CLK_FREQ;
	constant interval_100ms : natural := BOARD_CLK_FREQ/10;
	constant interval_2ms : natural := BOARD_CLK_FREQ/500;

	component switch_driver
		generic (
			LPR_CP : natural;
			SWS_CP : natural;
			SW_ACT_ST : std_logic
		);
		port (
			CLK : in std_logic;
			RST : in std_logic;
			SWI : in std_logic;
			RIE : out std_logic;
			FAE : out std_logic;
			LVL : out std_logic;
			TGL : out std_logic;
			LPR : out std_logic
		);
	end component;

	component led_driver
		generic (
			TP_1S: natural;
			TP_100MS: natural
		);
		port (
			CLK : in std_logic;
			RST : in std_logic;
			MODE : in std_logic_vector(1 downto 0);
			LED : out std_logic
		);
	end component;

	component control_fsm
		port (
			CLK : in std_logic;
			RST	: in std_logic;
			RIE : in std_logic;
			FAE : in std_logic;
			LPR : in std_logic;
			LED_MODE : out std_logic_vector(1 downto 0);
			BEEP_MODE : out std_logic_vector(1 downto 0);
			BEEP_RUN : out std_logic
		);
	end component;

begin

	U1: switch_driver
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SW_IN,
			RIE => RIE_sig,
			FAE => FAE_sig,
			LVL => open,
			TGL => open,
			LPR => LPR_sig
		);

	U2: control_fsm
		port map (
			CLK => CLK,
			RST	=> RST_sig,
			RIE => RIE_sig,
			FAE => FAE_sig,
			LPR => LPR_sig,
			LED_MODE => LED_MODE_sig,
			BEEP_MODE => BEEP_MODE_sig,
			BEEP_RUN => BEEP_RUN_sig
		);

	U3: led_driver
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => LED_MODE_sig,
			LED => LED_sig
		);

	RST_sig <= RST;
	LED_OUT <= LED_sig;
	BEEP_MODE <= BEEP_MODE_sig;
	BEEP_RUN <= BEEP_RUN_sig;

end architecture switch_led_beep_tester_arch;
