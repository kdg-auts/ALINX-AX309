-- project: lab4 - uart demo
-- file: uart_transmitter.vhd
-- description:
--  Module performs serial bit by bit transmission of parallel loaded byte.
--  Bits are tranmitted according to baud generator ticks.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_transmitter is
	generic (
		PACKET_BIT_SIZE : integer := 8; -- # data bits
		STOP_BIT_WIDTH : integer := 16 -- # ticks for stop bits
	);
	port (
		CLK: in std_logic;
		RST: in std_logic;
		STX: in std_logic;
		BDT: in std_logic;
		DIN: in std_logic_vector (PACKET_BIT_SIZE-1 downto 0);
		FTX: out std_logic;
		TXO: out std_logic
	);
end entity;

architecture uart_transmitter_arch of uart_transmitter is
	type state_type is (idle, startbit, databits, stopbit);
	signal state_reg, state_next : state_type;
	signal baud_tick_count_reg, baud_tick_count_next : unsigned(3 downto 0);
	signal bit_count_reg, bit_count_next : unsigned(2 downto 0);
	signal tx_byte_reg, tx_byte_next : std_logic_vector(PACKET_BIT_SIZE-1 downto 0);
	signal tx_bit_reg, tx_bit_next : std_logic;
	signal FTX_next : std_logic;
begin
	-- transmitter state and data registers update
	fsm_update: process (CLK, RST)
	begin
		if RST = '1' then
			state_reg <= idle;
			baud_tick_count_reg <= (others => '0');
			bit_count_reg <= (others => '0');
			tx_byte_reg <= (others => '0');
			tx_bit_reg <= '1';
			FTX <= '0';
		elsif CLK'event and CLK = '1' then
			state_reg <= state_next;
			baud_tick_count_reg <= baud_tick_count_next;
			bit_count_reg <= bit_count_next;
			tx_byte_reg <= tx_byte_next;
			tx_bit_reg <= tx_bit_next;
			FTX <= FTX_next;
		end if;
	end process;

	-- transmitter FSM logic
	fsm_tx_core: process (state_reg, baud_tick_count_reg, bit_count_reg, tx_byte_reg, BDT, tx_bit_reg, STX, DIN)
	begin
		-- default values
		state_next <= state_reg;
		baud_tick_count_next <= baud_tick_count_reg;
		bit_count_next <= bit_count_reg;
		tx_byte_next <= tx_byte_reg;
		tx_bit_next <= tx_bit_reg;
		FTX_next <= '0';

		case state_reg is
			
			when idle =>
				tx_bit_next <= '1'; -- default state on TX line
				if STX = '1' then -- new data is ready to transmit
					state_next <= startbit;
					baud_tick_count_next <= (others => '0');
					tx_byte_next <= DIN; -- latch data to internal register
				end if;
			
			when startbit =>
				tx_bit_next <= '0'; -- form start bit
				if BDT = '1' then
					if baud_tick_count_reg = 15 then
						state_next <= databits;
						baud_tick_count_next <= (others => '0');
						bit_count_next <= (others => '0');
					else
						baud_tick_count_next <= baud_tick_count_reg + 1;
					end if;
				end if;

			when databits =>
				tx_bit_next <= tx_byte_reg(0);
				if BDT = '1' then
					if baud_tick_count_reg = 15 then
						baud_tick_count_next <= (others => '0');
						tx_byte_next <= '0' & tx_byte_reg(PACKET_BIT_SIZE-1 downto 1);
						if bit_count_reg = PACKET_BIT_SIZE-1 then
							state_next <= stopbit;
						else
							bit_count_next <= bit_count_reg + 1;
						end if;
					else
						baud_tick_count_next <= baud_tick_count_reg + 1;
					end if;
				end if;
			
			when stopbit =>
				tx_bit_next <= '1';
				if BDT = '1' then
					if baud_tick_count_reg = STOP_BIT_WIDTH-1 then
						state_next <= idle;
						FTX_next <= '1';
					else
						baud_tick_count_next <= baud_tick_count_reg + 1;
					end if;
				end if;

		end case;
	end process;
	
	TXO <= tx_bit_reg;

end architecture;