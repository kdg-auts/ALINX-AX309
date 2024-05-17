-- project: lab4 - uart demo
-- file: uart_module.vhd
-- description:
--  Module combines receiver and transmitter and additional infrastructure (logic and registers)
--  to provide errorless transmittion and receiving data .

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_module_fifo is
	generic (
		BAUD_PERIOD : integer := 325; -- default baud rate is 9600 (tick period 325)
		PACKET_BIT_SIZE : integer := 8;
		STOP_BIT_WIDTH : integer := 16
	);
	port (
		CLK: in std_logic;
		RST: in std_logic;
		WRF: in std_logic; -- write to fifo (start transmitting)
		DIN: in std_logic_vector (PACKET_BIT_SIZE-1 downto 0); -- data to transmit
		TXO: out std_logic; -- tx serial out
		RXI: in std_logic;  -- rx serial in
		FFL: out std_logic;	-- transmitter fifo buffer is full
		RXD: out std_logic_vector (PACKET_BIT_SIZE-1 downto 0); -- received data
		RXF: out std_logic; -- received data ready
		FBF: out std_logic; -- receiver buffer is full
		RXR: in std_logic -- received data acknowledge	
	);
end entity;

architecture uart_module_fifo_arch of uart_module_fifo is
	signal baud_tick_sig : std_logic;
	signal rx_data_ready_sig : std_logic;
	signal rx_data_sig : std_logic_vector (PACKET_BIT_SIZE-1 downto 0);
	signal start_tx_sig : std_logic;
	signal read_tx_fifo_sig : std_logic;
	signal tx_is_busy_sig : std_logic;
	signal fifo_empty_sig : std_logic;
	signal fifo_full_sig : std_logic;
	signal data_to_tx_sig : std_logic_vector (PACKET_BIT_SIZE-1 downto 0);
	signal finish_tx_sig : std_logic;
	signal rx_fifo_ready_sig : std_logic;
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
	
	tx_buffer: entity work.fifo_buffer(fifo_buffer_arch)
	generic map (
		BUS_WIDTH => PACKET_BIT_SIZE,
		ADDR_LENGTH => 3 -- fifo depth should be 8 cells
	)
	port map (
		CLK => CLK,
		RST => RST,
		RD => read_tx_fifo_sig,
		WR => WRF,
		DI => DIN,
		EMPT => fifo_empty_sig,
		FULL => fifo_full_sig,
		DO => data_to_tx_sig
	);
	
	rx_buffer: entity work.fifo_buffer(fifo_buffer_arch)
	generic map (
		BUS_WIDTH => PACKET_BIT_SIZE,
		ADDR_LENGTH => 1 -- fifo depth should be 2 cells
	)
	port map (
		CLK => CLK,
		RST => RST,
		RD => RXR,
		WR => rx_data_ready_sig,
		DI => rx_data_sig,
		EMPT => rx_fifo_ready_sig,
		FULL => FBF,
		DO => RXD
	);
	
	tx_control: process(CLK, RST)
	begin
		if RST = '1' then 
			start_tx_sig <= '0';
			read_tx_fifo_sig <= '0';
			tx_is_busy_sig <= '0';
		elsif CLK'event and CLK = '1' then
			if fifo_empty_sig = '0' and tx_is_busy_sig = '0' then
				start_tx_sig <= '1';
				read_tx_fifo_sig <= '1';
				tx_is_busy_sig <= '1';
			else 
				start_tx_sig <= '0';
				read_tx_fifo_sig <= '0'; 
			end if;
			if finish_tx_sig = '1' then
				tx_is_busy_sig <= '0';
			end if;
		end if;
	end process;
	
	--start_tx_sig <= not fifo_empty_sig;
	FFL <= fifo_full_sig;
	RXF <= not rx_fifo_ready_sig;
	
end architecture;