-- project: lab1 - switch and led drivers
-- file: switch_driver.vhd
-- description:
--    Module detects different events for single switch/key: rising edge, falling edge,
--    long press; module indicates pressed/released state and registered toggle state.
--    Module performs input filtering trough hardware debouncing scheme (based on
--    shift register) and outputs state of switch/key in positive logic (type of switch/key
--    input is defined with corresponding generic parameter)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity switch_driver is

	generic (
		LPR_CP : natural := 50000000; -- long press count period (in CLK periods) == 1 sec
		SWS_CP : natural := 100000; -- switch scan count period (in CLK periods) == 2 ms
		SW_ACT_ST : std_logic := '1' -- switch active state (when it is pressed)
	);

	port (
		CLK : in std_logic;
		RST : in std_logic;
		SWI : in std_logic;  -- switch/key state input
		RIE : out std_logic; -- RIsing Edge signal
		FAE : out std_logic; -- FAlling Edge signal
		LVL : out std_logic; -- LeVeL (current filtered switch state, positive logic)
		TGL : out std_logic; -- ToGgLe state (dedicated register)
		LPR : out std_logic  -- Long PRess signal
	);
end switch_driver;

architecture switch_drv_arch of switch_driver is
	signal sw_state_shiftreg : std_logic_vector (5 downto 0);
	signal sw_fsm_state : std_logic;
	signal sw_toggle_reg : std_logic;
	signal long_press_counter : natural range 0 to LPR_CP-1;
	signal sw_scan_counter : natural range 0 to SWS_CP-1;
	signal shiftreg_en : std_logic;
	signal lp_counter_en : std_logic;
	constant ALL_ONES : std_logic_vector(sw_state_shiftreg'range) := (others => SW_ACT_ST); 
	constant ALL_ZEROS : std_logic_vector(sw_state_shiftreg'range) := (others => not SW_ACT_ST);

begin

	-- counter to determine moments of key scan (every 2 ms)
	-- forms enable signal for shift register in key debouncing scheme
	sw_scan_counter_proc: process (CLK, RST)
	begin
		if rising_edge(CLK) then
			if RST ='1' then
				sw_scan_counter <= 0;
				shiftreg_en <= '0';
			elsif sw_scan_counter = SWS_CP-1 then
				shiftreg_en <= '1';
				sw_scan_counter <= 0;
			else
				shiftreg_en <= '0';
				sw_scan_counter <= sw_scan_counter + 1;
			end if;
		end if;
	end process;

	-- counter to determine if key is constantly pressed (lohger than 1 second)
	-- if key is pressed longer than 1 sec, LPR signal is formed (strobe signal
	-- after each 1 sec while key is being pressed)
	long_press_counter_proc: process (CLK, RST)
	begin
		if rising_edge(CLK) then
			if RST ='1' then
				long_press_counter <= 0;
				LPR <= '0';
			elsif lp_counter_en = '1' then
				if long_press_counter = LPR_CP-1 then
					LPR <= '1';
					long_press_counter <= 0;
				else
					LPR <= '0';
					long_press_counter <= long_press_counter + 1;
				end if;

			else
				long_press_counter <= 0;
				LPR <= '0';
			end if;
		end if;
	end process;

	-- shift register that collects key state each 2 ms; typical hardware method 
	-- for key debouncing: key is concidered to be pressed when register collects
	-- all ones; key is concidered to be released when register collects all zeros
	shiftreg_proc: process (CLK, RST)
	begin
		if rising_edge(CLK) then
			if RST ='1' then
				sw_state_shiftreg <= (others => '0');
			elsif shiftreg_en = '1' then
				sw_state_shiftreg <= sw_state_shiftreg (4 downto 0) & SWI;
			end if;
		end if;
	end process;

	-- finite state machine (fsm) for switch/key state processing; determines all
	-- events for the switch/key: 
	-- RIE - rising edge detected (key is just pressed)
	-- FAE - falling edge detected (key is just released)
	-- LVL - current filtered state of switch/key (pressed of released)
	-- sw_toggle_reg (TGL) changes its state each time after key is pressed
	sw_fsm_proc: process (CLK, RST)
	begin
		if rising_edge (CLK) then
			if RST = '1' then
				sw_fsm_state <= '0';
				RIE <= '0';
				FAE <= '0';
				LVL <= '0';
				sw_toggle_reg <= '0';
				lp_counter_en <= '0';
			else
				case sw_fsm_state is
					when '0' => -- internal state "key is released"
						if sw_state_shiftreg = ALL_ONES then -- key is stably pressed
							lp_counter_en <= '1'; -- start long press time counter
							sw_toggle_reg <= not sw_toggle_reg; -- change toggle state to opposite
							LVL <= '1';
							sw_fsm_state <='1'; -- change internal state to "key is pressed"
							RIE <= '1'; -- rising edge detected
						else
							FAE <= '0'; -- cancel falling edge event
						end if;
					when '1' => -- internal state "key is pressed"
						if sw_state_shiftreg = ALL_ZEROS then -- key is stably released
							FAE <= '1'; -- falling edge detected
							lp_counter_en <= '0'; -- halt long press time counter
							LVL <= '0';
							sw_fsm_state <= '0'; -- change internal state to "key is released"
						else
							RIE <= '0'; -- cancel rising edge event
						end if;
					when others =>
						null;
				end case;
			end if;
		end if;
	end process;

	TGL <= sw_toggle_reg; -- output toggle register state
	
end architecture switch_drv_arch;
