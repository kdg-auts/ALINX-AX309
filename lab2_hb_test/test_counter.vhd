-------------------------------------------------------------------------------
-- Description : счетчик для тестирования работы драйвера 7-сегм. индикаторов 
--               и драйвера звуковых сигналов
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity test_counter is
	generic (
		H_PERIOD: integer := 50000000
	);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		H : out STD_LOGIC_VECTOR(3 downto 0);
		D : out STD_LOGIC;
		SB : out STD_LOGIC;
		LB : out STD_LOGIC
	);
end test_counter;

architecture test_counter_arch of test_counter is
	signal h_count: INTEGER range 0 to H_PERIOD-1;
	signal h_value: std_logic_vector(3 downto 0) := (others => '0');
begin
	process(CLK, RST)
	begin
		if rising_edge(CLK) then 
			if RST = '1' then 
				h_count <= 0;
				h_value <= (others => '0');
				LB <= '0';
				SB <= '0';
			elsif h_count = H_PERIOD-1 then
				h_count <= 0;
				h_value <= h_value + 1;
				if h_value = "1111" then
					LB <= '1';
					SB <= '0';
				else
					LB <= '0';
					SB <= '1';
				end if;
			else 
				h_count <= h_count + 1;
				LB <= '0';
				SB <= '0';
			end if;
		end if;
	end process;
	
	H <= h_value;
	D <= h_value(0);
	
end architecture;