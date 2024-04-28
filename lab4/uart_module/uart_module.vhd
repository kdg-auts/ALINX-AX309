-- project: lab4 - uart demo
-- file: uart_module.vhd
-- description:
--  Module combines receiver and transmitter and additional infrastructure (logic and registers)
--  to provide errorless transmittion and receiving data .

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_module is
	generic (
		--DBIT : integer := 8; -- # data bits
		--SB_TICK : integer := 16 -- # ticks for stop bits
		BAUD_PERIOD : integer := 325; -- default baud rate is 9600 (tick period 325)
		PACKET_BIT_SIZE : integer := 8;
		STOP_BIT_WIDTH : integer := 16
	);
	port (
		CLK: in std_logic;
		RST: in std_logic;
		STX: in std_logic; -- start transmitting
		DIN: in std_logic_vector (PACKET_BIT_SIZE-1 downto 0); -- data to transmit
		TXO: out std_logic; -- tx serial out
		RXI: in std_logic;  -- rx serial in
		TXB: out std_logic;	-- transmitter busy
		RXD: out std_logic_vector (PACKET_BIT_SIZE-1 downto 0); -- received data
		RXF: out std_logic; -- received data ready
		RXR: in std_logic -- received data acknowledge	
	);
end entity;

architecture uart_module_arch of uart_module is
	signal baud_tick_sig : std_logic;
	signal rx_data_ready_sig : std_logic;
	signal rx_data_sig : std_logic_vector (PACKET_BIT_SIZE-1 downto 0);
	signal start_tx_sig : std_logic;
	signal data_to_tx_sig : std_logic_vector (PACKET_BIT_SIZE-1 downto 0);
	signal finish_tx_sig : std_logic;
begin
	
	baud_gen_unit: entity work.baud_generator(baud_generator_arch)
	generic map (
		BAUD_PERIOD => BAUD_PERIOD
	)
	port map (
		CLK => CLK,
		RST => RST,
		BDT => baud_tick_sig
	);

	receive_unit: entity work.uart_receiver(uart_receiver_arch)
	generic map (
		PACKET_BIT_SIZE => PACKET_BIT_SIZE,
		STOP_BIT_WIDTH => STOP_BIT_WIDTH
	)
	port map (
		CLK => CLK,
		RST => RST,
		RXI => RXI, -- input port
		BDT => baud_tick_sig, 
		RDY => rx_data_ready_sig, 
		PDO => rx_data_sig
	);
	
	transmit_unit: entity work.uart_transmitter(uart_transmitter_arch)
	generic map (
		PACKET_BIT_SIZE => PACKET_BIT_SIZE,
		STOP_BIT_WIDTH => STOP_BIT_WIDTH
	)
	port map (
		CLK => CLK,
		RST => RST,
		STX => start_tx_sig,
		BDT => baud_tick_sig,
		DIN => data_to_tx_sig,
		FTX => finish_tx_sig,
		TXO => TXO
	);
	
	tx_buffer: entity work.buf_flag_register(buf_flag_register_arch)
	generic map (
		PACKET_BIT_SIZE => PACKET_BIT_SIZE
	)
	port map (
		CLK => CLK,
		RST => RST,
		CLF => finish_tx_sig,
		STF => STX,
		DTI => DIN,
		DTO => data_to_tx_sig,
		FLG => start_tx_sig
	);
	
	rx_buffer: entity work.buf_flag_register(buf_flag_register_arch)
	generic map (
		PACKET_BIT_SIZE => PACKET_BIT_SIZE
	)
	port map (
		CLK => CLK,
		RST => RST,
		CLF => RXR, -- input port
		STF => rx_data_ready_sig,
		DTI => rx_data_sig,
		DTO => RXD, --output port
		FLG => RXF	--output port
	);
	
	TXB <= start_tx_sig;
	
end architecture;