-- project: lab4 - uart demo
-- file: baud_generator.vhd
-- description:
--    Module generates a sampling signal whose frequency is exactly 16 times
--    the UART`s designated baud rate. Output signal behaves like enable ticks
--    rather than the clock signal to the UART receiver.
--    BAUD_PERIOD is calculated as CLK_FREQ/(BAUD_RATE*16)
--    table of BAUD_PERIOD values for posible baud rates (for CLK_FREQ = 50 MHz):
--  BAUD RATE:   2400 | 4800 | 9600 | 14400 | 19200 | 28800 | 38400 | 57600 | 76800 | 115200 | 230400 | 250000 | 500000
--  BAUD_PERIOD: 1302 |  651 |  325 |   217 |   163 |   108 |    81 |    54 |    41 |     27 |     14 |     12 |      6

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;

entity baud_generator is 
	generic (
		BAUD_PERIOD : integer := 325 -- default baud rate is 9600
	);
	port( 
		CLK : in std_logic;
		RST : in std_logic;
		BDT : out std_logic
	);
end entity;

architecture baud_generator_arch of baud_generator is
	constant reg_width : integer := integer(ceil(log2(real(BAUD_PERIOD))));
	signal baud_reg : unsigned (reg_width-1 downto 0);
begin
	
	-- simple counter to generate baud ticks
	bd_gen: process (CLK, RST)
	begin
		if (RST = '1') then
			baud_reg <= (others => '0');
		elsif (CLK'event and CLK = '1') then 
			if baud_reg = BAUD_PERIOD-1 then
				baud_reg <= (others => '0');
			else
				baud_reg <= baud_reg + 1;
			end if;
		end if;
	end process;
	
	-- raise a tick on counter overflow
	BDT <= '1' when baud_reg = BAUD_PERIOD-1 else '0'; 

end architecture;
