-- project: lab2 - switch & led with beep
-- file: beep_resolver.vhd
-- description:
--    resolves, which switch_led_beep_tester unit (1-4) beep request
--    to be processed (multiplexing)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity beep_resolver is
	port (
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		BM1_IN : in  STD_LOGIC_VECTOR (1 downto 0);
		BR1_IN : in  STD_LOGIC;
		BM2_IN : in  STD_LOGIC_VECTOR (1 downto 0);
		BR2_IN : in  STD_LOGIC;
		BM3_IN : in  STD_LOGIC_VECTOR (1 downto 0);
		BR3_IN : in  STD_LOGIC;
		BM4_IN : in  STD_LOGIC_VECTOR (1 downto 0);
		BR4_IN : in  STD_LOGIC;
		MODE_OUT : out  STD_LOGIC_VECTOR (1 downto 0);
		START_OUT : out  STD_LOGIC
	);
end beep_resolver;

architecture beep_resolver_arch of beep_resolver is
begin
	
	resolve_proc: process(CLK, RST) 
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				MODE_OUT <= "00";
				START_OUT <= '0';
			else 
				if BR1_IN = '1' then
					MODE_OUT <= BM1_IN;
					START_OUT <= BR1_IN;
				elsif BR2_IN = '1' then
					MODE_OUT <= BM2_IN;
					START_OUT <= BR2_IN;
				elsif BR3_IN = '1' then
					MODE_OUT <= BM3_IN;
					START_OUT <= BR3_IN;
				elsif BR4_IN = '1' then
					MODE_OUT <= BM4_IN;
					START_OUT <= BR4_IN;
				else 
					MODE_OUT <= "00";
					START_OUT <= '0';
				end if;
			end if; 
		end if; 
	end process;

end beep_resolver_arch;