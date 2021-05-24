-- project: lab1 - switch and led drivers
-- file: led_driver.vhd
-- description: single led driver module, contains 2 counters to form 2 waveforms with 
--              periods 1 sec and 100 ms; output is chosen by multiplexer between constant 0 (off), 
--              constant 1 (on), waveform 100 ms (fast blink) or waveform 1 s (slow blink)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity led_driver is
	generic (
		TP_1S: natural := 50000000; -- time period for 1 sec in clock periods (ticks)
		TP_100MS: natural := 5000000 -- time period for 100 ms in clock periods (ticks)
	);
	port (
		CLK : in std_logic;
		RST : in std_logic;
		MODE : in std_logic_vector(1 downto 0);
		LED : out std_logic
	);
end led_driver;

architecture led_drv_arch of led_driver is
	signal counter_1 : natural range 0 to TP_100MS-1;
	signal counter_2 : natural range 0 to TP_1S-1;
	signal wave_1sec : std_logic := '0';
	signal wave_100ms : std_logic := '0';
	
begin
	
	-- process for generation waveform with period 1 sec
	wform_1s_gen: process (CLK, rst)
	begin
		if CLK'event and CLK ='1' then
			if RST = '1' then
				counter_2 <= 0;
				wave_1sec <= '0';
			else
				if counter_2 = TP_1S/2-1 then -- first half period
					wave_1sec <= '1';
					counter_2 <= counter_2 + 1;
				elsif counter_2 = TP_1S-1 then -- second half period
					wave_1sec <= '0';
					counter_2 <= 0; 
				else
					counter_2 <= counter_2 + 1;
				end if;
			end if;
		end if;
	end process;
	
	-- process for generation waveform with period 100 ms
	-- (another description style for counter)
	wform_100ms_gen: process (CLK, RST)
	begin
		if CLK'event and CLK ='1' then
			if RST ='1' then
				wave_100ms <= '0';
				counter_1 <= 0;
			else
				if counter_1 = TP_100MS-1 then 
					wave_100ms <= '0';
					counter_1 <= 0;
				else
					if counter_1 = TP_100MS/2-1 then
						wave_100ms <= '1';
					end if;
					counter_1 <= counter_1 + 1;
				end if;
				
			end if;
		end if;
	end process;
	
	-- output generation multiplexer
	LED <= wave_100ms when MODE = "11" else
	       wave_1sec  when MODE = "10" else
	       '1'        when MODE = "01" else
	       '0'; -- MODE = "00"
	
end architecture led_drv_arch;
