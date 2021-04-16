-- project: lab2 - beep, switch and led drivers
-- file: beep_driver_tb.vhd
-- description:
--    testbench for functional verification of beep_driver module

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity beep_driver_tb is
end entity;

architecture beep_driver_tb_arch of beep_driver_tb is

	-- additional signals and parameters
	constant clk_period : time := 20 ns;
	constant snd_mode : std_logic := '1'; -- output generation mode: '0' = constant, '1' = waveform
	constant shb_period : natural := 1000; -- imitation of 200 ms interval (redused by 10000 times)
	constant lob_period: natural := 5000; -- imitation of 1 sec interval
	constant snd_period: natural := 2; -- imitation of 2.5 ms interval
	type mode_set_arr is array (0 to 3) of std_logic_vector(1 downto 0);
	constant mode_set: mode_set_arr := ("00", "01", "10", "11"); -- (off, short, long, double) 
	
	-- stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic;
	signal rst : std_logic;
	signal start : std_logic;
	signal mode : std_logic_vector(1 downto 0) := (others => '0');

	-- observed signals - signals mapped to the output ports of tested entity
	signal sound : std_logic;

begin

	-- Unit Under Test declaration, generic and port mapping
	UUT : entity work.beep_driver(beep_driver_arch)
		generic map (
			SND_MODE => snd_mode,
			SHB_PERIOD => shb_period,
			LOB_PERIOD => lob_period,
			SND_PERIOD => snd_period
		)
		port map (
			CLK => clk,
			RST => rst,
			MODE => mode,
			START => start,
			BEEP => sound
		);

	-- clock waveform generator
	clk_gen_proc: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- reset signal generator
	rst_gen_proc: process
	begin
		rst <= '1';
		wait for clk_period*2;
		rst <= '0';
		wait;
	end process;

	-- test signal values generator
	sw_press_gen_proc: process
	begin
		wait until rst = '0'; -- 1) work only after reset
		for i in 0 to 3 loop  -- 2) try all modes of beep_driver operation
			mode <= mode_set(i);
			start <= '1';
			wait for clk_period;
			start <= '0';
			wait for 120 us;
		end loop;
		wait;                 -- 3) stop forever
	end process;

end architecture;

