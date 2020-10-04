----------------------------------------------------------------------------------
-- Create Date    : 23:05:42 08/25/2020 
-- Design Name    : lab_hexled
-- Module Name    : sbox_hexled_demo - sbox_hexled_demo_arch
-- Project Name   : lab_sbox_on_hexled
-- Target Devices : xc6slx9
-- Description    : top-level module
--
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sbox_hexled_demo is
    generic (
        H_PERIOD: integer := 50000000; -- 50M counts of clk = 1 sec
        CNT_LIMIT: integer := 500000  -- 500k counts of clk = 10 ms
    );
    port ( 
        global_clk : in  STD_LOGIC;
        global_rst : in  STD_LOGIC;
        seg_data : out  STD_LOGIC_VECTOR (7 downto 0);
        seg_select : out  STD_LOGIC_VECTOR (5 downto 0)
    );
end sbox_hexled_demo;

architecture sbox_hexled_demo_arch of sbox_hexled_demo is
    signal rst_int : STD_LOGIC := '0';
    signal sbox_inp : STD_LOGIC_VECTOR (3 downto 0);
    signal sbox_otp : STD_LOGIC_VECTOR (3 downto 0);
    signal seg_data_int : STD_LOGIC_VECTOR (7 downto 0);
    signal seg_select_int : STD_LOGIC_VECTOR (1 downto 0);
begin
    
    -- global input ajustment
    rst_int <= not global_rst; -- global_rst input is ACTIVE LOW
    seg_data <= not seg_data_int; -- seg_data output is ACTIVE LOW
    -- seg_select output is ACTIVE LOW
    seg_select <= not (seg_select_int(0) & "0000" & seg_select_int(1));
    
    -- input sequence counter
    inp_counter: entity work.counter_4_bit_1_sec(counter_4_bit_1_sec_arch)
    generic map (
        H_PERIOD => H_PERIOD
    )
    port map (
        clk => global_clk,
        rst => rst_int,
        cdata => sbox_inp
    );
    
    -- s-box component
    sbox_instance: entity work.kxx_s_box(kxx_s_box_arch)
    port map (
        x => sbox_inp,
        y => sbox_otp
    );
    
    -- hexled driver
    hexled_driver_inst: entity work.hexled_driver(hexled_driver_arch)
    generic map (
        CNT_LIMIT => CNT_LIMIT
    )
    port map (
        clk => global_clk,
        rst => rst_int,
        hex_data_0 => sbox_inp, 
        hex_data_1 => sbox_otp,
        dot_0 => '0',
        dot_1 => '1',
        seg_data   => seg_data_int,
        seg_select => seg_select_int
    );

end sbox_hexled_demo_arch;

