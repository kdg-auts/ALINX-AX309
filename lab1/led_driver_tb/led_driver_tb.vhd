-- project: lab1 - switch and led drivers
-- file: led_driver_tb.vhd
-- description:
--    testbench for functional verification of led_driver module

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity led_driver_tb is
	generic (
		TP_1s_imitation: natural := 500;
		TP_100ms_imitation: natural := 50
		);
end led_driver_tb;

architecture led_driver_tb_arch of led_driver_tb is
	
	-- component declaration of the unit under test (UUT)
	component led_driver
		generic (
			TP_1S: natural;
			TP_100MS: natural
		);
		port (
			CLK : in std_logic;
			RST : in std_logic;
			MODE : in std_logic_vector(1 downto 0);
			LED : out std_logic
		);
	end component;

	-- stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic;
	signal rst : std_logic;
	signal mode : std_logic_vector(1 downto 0);

	-- observed signals - signals mapped to the output ports of tested entity
	signal led : std_logic;

	-- additional signals and parameters
	constant clk_period : time := 20 ns;

begin

	-- unit under test port map
	UUT : led_driver
		generic map (
			TP_1S => TP_1s_imitation,
			TP_100MS => TP_100ms_imitation
		)
		port map (
			CLK => clk,
			RST => rst,
			MODE => mode,
			LED => led
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

	sw_press_gen_proc: process
	begin
		mode <= "00";
		wait for 100 us;

		mode <= "01";
		wait for 100 us;

		mode <= "10";
		wait for 100 us;

		mode <= "11";
		wait for 100 us;

		mode <= "XX";
		wait;
	end process;

end led_driver_tb_arch;

configuration led_driver_tb_conf of led_driver_tb is
	for led_driver_tb_arch
		for UUT : led_driver
			use entity work.led_driver(led_drv_arch);
		end for;
	end for;
end led_driver_tb_conf;

