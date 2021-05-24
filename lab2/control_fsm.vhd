-- project: lab2 - switch & led with beep
-- file: control_fsm.vhd
-- description:
--    finite state machine (fsm) that controls led_driver and beep_driver according to 
--    switch_driver module output signals; based on switch/key pressing patterns it 
--    changes display modes of controlled LED (off, constant on, slow blinking or 
--    fast blinking) and generates command to play subsequent sound pattern (short beep
--    for turn on/off slow blink, double beep for turning on fast blink and long beep
--    for fast blink turning off)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_fsm is
	port (
		CLK : in std_logic;
		RST : in std_logic;
		RIE : in std_logic;
		FAE : in std_logic;
		LPR : in std_logic;
		LED_MODE : out std_logic_vector(1 downto 0);
		BEEP_MODE : out std_logic_vector(1 downto 0);
		BEEP_RUN : out std_logic
	);
end control_fsm;

architecture control_fsm_arch of control_fsm is
	type fsm_state_type is (idle, press, release, long_press);
	signal fsm_state : fsm_state_type := idle;
	signal led_mode_sig : std_logic_vector(1 downto 0) := "00";
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
