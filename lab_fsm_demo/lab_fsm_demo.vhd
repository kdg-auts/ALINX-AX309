----------------------------------------------------------------------------------
-- Create Date    : 16:34:42 02.10.2020 
-- Design Name    : lab_fsm_demo
-- Module Name    : lab_fsm_demo - lab_fsm_demo_arch 
-- Project Name   : lab_fsm_demo
-- Target Devices : xc6slx9
-- Description: 
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab_fsm_demo is
    generic (
		BEEPER_SND_MODE: std_logic := '0'; -- output generation mode: '0' = constant, '1' = waveform
		BEEPER_SHB_PERIOD: natural := 10000000; -- number of CLK ticks for 200 ms (Fclk = 50 MHz)
		BEEPER_LOB_PERIOD: natural := 50000000; -- number of CLK ticks for 1 sec (Fclk = 50 MHz)
        BEEPER_SND_PERIOD: natural := 25000; -- number of CLK ticks for 0.5 ms (Fsnd = 2 kHz)
        HEXLED_CNT_LIMIT: integer := 500000 -- 500k counts of clk = 10 ms
	);
    port ( 
        GLOBAL_RST : in  STD_LOGIC;
        GLOBAL_CLK : in  STD_LOGIC;
        UP_BTN : in  STD_LOGIC;
        DOWN_BTN : in  STD_LOGIC;
        SEG_DATA   : out STD_LOGIC_VECTOR (7 downto 0);
        SEG_SELECT : out STD_LOGIC_VECTOR (5 downto 0);
        BEEP : out  STD_LOGIC
    );
end entity;

architecture lab_fsm_demo_arch of lab_fsm_demo is
    signal rst_int : STD_LOGIC;
    signal up_btn_int : STD_LOGIC;
    signal down_btn_int : STD_LOGIC;
    signal beep_out : STD_LOGIC;
    signal beep_en : STD_LOGIC;
    signal sbox_inp : STD_LOGIC_VECTOR (3 downto 0);
    signal sbox_otp : STD_LOGIC_VECTOR (3 downto 0);
    signal seg_data_int : STD_LOGIC_VECTOR (7 downto 0);
    signal seg_select_int : STD_LOGIC_VECTOR (1 downto 0);
    constant DEF_MODE : STD_LOGIC_VECTOR (1 downto 0) := "01";
begin
    -- in/out level ajustments
    rst_int <= not GLOBAL_RST; -- global reset is active low
    up_btn_int <= not UP_BTN; -- button signals are active low
    down_btn_int <= not DOWN_BTN; -- button signals are active low
    BEEP <= not beep_out; -- beep signal is active low
    SEG_DATA <= not seg_data_int; -- seg_data output is ACTIVE LOW
    -- seg_select output is ACTIVE LOW and segment ajustment from 2 to 6
    SEG_SELECT <= not (seg_select_int(0) & "0000" & seg_select_int(1));
    
    FSM: entity work.control_fsm(control_fsm_arch)
    port map (
        CLK => GLOBAL_CLK,
        RST => rst_int,
        UP_BTN => up_btn_int,
        DOWN_BTN => down_btn_int,
        COUT => sbox_inp,
        BEEP => beep_en
    );

    KBOX: entity work.kxx_s_box(kxx_s_box_arch)
    port map (
        x => sbox_inp,
        y => sbox_otp
    );

    BEEPER: entity work.beep_driver(beep_driver_arch)
    generic map (
		SND_MODE => BEEPER_SND_MODE,
		SHB_PERIOD => BEEPER_SHB_PERIOD,
		LOB_PERIOD => BEEPER_LOB_PERIOD,
		SND_PERIOD => BEEPER_SND_PERIOD
	)
	port map (
		CLK => GLOBAL_CLK,
		RST => rst_int,
		START => beep_en,
		MODE => DEF_MODE,
		BEEP => beep_out
    );
    
    HEXLED: entity work.hexled_driver(hexled_driver_arch)
    generic map (
        CNT_LIMIT => HEXLED_CNT_LIMIT
    )
    port map (
        clk => GLOBAL_CLK,
        rst => rst_int,
        hex_data_0 => sbox_inp,
        hex_data_1 => sbox_otp,
        dot_0 => '0',
        dot_1 => '1',
        seg_data => seg_data_int,
        seg_select => seg_select_int
    );

end architecture;