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

entity control_fsm is
	port (
		CLK : in std_logic;
		RST : in std_logic;
		SW1_LEFT : in std_logic;
		SW2_RIGHT : in std_logic;
		SW3_NEXT : in std_logic;
		SW4_PREV : in std_logic;
		DOT : out STD_LOGIC_VECTOR(5 downto 0);
		REG0 : out STD_LOGIC_VECTOR(3 downto 0);
		REG1 : out STD_LOGIC_VECTOR(3 downto 0);
		REG2 : out STD_LOGIC_VECTOR(3 downto 0);
		REG3 : out STD_LOGIC_VECTOR(3 downto 0);
		REG4 : out STD_LOGIC_VECTOR(3 downto 0);
		REG5 : out STD_LOGIC_VECTOR(3 downto 0);
		SHFT : out STD_LOGIC;
		LED0_MODE : out STD_LOGIC_VECTOR(1 downto 0);
		LED1_MODE : out STD_LOGIC_VECTOR(1 downto 0);
		LED2_MODE : out STD_LOGIC_VECTOR(1 downto 0);
		LED3_MODE : out STD_LOGIC_VECTOR(1 downto 0);
		BEEP_MODE : out STD_LOGIC_VECTOR(1 downto 0);
		BEEP_RUN : out STD_LOGIC
	);
end control_fsm;

architecture control_fsm_arch of control_fsm is
	type fsm_state_type is (idle, inc_pointer, dec_pointer, inc_reg, dec_reg);
	signal fsm_state : fsm_state_type := idle;
	signal reg0_sig : std_logic_vector(3 downto 0) := (others => '0');
	signal reg1_sig : std_logic_vector(3 downto 0) := (others => '0');
	signal reg2_sig : std_logic_vector(3 downto 0) := (others => '0');
	signal reg3_sig : std_logic_vector(3 downto 0) := (others => '0');
	signal reg4_sig : std_logic_vector(3 downto 0) := (others => '0');
	signal reg5_sig : std_logic_vector(3 downto 0) := (others => '0');
	signal led_mode_sig : std_logic_vector(3 downto 0) := "00";
	signal beep_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal beep_run_sig : std_logic := '0';
begin
	
	fsm_proc: process(CLK, RST) 
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				fsm_state <= idle; 
				led_mode_sig <= "00";
				beep_mode_sig <= "00";
				beep_run_sig <= '0';
			else 
				case fsm_state is 
					when idle => -- default state, waiting switch/key press
						beep_run_sig <= '0'; -- halt start signal
						if RIE = '1' then
							fsm_state <= press;
						end if;
					when press => -- switch/key press detected, now wait for release or long press
						if FAE = '1' then -- release: toggle slow blink and play short beep
							fsm_state <= release;
						elsif LPR = '1' then -- long press: turn fast blink and play double beep
							fsm_state <= long_press;
						end if;
					when release => -- change mode in circle OFF -> ON -> slow blink -> OFF -> ...
						case led_mode_sig is
							when "00" => 
								led_mode_sig <= "01"; -- led: OFF -> ON
								beep_mode_sig <= "01"; -- short beep
								beep_run_sig <= '1'; -- start playing
							when "01" => 
								led_mode_sig <= "10"; -- led: ON -> slow blink
								beep_mode_sig <= "01"; -- short beep
								beep_run_sig <= '1'; -- start playing
							when "10" => 
								led_mode_sig <= "00"; -- led: slow blink -> OFF
								beep_mode_sig <= "01"; -- short beep
								beep_run_sig <= '1'; -- start playing
							when others => 
								led_mode_sig <= "00"; -- lef: fast blink -> OFF
								beep_mode_sig <= "10"; -- long beep
								beep_run_sig <= '1'; -- start playing
						end case;
						fsm_state <= idle;
					when long_press => -- long press turns fast blink mode, fast press-release to turn OFF
						led_mode_sig <= "11"; -- led: fast blink
						beep_mode_sig <= "11"; -- double beep
						beep_run_sig <= '1'; -- start playing
						fsm_state <= idle;
				end case; 
			end if; 
		end if; 
	end process;
	
	LED_MODE <= led_mode_sig; -- output current led state
	BEEP_MODE <= beep_mode_sig; -- output beep mode
	BEEP_RUN <= beep_run_sig; -- output beep run
	
end architecture control_fsm_arch;
