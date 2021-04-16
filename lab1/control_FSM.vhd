-- project: lab1 - switch and led drivers
-- file: control_fsm.vhd
-- description:
--    finite state machine (fsm) that controls led_driver according to switch_driver module
--    output signals; based on switch/key pressing patterns is changes display modes of 
--    controlled LED: off, constant on, slow blinking and fast blinking

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
		LED_MODE : out std_logic_vector(1 downto 0)
	);
end control_fsm;

architecture control_fsm_arch of control_fsm is
	type fsm_state_type is (idle, press, release, long_press);
	signal fsm_state : fsm_state_type;
	signal led_mode_sig : std_logic_vector(1 downto 0) := "00";
begin
	
	fsm_proc: process(CLK, RST) 
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				fsm_state <= idle; 
				led_mode_sig <= "00";
			else 
				case fsm_state is 
					when idle => -- default state, waiting switch/key press
						if RIE = '1' then
							fsm_state <= press;
						end if;
					when press => -- switch/key press detected, now wait for release or long press
						if FAE = '1' then -- release
							fsm_state <= release;
						elsif LPR = '1' then -- long press
							fsm_state <= long_press;
						end if;
					when release => -- change mode in circle OFF -> ON -> slow blink -> OFF -> ...
						case led_mode_sig is
							when "00" => led_mode_sig <= "01"; -- led ON
							when "01" => led_mode_sig <= "10"; -- ON -> slow blink
							when "10" => led_mode_sig <= "00"; -- slow blink -> OFF
							when others => led_mode_sig <= "00"; -- fast blink -> OFF
						end case;
						fsm_state <= idle;
					when long_press => -- long press turns fast blink mode, fast press-release to turn OFF
						led_mode_sig <= "11";
						fsm_state <= idle;
				end case; 
			end if; 
		end if; 
	end process;
	
	LED_MODE <= led_mode_sig; -- output current led state
	
end architecture control_fsm_arch;
