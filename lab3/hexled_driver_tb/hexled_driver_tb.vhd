-- project: lab3 - hexled demo
-- file: hexled_driver_tb.vhd
-- description:
--    testbench for functional verification of hexled_driver module

--!! TO DO: implement 7-segment value decoder

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity hexled_driver_tb is
end entity;

architecture hexled_driver_tb_arch of hexled_driver_tb is

	-- additional signals and parameters
	constant clk_period : time := 20 ns;
	constant hl_upd_period : natural := 1000; -- imitation of 1 ms interval (reduced by 250 times)

	type digit_test_arr is array (0 to 31) of std_logic_vector(4 downto 0);
	constant digit_test_const: digit_test_arr := 
		("00000", "00001", "00010", "00011", "00100", "00101", "00110", "00111",   -- 0-7 
		 "01000", "01001", "01010", "01011", "01100", "01101", "01110", "01111",   -- 8-F
		 "10000", "10001", "10010", "10011", "10100", "10101", "10110", "10111",   -- (symbols with shift=1: separate bars)
		 "11000", "11001", "11010", "11011", "11100", "11101", "11110", "11111");  -- (symbols with shift=1: H L U...)
	
	-- stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic;
	signal rst : std_logic;
	signal dot_test : std_logic_vector(5 downto 0) := (others => '0');
	type digit_test_type is array (0 to 5) of std_logic_vector(4 downto 0);
	signal digit_test : digit_test_type := (others => (others => '0'));

	-- observed signals - signals mapped to the output ports of tested entity
	signal segment_data : std_logic_vector(7 downto 0);
    signal digit_select : std_logic_vector(5 downto 0);

begin

	-- Unit Under Test declaration, generic and port mapping
	UUT: entity work.hexled_driver(hexled_driver_arch)
    generic map (
        CNT_LIMIT => hl_upd_period
    )
    port map (
        CLK => clk,
        RST => rst,
        DT0 => dot_test(0),
        DT1 => dot_test(1),
        DT2 => dot_test(2),
        DT3 => dot_test(3),
        DT4 => dot_test(4),
        DT5 => dot_test(5),
        DDI0 => digit_test(0),
        DDI1 => digit_test(1),
        DDI2 => digit_test(2),
        DDI3 => digit_test(3),
        DDI4 => digit_test(4),
        DDI5 => digit_test(5),
        SEG_DAT => segment_data,
        DIG_SEL => digit_select
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
	stim_gen_proc: process
	begin
		wait until rst = '0'; -- 1) work only after reset
		for i in 0 to 31-5 loop  -- 2) try all modes of hexled_driver operation
			digit_test <= (digit_test_const(i), digit_test_const(i+1), digit_test_const(i+2), digit_test_const(i+3), digit_test_const(i+4), digit_test_const(i+5));
			dot_test <= (digit_test_const(i)(0), digit_test_const(i+1)(0), digit_test_const(i+2)(0), digit_test_const(i+3)(0), digit_test_const(i+4)(0), digit_test_const(i+5)(0));
			wait for 120 us;
		end loop;
		wait;                 -- 3) stop forever
	end process;

end architecture;