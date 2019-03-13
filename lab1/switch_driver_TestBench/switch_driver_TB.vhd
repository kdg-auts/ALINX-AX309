library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

-- Add your library and packages declaration here ...

entity switch_driver_tb is
	-- Generic declarations of the tested unit
	generic(
		LP_COUNT_PERIOD : INTEGER := 500;
		SWS_COUNT_PERIOD : INTEGER := 10 );
end switch_driver_tb;

architecture switch_driver_tb_arch of switch_driver_tb is
	-- Component declaration of the tested unit
	component switch_driver
		generic(
			LP_COUNT_PERIOD : INTEGER := 50000000;
			SWS_COUNT_PERIOD : INTEGER := 100000 );
		port(
			clk : in STD_LOGIC;
			rst : in STD_LOGIC;
			sw : in STD_LOGIC;
			Redge : out STD_LOGIC;
			Fedge : out STD_LOGIC;
			LVL : out STD_LOGIC;
			Toggle : out STD_LOGIC;
			LPress : out STD_LOGIC );
	end component;
	
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal rst : STD_LOGIC;
	signal sw : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Redge : STD_LOGIC;
	signal Fedge : STD_LOGIC;
	signal LVL : STD_LOGIC;
	signal Toggle : STD_LOGIC;
	signal LPress : STD_LOGIC;
	
	-- Add your code here ... 
	
	constant clk_period : time := 20 ns; 
	
begin
	
	-- Unit Under Test port map
	UUT : switch_driver
	generic map (
		LP_COUNT_PERIOD => LP_COUNT_PERIOD,
		SWS_COUNT_PERIOD => SWS_COUNT_PERIOD
		)
	
	port map (
		clk => clk,
		rst => rst,
		sw => sw,
		Redge => Redge,
		Fedge => Fedge,
		LVL => LVL,
		Toggle => Toggle,
		LPress => LPress
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
		sw <= '0';
		wait until rst = '0';
		wait for clk_period * 50; -- pause before press
		
		-- pressing button - bounce untill is ON
		sw <= '1';
		wait for 1500 ns;
		sw <= '0';
		wait for 10 us;
		
		sw <= '1';
		wait for 3000 ns;
		sw <= '0';
		wait for 8 us;
		
		sw <= '1';
		wait for 3500 ns;
		sw <= '0';
		wait for 7 us;
		
		sw <= '1';
		wait for 5000 ns;
		sw <= '0';
		wait for 5 us;
		
		sw <= '1';
		wait for 1 ms; -- wery long 
		-- button is finally pressed - wait for long time
		
		-- releassing button - bounce untill is OFF
		sw <= '0';
		wait for 5 us;	
		sw <= '1';
		wait for 5000 ns; 
		
		sw <= '0';
		wait for 7 us;	
		sw <= '1';
		wait for 3500 ns;
		
		sw <= '0';
		wait for 10 us;	
		sw <= '1';
		wait for 1500 ns;
		
		sw <= '0';
		wait for 7 us;	-- wery long 
		-- button is finally released - wait for long time
		
		wait;	  
		
		
		
	end process; 
	
end switch_driver_tb_arch;

configuration TESTBENCH_FOR_switch_driver of switch_driver_tb is
	for switch_driver_tb_arch
		for UUT : switch_driver
			use entity work.switch_driver(switch_drv_arch);
		end for;
	end for;
end TESTBENCH_FOR_switch_driver;

