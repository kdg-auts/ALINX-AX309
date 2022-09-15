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
		PACKET_BIT_SIZE : : integer := 8;
		STOP_BIT_WIDTH : integer := 16
	);
	port (
		CLK: in std_logic;
		RST: in std_logic;
		STX: in std_logic;
		BDT: in std_logic;
		DIN: in std_logic_vector (7 downto 0);
		FTX: out std_logic;
		TXO: out std_logic
	);
end entity;

architecture uart_module_arch of uart_module is
	signal 
	signal BDT_sig
begin
	baud_gen_unit: entity work.baud_generator(baud_generator_arch)
	generic map (
		BAUD_PERIOD => BAUD_PERIOD
	)
	port map (
		CLK => CLK,
		RST => RST,
		BDT => BDT_sig
	);

	receive_unit: entity work.uart_receiver(uart_receiver_arch)
	generic map (
		PACKET_BIT_SIZE => PACKET_BIT_SIZE,
		STOP_BIT_WIDTH => STOP_BIT_WIDTH
	)
	port map (
		CLK => CLK,
		RST => RST,
		RXI: in std_logic;
		BDT: in std_logic;
		RDY: out std_logic; 
		PDO: out std_logic_vector(7 downto 0)
	);
end architecture;