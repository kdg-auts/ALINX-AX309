-------------------------------------------------------------------------------
-- File        : HEXLed_driver.vhd
-- Generated   : Thu Apr  4 11:27:20 2019
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
-------------------------------------------------------------------------------
-- Description : драйвер 7-сегм. индикатора на 4 символа
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity HEXLed_driver is
	generic (
		CNT_LIMIT: integer := 1000000 -- число периодов CLK для формирования задержки в 20мс
	);
	port(
		D1 : in STD_LOGIC;
		D2 : in STD_LOGIC;
		D3 : in STD_LOGIC;
		D4 : in STD_LOGIC;
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		H1 : in STD_LOGIC_VECTOR(3 downto 0);
		H2 : in STD_LOGIC_VECTOR(3 downto 0);
		H3 : in STD_LOGIC_VECTOR(3 downto 0);
		H4 : in STD_LOGIC_VECTOR(3 downto 0);
		SEG : out STD_LOGIC_VECTOR(7 downto 0);
		DIG : out STD_LOGIC_VECTOR(3 downto 0)
	);
end HEXLed_driver;

architecture HEXLed_driver_arch of HEXLed_driver is
	signal active_hex: STD_LOGIC_VECTOR(3 downto 0); 
	signal CS: STD_LOGIC_VECTOR(1 downto 0);
	signal TSEG_count: INTEGER range 0 to CNT_LIMIT-1; 
begin

	active_hex <= H1 when CS = "00" else  
				  H2 when CS = "01" else
				  H3 when CS = "10" else
				  H4; -- when CS = "11"; 
				  
	SEG(6 downto 0)	<=	"0111111"  when active_hex = x"0" else  
						"0000110"  when active_hex = x"1" else
				 		"1011011"  when active_hex = x"2" else
				 		"1001111"  when active_hex = x"3" else
				 		"1100110"  when active_hex = x"4" else
				 		"1101101"  when active_hex = x"5" else
						"1111101"  when active_hex = x"6" else
						"0000111"  when active_hex = x"7" else
						"1111111"  when active_hex = x"8" else
						"1101111"  when active_hex = x"9" else
						"0100011"  when active_hex = x"A" else
						"0011100"  when active_hex = x"B" else	
						"0000000";
						
	SEG(7) <=     D1 when CS = "00" else  
				  D2 when CS = "01" else
				  D3 when CS = "10" else
				  D4; -- when CS = "11";  	
	
	DIG <= "0001" when CS = "00" else
		   "0010" when CS = "01" else
		   "0100" when CS = "10" else
		   "1000";
	
	timer: process(CLK, RST)
	begin 
		if rising_edge(CLK) then 
			if RST = '1' then 
				TSEG_count <= 0;
				CS <= "00"; 
			elsif TSEG_count = CNT_LIMIT-1 then
				TSEG_count <= 0;
				case CS is 
					when "00" => CS <= "01";
					when "01" => CS <= "10";
					when "10" => CS <= "11";
					when others => CS <= "00"; -- when "11"
				end case; 
			else 
				TSEG_count <= TSEG_count + 1;
			end if;
		end if;
	end process;
	
end HEXLed_driver_arch;
