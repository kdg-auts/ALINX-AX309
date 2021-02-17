----------------------------------------------------------------------------------
-- Create Date    : 19:12:22 08/25/2020
-- Design Name    : lab_hexled
-- Module Name    : hexled_driver - hexled_driver_arch
-- Project Name   : lab_sbox_on_hexled
-- Target Devices : xc6slx9
-- Description:
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hexled_driver is
    generic (
        CNT_LIMIT: integer := 1000000 -- 1M counts of clk = 20 millisec
    );
    port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        hex_data_0 : in  STD_LOGIC_VECTOR (3 downto 0);
        hex_data_1 : in  STD_LOGIC_VECTOR (3 downto 0);
        dot_0 : in  STD_LOGIC;
        dot_1 : in  STD_LOGIC;
        seg_data   : out STD_LOGIC_VECTOR (7 downto 0);
        seg_select : out STD_LOGIC_VECTOR (1 downto 0)
    );
end hexled_driver;

architecture hexled_driver_arch of hexled_driver is
    signal tseg_count: INTEGER range 0 to CNT_LIMIT-1 := 0;
    signal active_seg: STD_LOGIC := '0';
    signal active_hex: STD_LOGIC_VECTOR(3 downto 0);
begin

    -- digit selection counter
    hexled_timer: process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tseg_count <= 0;
                active_seg <= '0';
            elsif tseg_count = CNT_LIMIT-1 then
                tseg_count <= 0;
                if active_seg = '0' then
                    active_seg <= '1';
                else
                    active_seg <= '0';
                end if;
            else
                tseg_count <= tseg_count + 1;
            end if;
        end if;
    end process;

    -- selector of value to display
    active_hex <= hex_data_0 when active_seg = '0' else
                  hex_data_1;

    -- decoder bin-to-hex for selected value
    seg_data(6 downto 0) <= "0111111"  when active_hex = x"0" else
                            "0000110"  when active_hex = x"1" else
                            "1011011"  when active_hex = x"2" else
                            "1001111"  when active_hex = x"3" else
                            "1100110"  when active_hex = x"4" else
                            "1101101"  when active_hex = x"5" else
                            "1111101"  when active_hex = x"6" else
                            "0000111"  when active_hex = x"7" else
                            "1111111"  when active_hex = x"8" else
                            "1101111"  when active_hex = x"9" else
                            "1110111"  when active_hex = x"A" else
                            "1111100"  when active_hex = x"B" else
                            "0111001"  when active_hex = x"C" else
                            "1011110"  when active_hex = x"D" else
                            "1111001"  when active_hex = x"E" else
                            "1110001"; -- F

    -- dot display control
    seg_data(7) <= dot_0 when active_seg = '0' else
                   dot_1;

    -- forming outputs for segment selection
    seg_select(0) <= not active_seg;
    seg_select(1) <= active_seg;

end hexled_driver_arch;

