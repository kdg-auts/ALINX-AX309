-- project: lab0 - demo and introduction
-- file: kx_module_testbench.vhd
-- description:
--    functional verivication of module kx_module
--    main purpose is to get familiar with running testbenches
--    and perform functional verification

library IEEE;
use IEEE.std_logic_1164.all;

entity kxx_module_tb is
end entity;

architecture kxx_module_tb_arch of kxx_module_tb is

	-- component declaration for the Unit Under Test (UUT)
	component kxx_module
		port (
			x : in std_logic_vector(3 downto 0);
			y : out std_logic_vector(3 downto 0)
		);
	end component;

	--input signals
	signal t_x : std_logic_vector(3 downto 0) := (others => '0');

	--output signals
	signal t_y : std_logic_vector(3 downto 0);

begin

	-- instantiate the Unit Under Test (UUT)
	uut: kxx_module
		port map (
			x => t_x,
 			y => t_y
		);

	-- stimulus process
	stim_proc: process
	begin
		t_x <= "0000";
		wait for 10 ns;
		t_x <= "0001";
		wait for 10 ns;
		t_x <= "0010";
		wait for 10 ns;
		t_x <= "0011";
		wait for 10 ns;
		t_x <= "0100";
		wait for 10 ns;
		t_x <= "0101";
		wait for 10 ns;
		t_x <= "0110";
		wait for 10 ns;
		t_x <= "0111";
		wait for 10 ns;
		t_x <= "1000";
		wait for 10 ns;
		t_x <= "1001";
		wait for 10 ns;
		t_x <= "1010";
		wait for 10 ns;
		t_x <= "1011";
		wait for 10 ns;
		t_x <= "1100";
		wait for 10 ns;
		t_x <= "1101";
		wait for 10 ns;
		t_x <= "1110";
		wait for 10 ns;
		t_x <= "1111";
		wait;
	end process;

end architecture;
