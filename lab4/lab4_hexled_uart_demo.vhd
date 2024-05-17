-- project: lab4 - hexled demo with UART
-- file: lab4_hexled_uart_demo.vhd
-- description:
--    top-level module, combines 4 switch_driver modules for each Key button, hexled_driver
--    module to display states of internal 6 registers, 2 led_driver modules to display
--    current state code for active digit, beep_driver to play sound for different events
--    and control_fsm to perform main algorithm. 
--    UART module is used to transmit full current state of symbols displayed on hexled
--    indicator every 100 ms and accept updates for symbols on hexled indicator

library IEEE;
use IEEE.std_logic_1164.all;

entity lab4_hexled_uart_demo is
	generic (
		BOARD_CLK_FREQ : natural := 50000000; -- CLK frequency in Hz
		SND_MODE: std_logic := '0'; -- output generation mode: '0' = constant, '1' = waveform  
		BAUD_PERIOD : integer := 325 -- default baud rate is 9600 (tick period 325)
	);
	port (
		CLK : in std_logic;
		RST : in std_logic;
		SWI : in std_logic_vector(3 downto 0);
		SEG : out std_logic_vector(7 downto 0);
		DIG : out std_logic_vector(5 downto 0);
		LDO : out std_logic_vector(3 downto 0);
		BPO : out std_logic;
		RXI : in std_logic;
		TXO : out std_logic
	);
end entity;

architecture lab4_hexled_uart_demo_arch of lab4_hexled_uart_demo is
	-- input/output buffer signals (to ajust logic levels)
	signal RST_sig : std_logic;
	signal SWI_sig : std_logic_vector(3 downto 0);
	signal LED_sig : std_logic_vector(3 downto 0);
	signal SEG_data_sig : std_logic_vector(7 downto 0);
	signal DIG_sel_sig : std_logic_vector(5 downto 0);
	signal BPO_sig : std_logic;
	signal RXI_sig : std_logic;
	signal TXO_sig : std_logic;

	-- internal signals
	signal sw1_left_sig : std_logic;
	signal sw2_right_sig : std_logic;
	signal sw3_next_sig : std_logic;
	signal sw4_prev_sig : std_logic;
	signal led0_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal led1_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal led2_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal led3_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal dot_sig : std_logic_vector(5 downto 0) := (others => '0');
	signal digit0_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit1_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit2_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit3_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit4_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit5_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal beep_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal beep_run_sig : std_logic := '0';
	signal tx_buffer_full_sig : std_logic := '0';
	signal rx_buffer_full_sig : std_logic := '0';
	signal rx_data_ready_sig : std_logic := '0';
	signal received_data_sig : std_logic_vector(7 downto 0) := (others => '0');
	signal write_to_fifo_sig : std_logic := '0'; 
	signal rx_data_ack_sig : std_logic := '0';
	signal data_to_transmit_sig : std_logic_vector(7 downto 0) := (others => '0');

	-- customization constants (generics for components)
	constant interval_1sec : natural := BOARD_CLK_FREQ; -- 1 sec :: 50 MHz (T=20 ns)
	constant interval_100ms : natural := BOARD_CLK_FREQ/10; -- 100 ms
	constant interval_2ms : natural := BOARD_CLK_FREQ/500; -- 2 ms
	constant interval_5ms : natural := BOARD_CLK_FREQ/200; -- 5 ms
	constant interval_1ms : natural := BOARD_CLK_FREQ/1000; -- 1 ms
	constant long_beep_period : natural := BOARD_CLK_FREQ; -- 1 sec
	constant short_beep_period : natural := BOARD_CLK_FREQ/5; -- 200 ms
	constant sound_freq_period : natural := BOARD_CLK_FREQ/2000; -- 0.5 ms (Fsnd = 2 kHz)
	--constant baud_period : integer := 325; -- default baud rate is 9600 (tick period 325)
	constant packet_bit_size : integer := 8;
	constant stop_bit_width : integer := 16;
begin

	sw_drv1: entity work.switch_driver(switch_driver_arch)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(0),
			FAE => sw1_left_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);
	
	sw_drv2: entity work.switch_driver(switch_driver_arch)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(1),
			FAE => sw2_right_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);

	sw_drv3: entity work.switch_driver(switch_driver_arch)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(2),
			FAE => sw3_next_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);

	sw_drv4: entity work.switch_driver(switch_driver_arch)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(3),
			FAE => sw4_prev_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);

	main_fsm: entity work.control_fsm(control_fsm_arch)
		generic map (
			SEND_TIMER_MAX => interval_100ms
		)
		port map (
			CLK => CLK,
			RST	=> RST_sig,
			SWK1_LEFT => sw1_left_sig,
			SWK2_RIGHT => sw2_right_sig,
			SWK3_NEXT => sw3_next_sig,
			SWK4_PREV => sw4_prev_sig,
			DOT => dot_sig,
			REG0 => digit0_sig,
			REG1 => digit1_sig,
			REG2 => digit2_sig,
			REG3 => digit3_sig,
			REG4 => digit4_sig,
			REG5 => digit5_sig,
			LED0_MODE => led0_mode_sig,
			LED1_MODE => led1_mode_sig,
			LED2_MODE => led2_mode_sig,
			LED3_MODE => led3_mode_sig,
			BEEP_MODE => beep_mode_sig,
			BEEP_RUN => beep_run_sig,
			RX_DATA => received_data_sig,
			RX_DATA_RDY => rx_data_ready_sig,
			RX_BUF_FULL => rx_buffer_full_sig,
			TX_BUF_FULL => tx_buffer_full_sig,
			TX_DATA => data_to_transmit_sig,
			TX_DATA_WR => write_to_fifo_sig,
			RX_DATA_ACK => rx_data_ack_sig
		);

	led0_drv: entity work.led_driver(led_driver_arch)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led0_mode_sig,
			LED => LED_sig(0)
		);
	
	led1_drv: entity work.led_driver(led_driver_arch)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led1_mode_sig,
			LED => LED_sig(1)
		);
	
	led2_drv: entity work.led_driver(led_driver_arch)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led2_mode_sig,
			LED => LED_sig(2)
		);
	
	led3_drv: entity work.led_driver(led_driver_arch)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led3_mode_sig,
			LED => LED_sig(3)
		);

	hexled_drv: entity work.hexled_driver(hexled_driver_arch)
		generic map (
			CNT_LIMIT => interval_1ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			DT0 => dot_sig(0),
			DT1 => dot_sig(1),
			DT2 => dot_sig(2),
			DT3 => dot_sig(3),
			DT4 => dot_sig(4),
			DT5 => dot_sig(5),
			DDI0 => digit0_sig,
			DDI1 => digit1_sig,
			DDI2 => digit2_sig,
			DDI3 => digit3_sig,
			DDI4 => digit4_sig,
			DDI5 => digit5_sig,
			SEG_DAT => SEG_data_sig,
			DIG_SEL => DIG_sel_sig
		);

	beep_drv: entity work.beep_driver(beep_driver_arch)
		generic map (
			SND_MODE => SND_MODE,
			SHB_PERIOD => short_beep_period,
			LOB_PERIOD => long_beep_period,
			SND_PERIOD => sound_freq_period
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			START => beep_run_sig,
			MODE => beep_mode_sig,
			BEEP => BPO_sig
		);
	
	uart_module: entity work.uart_module_fifo(uart_module_fifo_arch) 	
		generic map (
			BAUD_PERIOD => BAUD_PERIOD,
			PACKET_BIT_SIZE => packet_bit_size,
			STOP_BIT_WIDTH => stop_bit_width
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			WRF => write_to_fifo_sig,
			DIN => data_to_transmit_sig,
			TXO => TXO_sig,
			RXI => RXI_sig,
			FFL => tx_buffer_full_sig,
			RXD => received_data_sig,
			RXF => rx_data_ready_sig, 
			FBF => rx_buffer_full_sig,
			RXR => rx_data_ack_sig	
		);
		
	-- input adaptation (positive or negative logic format depending on dev board schematic)
	-- switches/keys operate with negative logic (0 = press, 1 = release)
	RST_sig <= not RST;
	SWI_sig <= not SWI;
	-- LEDs operate with positive logic (0 = off, 1 = on)
	LDO <= LED_sig;
	-- buzzer operates with negative logic
	BPO <= not BPO_sig;
	-- hexled display circuit needs drive signals to be negated
	SEG <= not SEG_data_sig;
	DIG <= not DIG_sel_sig;
	-- uart signals
	TXO <= TXO_sig;
	RXI_sig <= RXI;

end architecture;