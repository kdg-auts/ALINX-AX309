-- project: lab3 - hexled demo
-- file: hexled_driver.vhd
-- description: 
--    6-digit 7-degment led display ("hexled") driver module (suitable for
--    part on AX309 evaluation board); contains a decoder for current digit
--    and counter to compute intervals between switching of digits and dot LED,
--    switching is performed by multiplexers; driver supports shift signal
--    to select HEX digits (shift=0) or special symbols (shift=1)
library IEEE;
use IEEE.std_logic_1164.all;

entity hexled_driver is
	generic (
		CNT_LIMIT: integer := 250000 -- number of CLK periods to form 5ms delay
	);
	port (
		CLK : in std_logic;
		RST : in std_logic;
		DT0 : in std_logic;
		DT1 : in std_logic;
		DT2 : in std_logic;
		DT3 : in std_logic;
		DT4 : in std_logic;
		DT5 : in std_logic;
		DDI0 : in std_logic_vector(4 downto 0);
		DDI1 : in std_logic_vector(4 downto 0);
		DDI2 : in std_logic_vector(4 downto 0);
		DDI3 : in std_logic_vector(4 downto 0);
		DDI4 : in std_logic_vector(4 downto 0);
		DDI5 : in std_logic_vector(4 downto 0);
		SEG_DAT : out std_logic_vector(7 downto 0);
		DIG_SEL : out std_logic_vector(5 downto 0)
	);
end hexled_driver;

architecture hexled_driver_arch of hexled_driver is
	signal active_ddi: std_logic_vector(3 downto 0) := (others => '0'); -- current data input to display
	signal active_shift: std_logic := '0'; -- shift value for current data
	signal active_digit: std_logic_vector(5 downto 0) := (0 => '1', others => '0'); -- active digit selector
	signal seg_display_counter: integer range 0 to CNT_LIMIT-1 := 0; -- display time interval
	signal shift_0_seg_data : std_logic_vector(6 downto 0) := (others => '0');
	signal shift_1_seg_data : std_logic_vector(6 downto 0) := (others => '0');
begin

	-- select data to display on current digit, split data and shift
	active_ddi <= DDI0(3 downto 0) when active_digit = "000001" else
	              DDI1(3 downto 0) when active_digit = "000010" else
	              DDI2(3 downto 0) when active_digit = "000100" else
	              DDI3(3 downto 0) when active_digit = "001000" else
	              DDI4(3 downto 0) when active_digit = "010000" else
	              DDI5(3 downto 0); -- when active_digit = "100000"
	
	active_shift <= DDI0(4) when active_digit = "000001" else
	                DDI1(4) when active_digit = "000010" else
	                DDI2(4) when active_digit = "000100" else
	                DDI3(4) when active_digit = "001000" else
	                DDI4(4) when active_digit = "010000" else
	                DDI5(4); -- when active_digit = "100000"
	
	-- digit decoder, split by shift value
	shift_0_seg_data <= "0111111" when active_ddi = x"0" else
	                    "0000110" when active_ddi = x"1" else
	                    "1011011" when active_ddi = x"2" else
	                    "1001111" when active_ddi = x"3" else
	                    "1100110" when active_ddi = x"4" else
	                    "1101101" when active_ddi = x"5" else
	                    "1111101" when active_ddi = x"6" else
	                    "0000111" when active_ddi = x"7" else
	                    "1111111" when active_ddi = x"8" else
	                    "1101111" when active_ddi = x"9" else
	                    "1110111" when active_ddi = x"A" else
	                    "1111100" when active_ddi = x"B" else
	                    "0111001" when active_ddi = x"C" else
	                    "1011110" when active_ddi = x"D" else
	                    "1111001" when active_ddi = x"E" else
	                    "1110001"; -- x"F"

	shift_1_seg_data <= "0000000" when active_ddi = "0000" else -- empty
	                    "0100000" when active_ddi = "0001" else -- seg F
	                    "0010000" when active_ddi = "0010" else -- seg E
	                    "0001000" when active_ddi = "0011" else -- seg D
	                    "0000100" when active_ddi = "0100" else -- seg C
	                    "0000010" when active_ddi = "0101" else -- seg B
	                    "0000001" when active_ddi = "0110" else -- seg A
	                    "1000000" when active_ddi = "0111" else -- seg G
	                    "1110110" when active_ddi = "1000" else -- "H"
	                    "0111000" when active_ddi = "1001" else -- "L"
	                    "0111110" when active_ddi = "1010" else -- "U"
	                    "0110111" when active_ddi = "1011" else -- "П" (upsidedown U)
	                    "1100011" when active_ddi = "1100" else -- sup o
	                    "1011100" when active_ddi = "1101" else -- sub o
	                    "1001001" when active_ddi = "1110" else -- 3 hor. bars
	                    "0110110"; -- "1111" -- 2 vert. bars (II)

	SEG_DAT(6 downto 0) <= shift_0_seg_data when active_shift = '0' else
	                       shift_1_seg_data;

	-- dot display selector
	SEG_DAT(7) <= DT0 when active_digit = "000001" else
	              DT1 when active_digit = "000010" else
	              DT2 when active_digit = "000100" else
	              DT3 when active_digit = "001000" else
	              DT4 when active_digit = "010000" else
	              DT5; -- when active_digit = "100000"
	
	-- active digit selector
	display_interval_counter: process(CLK, RST)
	begin 
		if rising_edge(CLK) then
			if RST = '1' then
				seg_display_counter <= 0;
				active_digit <= (0 => '1', others => '0'); 
			elsif seg_display_counter = CNT_LIMIT-1 then
				seg_display_counter <= 0;
				case active_digit is 
					when "100000"|"000000" => active_digit <= "000001";
					when others => active_digit <= active_digit(4 downto 0) & '0';
				end case;
			else
				seg_display_counter <= seg_display_counter + 1;
			end if;
		end if;
	end process;

	DIG_SEL <= active_digit;
	
end hexled_driver_arch;
