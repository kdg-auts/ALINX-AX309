-- project: lab1 - switch and led drivers
-- file: switch_led_tester.vhd
-- description:
--    top-level module, combines 4 instances of switch_led_tester module
--    for each switch on dev board; each module forms independent control
--    group for apropriate switch-led couple

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab1_switch_led is
	generic (
		BOARD_CLK_FREQ : natural := 50000000 -- in Hz
	);
	port (
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		SWI : in  STD_LOGIC_VECTOR (3 downto 0);
		LED : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end lab1_switch_led;

architecture lab1_switch_led_arch of lab1_switch_led is

	signal SWI_sig: STD_LOGIC_VECTOR (3 downto 0);
	signal LED_sig: STD_LOGIC_VECTOR (3 downto 0);
	signal RST_sig: STD_LOGIC;
begin

U1: entity work.switch_led_tester(switch_led_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(0),
		LED_OUT => LED_sig(0)
	);

U2: entity work.switch_led_tester(switch_led_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(1),
		LED_OUT => LED_sig(1)
	);

U3: entity work.switch_led_tester(switch_led_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(2),
		LED_OUT => LED_sig(2)
	);

U4: entity work.switch_led_tester(switch_led_tester_arch)
	generic map (
		BOARD_CLK_FREQ => BOARD_CLK_FREQ
	)
	port map (
		CLK => CLK,
		RST => RST_sig,
		SW_IN => SWI_sig(3),
		LED_OUT => LED_sig(3)
	);

	-- input adaptation (positive or negative logic format depending on dev board schematic)
	-- switches/keys operate with negative logic (0 = press, 1 = release)
	rst_sig <= not RST;
	SWI_sig <= not SWI;
	-- LEDs operate with positive logic (0 = off, 1 = on)
	LED <= LED_sig;

end lab1_switch_led_arch;

