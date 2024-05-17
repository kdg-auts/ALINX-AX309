-- project: lab3 - hexled demo
-- file: control_fsm.vhd
-- description:
--    finite state machine (fsm) that controls hexled_driver indication according to 
--    switch_driver module output signals; Key1 and Key2 allow to change active focus  
--    over hexled digits; Key3 and Key4 allow to change symbol displayed; every action
--    is followed by short beep signal, exept shift change and sequence overflow - they
--    are followed by double short and long beep respectively

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;

entity control_fsm is
	generic(
		SEND_TIMER_MAX : integer := 5000000 -- 5M CLK periods (100 ms)
	);
	port(
		CLK : in std_logic;
		RST : in std_logic;
		SWK1_LEFT : in std_logic;
		SWK2_RIGHT : in std_logic;
		SWK3_NEXT : in std_logic;
		SWK4_PREV : in std_logic;
		DOT : out std_logic_vector(5 downto 0);
		REG0 : out std_logic_vector(4 downto 0);
		REG1 : out std_logic_vector(4 downto 0);
		REG2 : out std_logic_vector(4 downto 0);
		REG3 : out std_logic_vector(4 downto 0);
		REG4 : out std_logic_vector(4 downto 0);
		REG5 : out std_logic_vector(4 downto 0);
		LED0_MODE : out std_logic_vector(1 downto 0);
		LED1_MODE : out std_logic_vector(1 downto 0);
		LED2_MODE : out std_logic_vector(1 downto 0);
		LED3_MODE : out std_logic_vector(1 downto 0);
		BEEP_MODE : out std_logic_vector(1 downto 0);
		BEEP_RUN : out std_logic;
		RX_DATA : in std_logic_vector(7 downto 0);
		RX_DATA_RDY : in std_logic;
		RX_BUF_FULL : in std_logic;
		TX_BUF_FULL : in std_logic;
		TX_DATA : out std_logic_vector(7 downto 0);
		TX_DATA_WR : out std_logic;
		RX_DATA_ACK : out std_logic
	);
end control_fsm;

architecture control_fsm_arch of control_fsm is
	-- fsm state description
	type fsm_state_type is (idle, inc_pointer, dec_pointer, inc_reg, dec_reg, receive_status, send_status);
	signal fsm_state : fsm_state_type := idle;
	-- internal data registers
	type reg_data_type is array (0 to 5) of unsigned(4 downto 0);
	signal reg_sig : reg_data_type := (others => (others => '0'));
	-- internal auxiliary signals
	signal pointer_sig : natural range 0 to 5 := 0;
	-- leds and buzzer control signals
	signal beep_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal beep_run_sig : std_logic := '0';
	-- uart related signals
	signal send_timer_sig : unsigned(integer(ceil(log2(real(SEND_TIMER_MAX))))-1 downto 0) := (others => '0');
	signal count_start_sig : std_logic := '0';
	signal count_finish_sig : std_logic := '0';
	signal send_pointer_sig	: natural range 0 to 6 := 0;
begin
	
	fsm_proc: process(CLK, RST)
		variable update_pointer : natural range 0 to 7 := 0;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				fsm_state <= idle; 
				pointer_sig <= 0;
				reg_sig <= (others => (others => '0'));
				beep_mode_sig <= "00";
				beep_run_sig <= '0';
				send_pointer_sig <= 0;
				TX_DATA <= (others => '0');
				TX_DATA_WR <= '0';
				RX_DATA_ACK <= '0';
			else 
				case fsm_state is 
					when idle => -- default state, waiting any button press (SWK1-SWK4)
						beep_run_sig <= '0'; -- reset beep start signal
						-- beep_mode_sig <= "00";
						if SWK1_LEFT = '1' then
							fsm_state <= inc_pointer;
						elsif SWK2_RIGHT = '1' then
							fsm_state <= dec_pointer;
						elsif SWK3_NEXT = '1' then
							fsm_state <= inc_reg;
						elsif SWK4_PREV = '1' then
							fsm_state <= dec_reg;
						elsif RX_DATA_RDY = '1' then
							fsm_state <= receive_status;
						elsif count_finish_sig = '1' then
							count_start_sig <= '1';
							fsm_state <= send_status;
						end if;
					when inc_pointer => -- SWK1 is pressed - change position left
						if pointer_sig = 5 then -- loop pointer and play long beep
							pointer_sig <= 0;
							beep_mode_sig <= "10";
							beep_run_sig <= '1';
						else
							pointer_sig <= pointer_sig + 1;
						end if;
						fsm_state <= idle;
					when dec_pointer => -- SWK2 is pressed - change position right
						if pointer_sig = 0 then -- loop pointer and play long beep
							pointer_sig <= 5;
							beep_mode_sig <= "10";
							beep_run_sig <= '1';
						else
							pointer_sig <= pointer_sig - 1;
						end if;
						fsm_state <= idle;
					when inc_reg => -- SWK3 is pressed - show next value for current digit
						if reg_sig(pointer_sig) = "11111" then -- loop value and play double beep 
							reg_sig(pointer_sig) <= "00000";
							beep_mode_sig <= "11";
							beep_run_sig <= '1';
						else
							reg_sig(pointer_sig) <= reg_sig(pointer_sig) + 1;
						end if;
						fsm_state <= idle;
					when dec_reg => -- SWK4 is pressed - show prev value for current digit
						if reg_sig(pointer_sig) = "00000" then -- loop value and play double beep 
							reg_sig(pointer_sig) <= "11111";
							beep_mode_sig <= "11";
							beep_run_sig <= '1';
						else
							reg_sig(pointer_sig) <= reg_sig(pointer_sig) - 1;
						end if;
						fsm_state <= idle;
					when send_status =>
						count_start_sig <= '0';
						if send_pointer_sig = 6 then -- loop send_pointer to process all reg_sig sells 
							send_pointer_sig <= 0;
							TX_DATA <= (others => '0');
							TX_DATA_WR <= '0';
							fsm_state <= idle; 
						else
							TX_DATA_WR <= '0';
							if TX_BUF_FULL = '0' then
								TX_DATA <= std_logic_vector(to_unsigned(send_pointer_sig, 3)) & std_logic_vector(reg_sig(send_pointer_sig));
								TX_DATA_WR <= '1';
								send_pointer_sig <= send_pointer_sig + 1;
							end if;
						end if;
					when receive_status	=>
						if RX_DATA_RDY = '1' then
							RX_DATA_ACK <= '1';
							update_pointer := to_integer(unsigned(RX_DATA(7 downto 5)));
							if update_pointer >= 0 and update_pointer <= 5 then
								reg_sig(update_pointer)	<= unsigned(RX_DATA(4 downto 0));
							end if;
						else
							RX_DATA_ACK <= '0';
							fsm_state <= idle;
						end if;
				end case; 
			end if; 
		end if; 
	end process;
	
	-- timer for periodical status send over UART (100 ms)
	uart_send_timer: process(CLK, RST)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				send_timer_sig <= (others => '0');
			else
				if count_start_sig = '1' then
					send_timer_sig <= (others => '0');
				elsif send_timer_sig < SEND_TIMER_MAX-1 then
					send_timer_sig <= send_timer_sig + 1;
				end if;
			end if; 
		end if;
	end process;
	
	count_finish_sig <= '1' when send_timer_sig = SEND_TIMER_MAX-1 else '0';
	
	-- dot enlightment selector (should be visible for active digit)
	DOT <= "000001" when pointer_sig = 0 else
	       "000010" when pointer_sig = 1 else
	       "000100" when pointer_sig = 2 else
	       "001000" when pointer_sig = 3 else
	       "010000" when pointer_sig = 4 else
	       "100000"; -- pointer_sig = 5
	
	-- output all reg states on hexled digits (conv. unsigned to SLV)
	REG0 <= std_logic_vector(reg_sig(0));
	REG1 <= std_logic_vector(reg_sig(1));
	REG2 <= std_logic_vector(reg_sig(2));
	REG3 <= std_logic_vector(reg_sig(3));
	REG4 <= std_logic_vector(reg_sig(4));
	REG5 <= std_logic_vector(reg_sig(5));

	-- output current digit code on leds
	LED0_MODE <= '0' & reg_sig(pointer_sig)(0);
	LED1_MODE <= '0' & reg_sig(pointer_sig)(1);
	LED2_MODE <= '0' & reg_sig(pointer_sig)(2);
	LED3_MODE <= '0' & reg_sig(pointer_sig)(3);

	-- output beep signals
	BEEP_MODE <= beep_mode_sig;
	BEEP_RUN <= beep_run_sig;
	
end architecture control_fsm_arch;