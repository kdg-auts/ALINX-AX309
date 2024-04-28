library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_module_tb is
end entity;

architecture uart_module_tb_arch of uart_module_tb is
	-- setup generics
	constant BAUD_PERIOD : integer := 325; -- default baud rate is 9600 (tick period 325)
	constant PACKET_BIT_SIZE : integer := 8;
	constant STOP_BIT_WIDTH : integer := 16;
	-- setup clock 
	constant clk_period : time := 20 ns;
	-- stimulus signals
	signal clk : std_logic;
	signal rst : std_logic;
	signal start_tx : std_logic;  -- start transmitting
	signal test_data : std_logic_vector (PACKET_BIT_SIZE-1 downto 0); -- data to transmit
	-- observed signals
	signal serial_line : std_logic;	-- tx serial out -> rx serial in
	signal tx_is_busy : std_logic; -- transmitter busy
	signal received_data : std_logic_vector (PACKET_BIT_SIZE-1 downto 0); -- received data
	signal receive_acknoledge : std_logic;-- received data ready - received data acknowledge
begin
	
	uut: entity work.uart_module(uart_module_arch)
	generic map (
		BAUD_PERIOD => BAUD_PERIOD,
		PACKET_BIT_SIZE => PACKET_BIT_SIZE,
		STOP_BIT_WIDTH => STOP_BIT_WIDTH
	)
	port map (
		CLK => clk,
		RST => rst,
		STX => start_tx,
		DIN => test_data, 
		TXO => serial_line, 
		RXI => serial_line, 
		TXB => tx_is_busy,	
		RXD => received_data, 
		RXF => receive_acknoledge, 
		RXR => receive_acknoledge  
	);

	-- clock waveform generator
	clk_gen_proc: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- reset signal generator
	rst_gen_proc: process
	begin
		rst <= '1';
		wait for clk_period*2;
		rst <= '0';
		wait;
	end process;
	
	stim_gen_proc: process
	begin
		wait until rst = '0'; -- work only after reset
        wait for clk_period*10;
		
		-- set packet to transmit
		report "First TX-RX cycle begin" severity NOTE;
		test_data <= x"AA";
		start_tx <= '1';
		wait for clk_period;
		start_tx <= '0';
        wait until receive_acknoledge = '1';
		
		assert received_data = test_data report "First TX-RX cycle failed!" severity FAILURE;
		
		wait for clk_period*5200;	
		-- set packet to transmit 
		report "Second TX-RX cycle begin" severity NOTE;
		test_data <= x"55";
		start_tx <= '1';
		wait for clk_period;
		start_tx <= '0';
        wait until receive_acknoledge = '1';
		
		assert received_data = test_data report "Second TX-RX cycle failed!" severity FAILURE;

		wait; -- stop forever
	end process;
	
end architecture;