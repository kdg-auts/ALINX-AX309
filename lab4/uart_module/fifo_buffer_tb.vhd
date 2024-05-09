library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity fifo_buffer_tb is
end entity;

architecture fifo_buffer_tb_arch of fifo_buffer_tb is
	-- setup generics
	constant BUS_WIDTH : integer := 8;
	constant ADDR_LENGTH : integer := 3;
	-- setup clock 
	constant clk_period : time := 20 ns;
	-- stimulus signals
	signal clk : std_logic;
	signal rst : std_logic;
	signal read_data : std_logic := '0';  -- read from fifo action
    signal write_data : std_logic := '0';  -- write to fifo action
	signal data_in : std_logic_vector(BUS_WIDTH-1 downto 0) := (others => '0'); -- data to write
	-- observed signals
	signal fifo_empty : std_logic;	-- tx serial out -> rx serial in
	signal fifo_full : std_logic; -- transmitter busy
	signal data_out : std_logic_vector (BUS_WIDTH-1 downto 0); -- received data
    -- special signals
    type dv_type_array is array (0 to 2**ADDR_LENGTH-1) of std_logic_vector(BUS_WIDTH-1 downto 0);
    signal data_vault : dv_type_array := (x"1A", x"2B", x"3C", x"4D", x"5E", x"6F", x"70", x"81");
    signal data_collector : dv_type_array := (others => (others => '0'));
begin
	
	uut: entity work.fifo_buffer(fifo_buffer_arch)
	generic map (
		BUS_WIDTH => BUS_WIDTH,
		ADDR_LENGTH => ADDR_LENGTH
	)
	port map (
		CLK => clk,
		RST => rst,
		RD => read_data,
		WR => write_data,
		DI => data_in,
		EMPT => fifo_empty,
		FULL => fifo_full,
		DO => data_out
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
		
		-- test write untill full
        for i in 0 to data_vault'length-1 loop
            if fifo_full = '1' then
                report "unexpected fifo is full during fullfilment!" severity ERROR;
                exit;
            end if;
            data_in <= data_vault(i);
            write_data <= '1';
            wait for clk_period;
            write_data <= '0';
            wait for clk_period;
        end loop; 

        assert fifo_full = '1' report "fifo is not full after exhaustive write!" severity ERROR;

        -- test read untill empty
        for i in 0 to data_collector'length-1 loop
            if fifo_empty = '1' then
                report "unexpected fifo is empty during exhaustive read!" severity ERROR;
                exit;
            end if;
            data_collector(i) <= data_out;
            read_data <= '1';
            wait for clk_period;
            read_data <= '0';
            wait for clk_period;
        end loop; 
		
        assert fifo_empty = '1' report "fifo is not empty after exhaustive read!" severity ERROR;

		wait; -- stop forever
	end process;
	
end architecture;