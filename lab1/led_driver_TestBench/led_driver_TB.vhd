library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity led_driver_tb is	
	generic (
		INTERVAL1s: integer := 500;
		INTERVAL100ms: integer :=50
		);
end led_driver_tb;

architecture led_driver_tb_arch of led_driver_tb is
	-- Component declaration of the tested unit
	component led_driver 
		generic (
		INTERVAL1s: integer := 50000000;
		INTERVAL100ms: integer :=5000000
		);
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		state : in STD_LOGIC;
		blink : in STD_LOGIC;
		led : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal rst : STD_LOGIC;
	signal state : STD_LOGIC;
	signal blink : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal led : STD_LOGIC;

	-- Add your code here ...
	constant clk_period : time := 20 ns; 

begin

	-- Unit Under Test port map
	UUT : led_driver 
	generic map (
		INTERVAL1s => INTERVAL1s,
		INTERVAL100ms => INTERVAL100ms
		)
		port map (
			clk => clk,
			rst => rst,
			state => state,
			blink => blink,
			led => led
		);

	-- Add your stimulus here ...
	CLK_Gen: process 
	begin
		
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
		
	end process;  
	
	
	rst_Gen: process 
	begin
		
		rst <= '1';
		wait for clk_period *2;
		rst <= '0';
		wait;
		
	end process;
	
	SW_Press_Gen: process 
	begin
		-- initial assignment
		state <= '0';
		blink <= '0'; 
		wait for 100 us;
		
		state <= '1';
		blink <= '0'; 
		wait for 100 us; 
		
		state <= '0';
		blink <= '1'; 
		wait for 100 us; 
		
		state <= '1';
		blink <= '1'; 
		wait;
		
		
		
	end process; 

end led_driver_tb_arch;

configuration TESTBENCH_FOR_led_driver of led_driver_tb is
	for led_driver_tb_arch
		for UUT : led_driver
			use entity work.led_driver(led_drv_arch);
		end for;
	end for;
end TESTBENCH_FOR_led_driver;

