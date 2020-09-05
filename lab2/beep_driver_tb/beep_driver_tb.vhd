-- project: lab2 - beep, switch and led drivers
-- file: beep_driver_tb.vhd
-- description:
--    testbench for functional verification of beep_driver module

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity beep_driver_tb is
	generic (
		SND_MODE: std_logic := '1'; -- output generation mode: '0' = constant, '1' = waveform
		SHB_PERIOD: natural := 10000000; -- number of CLK ticks for 200 ms (Fclk = 50 MHz)
		LOB_PERIOD: natural := 50000000; -- number of CLK ticks for 1 sec (Fclk = 50 MHz)
		SND_PERIOD: natural := 25000
		);
end entity;

architecture beep_driver_tb_arch of beep_driver_tb is

	-- additional signals and parameters
	constant clk_period : time := 20 ns;
	constant snd_mode : std_logic := '1'; -- output generation mode: '0' = constant, '1' = waveform
	constant shb_period : natural := 1000; -- imitation of 200 ms interval (redused by 10000 times)
	constant lob_period: natural := 5000; -- imitation of 1 sec interval
	constant snd_period: natural := 2; -- imitation of 2.5 ms interval
	
	-- stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic;
	signal rst : std_logic;
	signal mode : std_logic_vector(1 downto 0);

	-- observed signals - signals mapped to the output ports of tested entity
	signal led : std_logic;

begin

	-- unit under test declaration and port map
	UUT : entity work.beep_driver
		generic map (
			SND_MODE => '1', -- output generation mode: '0' = constant, '1' = waveform
			SHB_PERIOD => 1000,
			LOB_PERIOD => 5000,
			SND_PERIOD => 2
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

end architecture;

configuration beep_driver_tb_conf of beep_driver_tb is
	for beep_driver_tb_arch
		for UUT : beep_driver
			use entity work.beep_driver(beep_drv_arch);
		end for;
	end for;
end beep_driver_tb_conf;

