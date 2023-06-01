-- project: lab0 - demo and introduction
-- file: kx_module_testbench.vhd
-- description:
--    simple combinatorial module description; main purpose: to get
--    familiar with design flow and development environment

library IEEE;
use IEEE.std_logic_1164.all;

entity kxx_module is
	port (
		x: in std_logic_vector(3 downto 0);
		y: out std_logic_vector(3 downto 0)
	);
end entity;

architecture kxx_module_arch of kxx_module is
	signal int_x , int_y: std_logic_vector(3 downto 0);
begin
	-- input adaptation: due to circuit features buttons operate in reverse logic
	--int_x <= not x; 
	int_x <= x;

	-- output adaptation: this dev board does not need to reverse logic for LEDs
	--y <= not int_y;
	y <= int_y;

	-- functional load of module
	int_y <= "1101" when int_x = "0000" else
	         "0010" when int_x = "0001" else
	         "1000" when int_x = "0010" else
	         "0100" when int_x = "0011" else
	         "0110" when int_x = "0100" else
	         "1111" when int_x = "0101" else
	         "1011" when int_x = "0110" else
	         "0001" when int_x = "0111" else
	         "1010" when int_x = "1000" else
	         "1001" when int_x = "1001" else
	         "0011" when int_x = "1010" else
	         "1110" when int_x = "1011" else
	         "0101" when int_x = "1100" else
	         "0000" when int_x = "1101" else
	         "1100" when int_x = "1110" else
	         "0111";
	
	end architecture;
