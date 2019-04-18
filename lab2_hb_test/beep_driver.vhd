-------------------------------------------------------------------------------
-- Description : драйвер излучателя звука
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity beep_driver is
	generic (
		SND_MODE: std_logic := '1'; -- режим работы: "0" = константа, "1" = частота
		SB_PERIOD: integer := 10000000; -- количество периодов CLK для 200 мс (Fclk = 50 MHz)
		LB_PERIOD: integer := 50000000; -- количество периодов CLK для 1сек (Fclk = 50 MHz)
		SND_PERIOD: integer := 25000 -- количество периодов CLK для 0,5 мс (Fsnd = 2 kHz)
	);
	port(
		SB : in STD_LOGIC;
		LB : in STD_LOGIC;
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		BO : out STD_LOGIC
	);
end beep_driver;

architecture beep_driver_arch of beep_driver is
	signal beep_count: INTEGER range 0 to LB_PERIOD-1; -- счетчик периода времени вывода звука
	signal snd_count: INTEGER range 0 to SND_PERIOD-1; -- счетчик генератора звуковой частоты
	signal snd_wave: std_logic; -- звуковая частота 2 кГц
	signal beep_en: std_logic; -- разрешение для вывода звука
	type snd_state_type is (IDLE, SBEEP, LBEEP); -- состояния автомата звукогенератора
	signal snd_state: snd_state_type := IDLE; -- автомат звукогенератора
begin
	snd_gen: process(clk, rst)
	begin
		if rising_edge(clk) then
			if RST = '1' then
				snd_wave <= '0';
				snd_count <= 0;
			elsif snd_count = SND_PERIOD/2 then
				snd_wave <= not snd_wave;
				snd_count <= snd_count + 1;
			elsif snd_count = SND_PERIOD-1 then
				snd_wave <= '0';
				snd_count <= 0;
			else
				snd_count <= snd_count + 1;
			end if;
		end if;
	end process;
	
	snd_fsm: process(clk, rst)
	begin
		if rising_edge(clk) then
			if RST = '1' then
				snd_state <= IDLE;
				beep_en <= '0';
				beep_count <= 0;
			else
				case snd_state is
					when IDLE =>
						if LB = '1' then
							snd_state <= LBEEP;
							beep_en <= '1';
						elsif SB = '1' then
							snd_state <= SBEEP;
							beep_en <= '1';
						else
							snd_state <= IDLE;
							beep_en <= '0';
						end if;
					when SBEEP => 
						beep_count <= beep_count + 1;
						if beep_count = SB_PERIOD-1 then
							beep_count <= 0;
							beep_en <= '0';
							snd_state <= IDLE;
						end if;
					when LBEEP => 
						beep_count <= beep_count + 1;
						if beep_count = LB_PERIOD-1 then
							beep_count <= 0;
							beep_en <= '0';
							snd_state <= IDLE;
						end if;
					when others => 
						snd_state <= IDLE;
						beep_en <= '0';
						beep_count <= 0;
				end case;
			end if;
		end if;
	end process;
	
	BO <= snd_wave when beep_en = '1' and SND_MODE = '1' else
	      '1'      when beep_en = '1' and SND_MODE = '0' else
		  '0';

end beep_driver_arch;