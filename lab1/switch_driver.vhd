library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity switch_driver is		 
	
	generic (
		LP_COUNT_PERIOD: integer := 50000000;
		SWS_COUNT_PERIOD: integer :=100000
		);
	
	port (
		clk : in std_logic;
		rst	: in std_logic;
		sw : in std_logic;
		Redge : out std_logic;
		Fedge	: out std_logic;
		LVL	: out std_logic;
		Toggle	: out std_logic;
		LPress	: out std_logic
		);
end switch_driver;	 

architecture switch_drv_arch of switch_driver is
	signal SW_state : std_logic_vector (5 downto 0);	
	signal SWA_state : std_logic;  
	signal SW_Toggle : std_logic;
	signal LP_Count : integer range 0 to LP_COUNT_PERIOD-1;
	signal SWS_Count : integer range 0 to SWS_COUNT_PERIOD-1; 
	signal en, lpce : std_logic;
	
begin
	
	SWS_Counter: process (clk, rst)
	begin
		if rising_edge(clk) then
			if rst ='1' then
				SWS_Count <= 0;
				en <= '0';
			elsif SWS_Count = SWS_COUNT_PERIOD-1 then
				en <= '1';
				SWS_Count <= 0;
			else
				en <= '0';
				SWS_Count <= SWS_Count + 1;
			end if;
		end if; 
	end process;	
	
	LP_Counter: process (clk, rst) 
	begin
		if rising_edge(clk) then
			if rst ='1' then
				LP_Count <= 0;
				LPress <= '0';
			elsif lpce = '1' then
				if LP_Count = LP_COUNT_PERIOD-1 then
					LPress <= '1';
					LP_Count <= 0;
				else
					LPress <= '0';
					LP_Count <= LP_Count + 1;
				end if;	
				
			else 
				LP_Count <= 0;
				LPress <= '0';
			end if;	
		end if;
	end process;
	
	SREG6: process (clk, rst) 
	begin
		if rising_edge(clk) then
			if rst ='1' then
				sw_state <= (others => '0');
			elsif en = '1'  then
				sw_state <= sw_state (4 downto 0)& sw;	
			end if;	
		end if;
	end process;
	
	SWA: process (clk, rst)
	begin
		if rising_edge (clk) then 
			if rst = '1' then
				SWA_state <= '0';
				Redge <= '0';
				Fedge <= '0';
				LVL <= '0';
				SW_Toggle <= '0';
			else
				case SWA_STATE is 
					when '0' => 
						if sw_state = "111111" then
							LPCE <= '1';
							SW_Toggle <= not SW_Toggle;
							LVL <= '1';
							SWA_STATE <='1';
							Redge <= '1';
						else
							Fedge <= '0';
						end if;
					when '1' => 
						if sw_state = "000000" then
							Fedge <= '1';
							lpce <= '0';
							LVL <= '0';
							SWA_STATE <= '0';
						else
							Redge <= '0';
						end if;
					when others =>
						null;
				end case;	  
			end if; 
		end if;
	end process;
	 Toggle <= SW_Toggle;
end architecture switch_drv_arch;
