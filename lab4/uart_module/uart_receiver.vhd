-- project: lab4 - uart demo
-- file: uart_receiver.vhd
-- description:
--    Module samples data input, determines start bit, values of all data bits
--    and stop bit. Parity bit receiving and checking  is not supported.

library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD.all;
 
entity uart_receiver is
	generic ( 
		PACKET_BIT_SIZE : integer := 8;
		STOP_BIT_WIDTH : integer := 16
	);
	port (
		CLK : in std_logic;
		RST: in std_logic;
		RXI: in std_logic;
		BDT: in std_logic;
		RDY: out std_logic; 
		PDO: out std_logic_vector(PACKET_BIT_SIZE-1 downto 0)
	);
end entity;

architecture uart_receiver_arch of uart_receiver is 
	type state_type is (idle, startbit, databits, stopbit);
	signal state_reg, state_next: state_type;
	signal sample_count_reg, sample_count_next: unsigned(3 downto 0);
	signal bit_count_reg, bit_count_next: unsigned(2 downto 0);
	signal rx_data_reg, rx_data_next: std_logic_vector(PACKET_BIT_SIZE-1 downto 0);
begin
	
	-- receiver FSM & registers update
	fsm_update: process (CLK, RST)
	begin
		if RST = '1' then 
			state_reg <= idle;
			sample_count_reg <= (others => '0');
			bit_count_reg <= (others => '0');
			rx_data_reg <= (others => '0');
		elsif CLK'event and CLK = '1' then
			state_reg <= state_next;
			sample_count_reg <= sample_count_next;
			bit_count_reg <= bit_count_next;
			rx_data_reg <= rx_data_next; 
		end if;
	end process;
	
	-- receiver FSM logic
	fsm_rx_core: process (state_reg, sample_count_reg, bit_count_reg, rx_data_reg, BDT, RXI)
	begin
		-- set dafault values 
		state_next <= state_reg;
		sample_count_next <= sample_count_reg;
		bit_count_next <= bit_count_reg;
		rx_data_next <= rx_data_reg;
		RDY <= '0';

		case state_reg is

			when idle => 
				if RXI = '0' then -- active edge of start bit detected
					state_next <= startbit;
					sample_count_next <= ( others => '0');
				end if;

			when startbit => 
				if BDT = '1' then
					if sample_count_reg = 7 then -- middle of start bit
						if RXI = '0' then -- data line is in LOW state - start bit confirmed
							state_next <= databits;
							sample_count_next <= (others => '0');
							bit_count_next <= (others => '0');
						else -- false reaction: it is not start bit
							state_next <= idle;
						end if;
					else
						sample_count_next <= sample_count_reg + 1;
					end if;
				end if;

			when databits =>
				if BDT = '1' then
					if sample_count_reg = 15 then -- middle of data bit (16 sample ticks since middle of previous bit)
						sample_count_next <= (others => '0');
						rx_data_next <= RXI & rx_data_reg(PACKET_BIT_SIZE-1 downto 1); -- record current bit value to data register
						if bit_count_reg = (PACKET_BIT_SIZE-1) then -- all data bits are sampled - verify stopbit
							state_next <= stopbit;
						else
							bit_count_next <= bit_count_reg + 1;
						end if;
					else 
						sample_count_next <= sample_count_reg + 1;
					end if;
				end if;

			when stopbit =>
				if BDT = '1' then
					if sample_count_reg = (STOP_BIT_WIDTH-1) then -- just count stop bit length
						state_next <= idle;
						RDY <= '1';
					else
						sample_count_next <= sample_count_reg + 1;
					end if;
				end if;
		end case;
	end process;
	
	-- parallel data output
	PDO <= rx_data_reg;

end architecture;
