-- project: lab1 - switch and led drivers
-- file: lab1_switch_led_tb.vhd
-- description:
--    testbench for functional verification of entire project

library IEEE;
use IEEE.std_logic_1164.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

entity lab1_switch_led_tb is
end lab1_switch_led_tb;

architecture behavior of lab1_switch_led_tb is 

	-- component declaration for the unit under test (uut)

	component lab1_switch_led
		generic (
			BOARD_CLK_FREQ : natural
		);
		port (
			CLK : in  std_logic;
			RST : in  std_logic;
			SWI : in  std_logic_vector(3 downto 0);
			LED : out std_logic_vector(3 downto 0)
		);
	end component;


	--inputs
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal swi : std_logic_vector(3 downto 0) := (others => '1');

	--outputs
	signal led : std_logic_vector(3 downto 0);

	-- clock period definitions
	constant clk_period : time := 20 ns;
	constant fake_freq : natural := 5000;

begin

	-- instantiate the unit under test (uut)
	uut: lab1_switch_led 
		generic map (
			BOARD_CLK_FREQ => fake_freq
		)
		port map (
			CLK => clk,
			RST => rst,
			SWI => swi,
			LED => led
		);

	-- clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
 

	-- stimulus process
	stim_proc: process
	begin
		rst <= '0';
		-- hold reset state for 100 ns
		wait for 100 ns;
		rst <= '1';
		wait for clk_period*10;
		
		-- imitate fast switch on KEY0 - turn LED0 on
		swi <= "1110";
		wait for 10 us;
		swi <= "1111";
		wait for 100 us;

		-- imitate fast switch on KEY0 - turn LED0 slow blink
		swi <= "1110";
		wait for 10 us;
		swi <= "1111";
		wait for 300 us;

		-- imitate fast switch on KEY0 - turn LED0 off
		swi <= "1110";
		wait for 10 us;
		swi <= "1111";
		wait for 100 us;

		-- imitate long switch on KEY0 - turn LED0 fast blink
		swi <= "1110";
		wait for 150 us;
		swi <= "1111";
		wait for 100 us;

		-- imitate fast switch on KEY0 - turn LED0 off
		swi <= "1110";
		wait for 10 us;
		swi <= "1111";
		wait for 100 us;

		wait;
	end process;

end;
