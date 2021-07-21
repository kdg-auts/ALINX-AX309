-- project: lab3
-- file: beep_driver.vhd
-- description:
--    piezoelectric sound speaker driver; can operate with active and passive type of speaker
--    (determined with generic parameter); provides generation of 3 different signals:
--    short beep, long beep and double short beep

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity beep_driver is
	generic (
		SND_MODE: std_logic := '1'; -- output generation mode: '0' = constant, '1' = waveform
		SHB_PERIOD: natural := 10000000; -- number of CLK ticks for 200 ms (Fclk = 50 MHz)
		LOB_PERIOD: natural := 50000000; -- number of CLK ticks for 1 sec (Fclk = 50 MHz)
		SND_PERIOD: natural := 25000 -- number of CLK ticks for 0.5 ms (Fsnd = 2 kHz)
	);
	port (
		CLK : in std_logic;
		RST : in std_logic;
		START : in std_logic; -- start beeping
		MODE : in std_logic_vector(1 downto 0); -- type of signal
		BEEP : out std_logic -- sound signal output
	);
end entity;

architecture beep_driver_arch of beep_driver is
	signal beep_counter: natural range 0 to LOB_PERIOD-1; -- sound output time counter
	signal snd_counter: natural range 0 to SND_PERIOD-1; -- sound waveform generator counter
	signal snd_waveform: std_logic; -- signal for 2 kHz wave
	signal beep_en: std_logic; -- sound output enable signal
	type snd_state_type is (idle, short_beep, long_beep, double_beep); -- fsm states
	signal snd_state: snd_state_type := idle; -- fsm for generator
	signal db_stage_count: natural range 0 to 2 := 0; -- double beep stage counter
begin
	
	-- sound wave generation process
	snd_gen: process(CLK, RST)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				snd_waveform <= '0';
				snd_counter <= 0;
			elsif beep_en = '1' then -- waveform is generated only when needed
				if snd_counter = SND_PERIOD-1 then
					snd_waveform <= '0';
					snd_counter <= 0;
				else
					if snd_counter = SND_PERIOD/2-1 then
						snd_waveform <= not snd_waveform;
					end if;
					snd_counter <= snd_counter + 1;
				end if;
			else
				snd_waveform <= '0';
				snd_counter <= 0;
			end if;
		end if;
	end process;
	
	-- main fsm
	snd_fsm: process(CLK, RST)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				snd_state <= idle;
				beep_en <= '0';
				beep_counter <= 0;
				db_stage_count <= 0;
			else
				case snd_state is
					when idle =>
						if START = '1' then
							case MODE is
								when "01" => -- short beep
									snd_state <= short_beep;
									beep_en <= '1';
								when "10" => -- long beep
									snd_state <= long_beep;
									beep_en <= '1';
								when "11" => -- double beep
									snd_state <= double_beep;
									beep_en <= '1';
									db_stage_count <= 0;
								when others => -- off
							end case;
						end if;
					when short_beep => -- count short period of time
						beep_counter <= beep_counter + 1;
						if beep_counter = SHB_PERIOD-1 then
							beep_counter <= 0;
							beep_en <= '0';
							snd_state <= idle;
						end if;
					when long_beep => 
						beep_counter <= beep_counter + 1;
						if beep_counter = LOB_PERIOD-1 then
							beep_counter <= 0;
							beep_en <= '0';
							snd_state <= idle;
						end if;
					when double_beep =>
						if db_stage_count = 0 then -- first beep
							beep_counter <= beep_counter + 1;
							if beep_counter = SHB_PERIOD-1 then
								beep_counter <= 0;
								beep_en <= '0';
								db_stage_count <= 1;
							end if;
						elsif db_stage_count = 1 then -- pause between beeps
							beep_counter <= beep_counter + 1;
							if beep_counter = SHB_PERIOD-1 then
								beep_counter <= 0;
								beep_en <= '1';
								db_stage_count <= 2;
							end if;
						else -- second beep
							beep_counter <= beep_counter + 1;
							if beep_counter = SHB_PERIOD-1 then
								beep_counter <= 0;
								beep_en <= '0';
								db_stage_count <= 0;
								snd_state <= idle;
							end if;
						end if;
					when others => 
						snd_state <= idle;
						beep_en <= '0';
						beep_counter <= 0;
				end case;
			end if;
		end if;
	end process;
	
	BEEP <= snd_waveform when beep_en = '1' and SND_MODE = '1' else
	        '1'          when beep_en = '1' and SND_MODE = '0' else
	        '0';

end architecture;