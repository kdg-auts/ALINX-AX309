----------------------------------------------------------------------------------
-- Create Date    : 16:34:42 02.10.2020 
-- Design Name    : lab_fsm_demo
-- Module Name    : control_fsm - control_fsm_arch 
-- Project Name   : lab_fsm_demo
-- Target Devices : xc6slx9
-- Description: 
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity control_fsm is
    port ( 
        RST : in  STD_LOGIC;
        CLK : in  STD_LOGIC;
        UP_BTN : in  STD_LOGIC;
        DOWN_BTN : in  STD_LOGIC;
        COUT : out  STD_LOGIC_VECTOR (3 downto 0);
        BEEP : out  STD_LOGIC
    );
end entity;

architecture control_fsm_arch of control_fsm is
    type state_t is (idle, count_up, count_down);
    signal fsm_state : state_t := idle;
    signal count_state : unsigned(3 downto 0) := (others => '0');
begin
    
    -- input and output bindings
    COUT <= STD_LOGIC_VECTOR(count_state);

    fsm_main: process(RST, CLK)
    begin
        if rising_edge(CLK) then 
            if RST = '1' then 
                fsm_state <= idle;
                count_state <= (others => '0');
                BEEP <= '0';
            else 
                case fsm_state is
                    when idle =>
                        BEEP <= '0';
                        if UP_BTN = '1' then -- button UP is pressed
                            fsm_state <= count_up;
                        end if;
                        if DOWN_BTN = '1' then -- button DOWN is pressed
                            fsm_state <= count_down;
                        end if;
                    when count_up =>
                        if UP_BTN = '0' then -- button UP is released - do actions
                            count_state <= count_state + 1;
                            if count_state = "1111" then
                                BEEP <= '1';
                            end if;
                            fsm_state <= idle;
                        end if;
                    when count_down =>
                        if DOWN_BTN = '0' then -- button DOWN is released - do actions
                            count_state <= count_state - 1;
                            if count_state = "0000" then
                                BEEP <= '1';
                            end if;
                            fsm_state <= idle;
                        end if;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;


end architecture;