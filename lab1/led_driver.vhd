library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity led_driver is
	
	generic (
		INTERVAL1s: integer := 50000000;
		INTERVAL100ms: integer :=5000000
		);
	
	port (
		clk : in std_logic;
		rst	: in std_logic;
		state : in std_logic;
		blink : in std_logic;
		led	: out std_logic
		);
end led_driver;	 

architecture led_drv_arch of led_driver is
	signal counter1 : integer range 0 to INTERVAL100ms-1;
	signal counter2 : integer range 0 to INTERVAL1s-1;
	signal wave1s, wave100ms : std_logic := '0';
	
begin
	
	w1s_gen: process (clk, rst)
	begin
		if clk'event and clk ='1' then
			if rst ='1' then
				counter2<=0;
				wave1s <= '0';
			else
				if counter2 = INTERVAL1s/2-1 then
					wave1s <= '1';
					counter2 <= counter2 + 1;
				elsif counter2 = INTERVAL1s-1 then 
					wave1s <= '0';
					counter2 <= 0; 
				else
					counter2 <= counter2 + 1;
				end if;
			end if;
		end if; 
	end process;	
	
	w100ms_gen: process (clk, rst)
	begin
		if clk'event and clk ='1' then
			if rst ='1' then
				counter1<=0;
				wave100ms <= '0';
			else
				if counter1 = INTERVAL100ms/2-1 then
					wave100ms <= '1';
					counter1 <= counter1 + 1;
				elsif counter1 = INTERVAL100ms-1 then 
					wave100ms <= '0';
					counter1 <= 0; 
				else
					counter1 <= counter1 + 1;
				end if;
			end if;
		end if; 
	end process;
	
	led <= wave1s when state = '1' and blink = '1' else
	wave100ms when state = '0' and blink = '1' else	
	'1' when state = '1' and blink = '0' else
	'0'; -- state = '0' and blink = '0'
	
end architecture led_drv_arch;
