library IEEE;
use IEEE.std_logic_1164.all;

entity buf_flag_register is
	generic(
		data_width : integer := 8
	);
	port(
		CLK : in std_logic;
		RST : in std_logic;
		CLF : in std_logic;
		STF : in std_logic;
		DTI : in std_logic_vector(data_width-1 downto 0);
		DTO : out std_logic_vector(data_width-1 downto 0);
		FLG : out std_logic
	);
end entity;

architecture buf_flag_register_arch of buf_flag_register is
begin
	process(CLK, RST)
	begin
		if RST = '1' then
			data_reg <= (others => '0');
			flag_reg <= '0';
		elsif (CLK'event and CLK = '1') then
			data_reg <= data_reg_next;
			flag_reg <= flag_reg_next;
		end if;
	end process;

	process(data_reg, flag_reg, CLF, STF, DTI)
	begin
		if STF = '1' then
			data_reg_next <= DTI;
			flag_reg_next <= '1';
		elsif CLF = '1' then
			flag_reg_next <= '1';
		else
			data_reg_next <= data_reg;
			flag_reg_next <= flag_reg;
		end if;
	end process;
end architecture;