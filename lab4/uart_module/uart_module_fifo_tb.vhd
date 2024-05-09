library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_module_fifo_tb is
end entity;

architecture uart_module_fifo_tb_arch of uart_module_fifo_tb is
	-- setup generics
	constant BAUD_PERIOD : integer := 325; -- default baud rate is 9600 (tick period 325)
	constant PACKET_BIT_SIZE : integer := 8;
	constant STOP_BIT_WIDTH : integer := 16;
	-- setup clock 
	constant clk_period : time := 20 ns;
	-- stimulus signals
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal write_tx_fifo : std_logic := '0';  -- start transmitting
	signal test_data : std_logic_vector (PACKET_BIT_SIZE-1 downto 0) := (others => '0'); -- data to transmit
	-- observed signals
	signal serial_line : std_logic;	-- tx serial out -> rx serial in
	signal tx_fifo_full : std_logic; -- transmitter busy
	signal rx_fifo_full : std_logic; -- receiver fifo buffer is full
	signal received_data : std_logic_vector (PACKET_BIT_SIZE-1 downto 0); -- received data
	signal receive_acknoledge : std_logic;-- received data ready - received data acknowledge
	-- special signals
    type dv_type_array is array (0 to 2**3-1) of std_logic_vector(PACKET_BIT_SIZE-1 downto 0);
    signal data_vault : dv_type_array := (x"1A", x"2B", x"3C", x"4D", x"5E", x"6F", x"70", x"81");
    signal data_collector : dv_type_array := (others => (others => '0'));
begin
	
	uut: entity work.uart_module_fifo(uart_module_fifo_arch)
	generic map (
		BAUD_PERIOD => BAUD_PERIOD,
		PACKET_BIT_SIZE => PACKET_BIT_SIZE,
		STOP_BIT_WIDTH => STOP_BIT_WIDTH
	)
	port map (
		CLK => clk,
		RST => rst,
		WRF => write_tx_fifo,
		DIN => test_data, 
		TXO => serial_line, 
		RXI => serial_line, 
		FFL => tx_fifo_full,
		RXD => received_data, 
		RXF => receive_acknoledge, 
		FBF => rx_fifo_full,
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
		
		-- set packet to transmit -- test write 6 packets
        for i in 0 to 5 loop
            test_data <= data_vault(i);
            write_tx_fifo <= '1';
            wait for clk_period;
            write_tx_fifo <= '0';
            wait for clk_period;
        end loop;
		
		wait for 6400 us;	
		
		-- set packet to transmit -- test write 6 packets
        for i in 0 to 5 loop
            test_data <= data_vault(i);
            write_tx_fifo <= '1';
            wait for clk_period;
            write_tx_fifo <= '0';
            wait for clk_period;
        end loop;
		
		
		wait; -- stop forever
	end process;
	
end architecture;