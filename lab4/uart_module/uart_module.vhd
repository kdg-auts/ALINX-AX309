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