-------------------------------------------------------------------------------
-- Description : схема для тестирования работы драйвера 7-сегм. индикаторов 
--               и драйвера звуковых сигналов
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity hb_test_toplevel is
	generic (
		SND_MODE: std_logic := '1' -- режим работы: "0" = константа, "1" = частота
	);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		SEG : out STD_LOGIC_VECTOR(7 downto 0);
		DIG : out STD_LOGIC_VECTOR(3 downto 0);
		BO : out STD_LOGIC
	);
end hb_test_toplevel;

architecture hb_test_toplevel_arch of hb_test_toplevel is
	signal rst_s : STD_LOGIC;
	signal hex_s : STD_LOGIC_VECTOR(3 downto 0);
	signal dot_s : STD_LOGIC;
	signal sb_s, lb_s : STD_LOGIC;
	signal seg_out : STD_LOGIC_VECTOR(7 downto 0);
	signal dig_out : STD_LOGIC_VECTOR(3 downto 0);
	signal bo_out : STD_LOGIC;
begin
	
	-- out ports links
	SEG <= not seg_out;
	DIG <= not dig_out;
	BO  <= bo_out;
	rst_s <= not RST;
	
	HD_GEN: entity work.test_counter(test_counter_arch)
	port map (
		CLK => CLK,
		RST => rst_s,
		H   => hex_s,
		D   => dot_s,
		SB  => sb_s,
		LB  => lb_s
	);
	
	HEX_DRV: entity work.hexled_driver(hexled_driver_arch)
	port map (
		CLK => CLK,
		RST => rst_s,
		D1  => dot_s,
		D2  => dot_s,
		D3  => dot_s,
		D4  => dot_s,
		H1  => hex_s,
		H2  => hex_s,
		H3  => hex_s,
		H4  => hex_s,
		SEG => seg_out,
		DIG => dig_out
	);
	
	SND_DRV: entity work.beep_driver(beep_driver_arch)
	generic map (
		SND_MODE => SND_MODE
	)
	port map (
		CLK => CLK,
		RST => rst_s,
		SB => sb_s,
		LB => lb_s,
		BO => bo_out
	);
	
end architecture;