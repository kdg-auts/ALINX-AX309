-------------------------------------------------------------------------------
-- Description : главный управляющий автомат таймера/секундомера 
--               включает в себя счетные регистры, позволяет редактировать 
--               их значения, инициирует звуковые сигналы по нажатиям кнопок
--               и событиям переполнения при счете
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity tim_sec is
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		INC : in STD_LOGIC;
		DEC : in STD_LOGIC;
		SEG_EDIT : in STD_LOGIC;
		MODE_SEL : in STD_LOGIC;
		RUN_STOP : in STD_LOGIC;
		TICK : in STD_LOGIC;

		HEX1, HEX2, HEX3, HEX4 : out STD_LOGIC_VECTOR(3 downto 0);
		D1_SEL, D2_SEL, D3_SEL, SE_SEL : out STD_LOGIC;
		SBEEP, LBEEP : out STD_LOGIC
	);
end entity;

architecture tim_sec_arch of tim_sec is
	type state_t is (idle, edit, count);
	signal state : state_t := idle; -- состояние основного автомата
	type seg_arr_t is array (0 to 2) of STD_LOGIC_VECTOR(3 downto 0);
	signal seg : seg_arr_t := (others => (others => '0')); -- регистр значений ТМ/СЕК
	signal act_seg : INTEGER range 0 to 2 := 0; -- номер активного сегмента
	signal act_mode: std_logic := '0'; -- режим работы: 0=секундомер, 1=таймер
begin
	main_fsm: process(CLK, RST)
	begin
		if CLK'event and CLK = '1' then
			if RST = '1' then
				state <= idle; -- значение по умолчанию
				act_mode <= '0'; -- режим СЕК
				act_seg <= 0; -- выбранный регистр сегмента 0 (десятые доли секунды)
				seg <= (others => (others => '0')); -- обнулить все регистры сегментов
			else
                SBEEP <= '0'; -- сбросить сигнал звука
                LBEEP <= '0';
                case state is
                    when idle =>
                        -- выбор следующего сегмента
                        if INC = '1' then
                            if act_seg = 2 then
                                act_seg <= 0;
                            else
                                act_seg <= act_seg + 1;
                            end if;
                        end if;
                        -- выбор предыдущего сегмента
                        if DEC = '1' then
                            if act_seg = 0 then
                                act_seg <= 2;
                            else
                                act_seg <= act_seg - 1;
                            end if;
                        end if;
                        -- смена режима ТМ/СЕК
                        if MODE_SEL = '1' then
                            act_mode <= not act_mode;
                        end if;
                        -- смена состояния: редактирование или начало счета
                        if SEG_EDIT = '1' then
                            state <= edit;
                            --SE_SEL <= '1';
                        elsif RUN_STOP = '1' then
                            state <= count;
                        end if;
                    when edit =>
                        -- редактирование текущего сегмента: инкремент
                        if INC = '1' then
                            if seg(act_seg) = "1001" then
                                seg(act_seg) <= "0000";
                            else
                                seg(act_seg) <= seg(act_seg) + 1;
                            end if;
                        end if;
                        -- редактирование текущего сегмента: декремент
                        if DEC = '1' then
                            if seg(act_seg) = "0000" then
                                seg(act_seg) <= "1001";
                            else
                                seg(act_seg) <= seg(act_seg) - 1;
                            end if;
                        end if;
                        if SEG_EDIT = '1' then
                            state <= idle;
                            --SE_SEL <= '0';
                        end if;
                    when count =>
                        if RUN_STOP = '1' then
                            state <= idle;
                            SBEEP <= '1';
                        elsif TICK = '1' then
                            if act_mode = '0' then -- секундомер
                                if seg(0) < "1001" then
                                    seg(0) <= seg(0) + 1;
                                elsif seg(1) < "1001" then
                                    seg(0) <= "0000";
                                    seg(1) <= seg(1) + 1;
                                elsif seg(2) < "1001" then
                                    seg(1) <= "0000";
                                    seg(2) <= seg(2) + 1;
                                else
                                    seg <= (others => (others => '0'));
                                    LBEEP <= '1';
                                    state <= idle;
                                end if;
                            else -- act_mode = '1' -- таймер
                                if seg(0) > "0000" then
                                    seg(0) <= seg(0) - 1;
                                elsif seg(1) > "0000" then
                                    seg(0) <= "1001";
                                    seg(1) <= seg(1) - 1;
                                elsif seg(2) < "0000" then
                                    seg(1) <= "1001";
                                    seg(2) <= seg(2) - 1;
                                else
                                    seg <= (others => (others => '0'));
                                    LBEEP <= '1';
                                    state <= idle;
                                end if;
                            end if;
                        end if;
				end case;
			end if;
		end if;
    end process;
    
    HEX1 <= seg(0);
    HEX2 <= seg(1);
    HEX3 <= seg(2);
    HEX4 <= x"A" when act_mode = '0' else x"B";

    SE_SEL <= '1' when state = edit else '0';

    D1_SEL <= '1' when act_seg = 0 else '0';
    D2_SEL <= '1' when act_seg = 1 else '0';
    D3_SEL <= '1' when act_seg = 2 else '0';

end architecture;