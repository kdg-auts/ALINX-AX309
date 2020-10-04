----------------------------------------------------------------------------------
-- Create Date    : 16:34:42 02.10.2020 
-- Design Name    : lab_fsm_demo
-- Module Name    : lab_fsm_demo_tb - lab_fsm_demo_tb_arch 
-- Project Name   : lab_fsm_demo
-- Target Devices : xc6slx9
-- Description: testbench for funtional verification of lab_fsm_demo top-level
--    module; generic costant values are reduced for convenient simulation timing;
--    recomended time for simulation: 90 us
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity lab_fsm_demo_tb is
end entity;

architecture lab_fsm_demo_tb_arch of lab_fsm_demo_tb is 
    signal clk_test : std_logic;
    signal rst_test : std_logic;
    signal up_btn_test : std_logic := '1';
    signal down_btn_test : std_logic := '1';
    signal seg_data : std_logic_vector (7 downto 0);
    signal seg_select : std_logic_vector (5 downto 0);
    signal sound : std_logic;
    constant H_PERIOD_test : integer := 500;
    constant CNT_LIMIT_test : integer := 10;
    constant CLK_PERIOD : time := 20 ns;
    constant SND_MODE_test : std_logic := '1'; -- output generation mode: '0' = constant, '1' = waveform
    constant SHB_PERIOD_test : natural := 10; -- sound pulse period (number of CLK ticks with Fclk = 50 MHz)
    constant LOB_PERIOD_test : natural := 50; -- sound signal period (number of CLK ticks with Fclk = 50 MHz)
    constant SND_PERIOD_test : natural := 2; -- sound wave period (number of CLK ticks for Fsnd = 2 kHz)
    constant HLCNT_LIMIT : integer := 5; -- hexled display refresh rate
begin

    -- UUT module instantiation
    UUT: entity work.lab_fsm_demo(lab_fsm_demo_arch) 
    generic map (
        BEEPER_SND_MODE => SND_MODE_test,
        BEEPER_SHB_PERIOD => SHB_PERIOD_test,
        BEEPER_LOB_PERIOD => LOB_PERIOD_test,
        BEEPER_SND_PERIOD => SND_PERIOD_test,
        HEXLED_CNT_LIMIT => HLCNT_LIMIT
    )
    port map (
        GLOBAL_RST => rst_test,
        GLOBAL_CLK => clk_test,
        UP_BTN => up_btn_test,
        DOWN_BTN => down_btn_test,
        SEG_DATA => seg_data,
        SEG_SELECT => seg_select,
        BEEP => sound
    );

    clk_gen_proc: process
    begin
        clk_test <= '0';
        wait for CLK_PERIOD/2;
        clk_test <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    rst_gen_proc: process
    begin
        rst_test <= '0';
        wait for CLK_PERIOD*2;
        rst_test <= '1';
        wait;
    end process;

    stim_gen: process
    begin
        wait until rst_test = '1';
        wait for CLK_PERIOD*10;

        -- button UP press/release imitation
        for i in 0 to 20 loop
            up_btn_test <= '0';
            wait for CLK_PERIOD*3;
            up_btn_test <= '1';
            wait for CLK_PERIOD*100;
        end loop;

        -- button DOWN press/release imitation
        for i in 0 to 20 loop
            down_btn_test <= '0';
            wait for CLK_PERIOD*3;
            down_btn_test <= '1';
            wait for CLK_PERIOD*100;
        end loop;

    end process;

end architecture;