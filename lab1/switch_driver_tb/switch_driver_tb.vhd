-- project: lab1 - switch and led drivers
-- file: switch_driver_tb.vhd
-- description:
--    testbench for functional verification of switch_driver module

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity switch_driver_tb is
	generic (
		LP_COUNT_PERIOD : natural := 500;
		SWS_COUNT_PERIOD : natural := 10
	);
end switch_driver_tb;

architecture switch_driver_tb_arch of switch_driver_tb is
	-- component declaration of the unit under test (UUT)
	component switch_driver
		generic (
			LPR_CP : natural;
			SWS_CP : natural;
			SW_ACT_ST : std_logic
		);
		port (
			CLK : in std_logic;
			RST : in std_logic;
			SWI : in std_logic;
			RIE : out std_logic;
			FAE : out std_logic;
			LVL : out std_logic;
			TGL : out std_logic;
			LPR : out std_logic
		);
	end component;

	-- stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal rst : STD_LOGIC;
	signal swi : STD_LOGIC;
	-- observed signals - signals mapped to the output ports of tested entity
	signal rie : STD_LOGIC;
	signal fae : STD_LOGIC;
	signal lvl : STD_LOGIC;
	signal tgl : STD_LOGIC;
	signal lpr : STD_LOGIC;

	-- additional signals and parameters
	constant clk_period : time := 20 ns;

begin

	-- unit under test port map
	UUT : switch_driver
		generic map (
			LPR_CP => LP_COUNT_PERIOD,
			SWS_CP => SWS_COUNT_PERIOD,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => clk,
			RST => rst,
			SWI => swi,
			RIE => rie,
			FAE => fae,
			LVL => lvl,
			TGL => tgl,
			LPR => lpr
		);

	clk_gen_proc: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;


	rst_gen_proc: process
	begin
		rst <= '1';
		wait for clk_period*2;
		rst <= '0';
		wait;
	end process;

	switch_behavior_proc: process
	begin
		swi <= '0';
		wait until rst = '0';
		wait for clk_period * 50; -- pause before press

		-- pressing button - imitating bounce untill is constantly ON
		-- ** task 1: rewrite bounce section using customized random intervals (random pkg)
		swi <= '1';
		wait for 1500 ns;
		swi <= '0';
		wait for 10 us;

		swi <= '1';
		wait for 3 us;
		swi <= '0';
		wait for 8 us;

		swi <= '1';
		wait for 3500 ns;
		swi <= '0';
		wait for 7 us;

		swi <= '1';
		wait for 5 us;
		swi <= '0';
		wait for 5 us;

		swi <= '1';
		wait for 1 ms; -- wery long
		-- button is finally pressed - wait for long time

		-- releasing button - imitating bounce untill is constantly OFF
		-- ** task 2: rewrite bounce section using customized random intervals (random pkg)
		sw <= '0';
		wait for 5 us;
		sw <= '1';
		wait for 5 us;

		sw <= '0';
		wait for 7 us;
		sw <= '1';
		wait for 3500 ns;

		sw <= '0';
		wait for 10 us;
		sw <= '1';
		wait for 1500 ns;

		sw <= '0';
		wait for 7 us; -- wery long
		-- button is finally released - wait for long time

		-- ** task 3: add test cases to verify fast press and long press modes corectness
		-- end of simulation
		wait;

	end process;

end switch_driver_tb_arch;

configuration switch_driver_tb_conf of switch_driver_tb is
	for switch_driver_tb_arch
		for UUT : switch_driver
			use entity work.switch_driver(switch_drv_arch);
		end for;
	end for;
end switch_driver_tb_conf;

