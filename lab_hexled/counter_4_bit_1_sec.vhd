----------------------------------------------------------------------------------
-- Create Date    : 20:12:42 08/25/2020 
-- Design Name    : lab_hexled
-- Module Name    : counter_4_bit_1_sec - counter_4_bit_1_sec_arch 
-- Project Name   : lab_sbox_on_hexled
-- Target Devices : xc6slx9
-- Description: 
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity counter_4_bit_1_sec is
    generic (
		H_PERIOD: integer := 50000000 -- 50M counts of clk = 1 sec
	);
    port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        cdata : out  STD_LOGIC_VECTOR (3 downto 0)
    );
end counter_4_bit_1_sec;

architecture counter_4_bit_1_sec_arch of counter_4_bit_1_sec is
    signal h_count: integer range 0 to H_PERIOD-1;
	signal h_value: unsigned(3 downto 0) := (others => '0');
begin
    -- ??????? ???????? ? ???????????? ??????? ?????????? S-Box
    process(clk, rst)
	begin
		if rising_edge(clk) then 
			if rst = '1' then 
				h_count <= 0;
				h_value <= (others => '0');
			elsif h_count = H_PERIOD-1 then
				h_count <= 0;
				h_value <= h_value + 1;
			else 
				h_count <= h_count + 1;
			end if;
		end if;
	end process;
    
    -- ???????????? ??????? ?????????? S-Box
    cdata <= std_logic_vector(h_value);

end counter_4_bit_1_sec_arch;

