library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_FSM is
	port (
		CLK : in std_logic;
		RST	: in std_logic;
		FE : in std_logic;
		STATE_LED : out std_logic;
		BLINK_LED : out std_logic  
	);
end control_FSM;	 


architecture control_FSM_arch of control_FSM is
	type FSM_state_type is (s0, s1, s2, s3);
	signal FSM_state : FSM_state_type;
	
	
begin
	
	FSM_func: process(CLK, RST) 
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				FSM_state <= s0; 
				STATE_LED <= '0';
				blink_led <= '0';
			else 
				case FSM_state is 
					when s0 =>
						STATE_LED <= '0';
						BLINK_LED <= '0';
						if FE = '1' then
							FSM_state <= s1;
						end if;
					when s1 => 
						STATE_LED <= '1';
						BLINK_LED <= '1';
						if FE='1' then
							FSM_state <= s2;
						end if;
					when s2 => 
						STATE_LED <= '0';
						BLINK_LED <= '1';
						if FE='1' then
							FSM_state <= s3;
						end if;
					when s3 => 
						STATE_LED <= '1';
						BLINK_LED <= '0';
						if FE='1' then
							FSM_state <= s0;
						end if;
				end case; 
			end if; 
		end if; 
		
	end process;
	 	
end architecture control_FSM_arch;
