library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sbox_hexled_demo_tb is
end entity;

architecture sbox_hexled_demo_tb_arch of sbox_hexled_demo_tb is 
    signal clk_test : std_logic;
    signal rst_test : std_logic;
    signal seg_data : std_logic_vector (7 downto 0);
    signal seg_select : std_logic_vector (5 downto 0);
    constant H_PERIOD_test : integer := 500;
    constant CNT_LIMIT_test : integer := 10;
    constant clk_period : time := 20 ns;
begin

    -- UUT module instantiation
    uut: entity work.sbox_hexled_demo(sbox_hexled_demo_arch) 
    generic map (
		H_PERIOD => H_PERIOD_test,
        CNT_LIMIT=> CNT_LIMIT_test
	)
    port map ( 
        global_clk => clk_test,
        global_rst => rst_test,
        seg_data => seg_data,
        seg_select => seg_select
    );

    clk_gen_proc: process
	begin
		clk_test <= '0';
		wait for clk_period/2;
		clk_test <= '1';
		wait for clk_period/2;
	end process;
    
    rst_gen_proc: process
	begin
		rst_test <= '0';
		wait for clk_period*2;
		rst_test <= '1';
		wait;
	end process;

end architecture;
