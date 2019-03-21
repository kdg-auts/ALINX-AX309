----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:28:54 03/21/2019 
-- Design Name: 
-- Module Name:    NTLM - NTLM_Arch 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NTLM is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           KN : in  STD_LOGIC_VECTOR (3 downto 0);
           LED : out  STD_LOGIC_VECTOR (3 downto 0));
end NTLM;

architecture NTLM_Arch of NTLM is

	signal KN_sig: STD_LOGIC_VECTOR (3 downto 0);
	signal RST_sig: STD_LOGIC;

begin

U1: entity work.TopLevel_Module(TLM_arch)
		port map ( 
			clk    => clk,
			rst	   => rst_sig,
			KN     => KN_sig(0), 
			LED_OUT  => LED(0)
		);

U2: entity work.TopLevel_Module(TLM_arch)
		port map ( 
			clk    => clk,
			rst	   => rst_sig,
			KN     => KN_sig(1), 
			LED_OUT  => LED(1)
		);

U3: entity work.TopLevel_Module(TLM_arch)
		port map ( 
			clk    => clk,
			rst	   => rst_sig,
			KN     => KN_sig(2), 
			LED_OUT  => LED(2)
		);
		
U4: entity work.TopLevel_Module(TLM_arch)
		port map ( 
			clk    => clk,
			rst	   => rst_sig,
			KN     => KN_sig(3), 
			LED_OUT  => LED(3)
		);

	rst_sig <= not RST;
	KN_sig <= not KN;

end NTLM_Arch;

