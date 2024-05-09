library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity fifo_buffer is 
	generic( 
		BUS_WIDTH: natural := 8; -- number of bits 
		ADDR_LENGTH: natural := 4 -- number of address bits 
	); 
	port ( 
		CLK  : in std_logic;
		RST  : in std_logic;
		RD   : in std_logic;
		WR   : in std_logic;
		DI   : in std_logic_vector (BUS_WIDTH-1 downto 0); 
		EMPT : out std_logic; 
		FULL : out std_logic;
		DO   : out std_logic_vector (BUS_WIDTH-1 downto 0) 
	); 
end entity;

architecture fifo_buffer_arch of fifo_buffer is 
	type reg_file_type is array (2**ADDR_LENGTH-1 downto 0) of std_logic_vector(BUS_WIDTH-1 downto 0); 
	signal array_reg : reg_file_type; 
	signal write_ptr_reg, write_ptr_next, write_ptr_succ : std_logic_vector(ADDR_LENGTH-1 downto 0); 
	signal read_ptr_reg, read_ptr_next, read_ptr_succ : std_logic_vector(ADDR_LENGTH-1 downto 0);
	signal full_reg, empty_reg, full_next, empty_next : std_logic; 
	signal wr_op : std_logic_vector (1 downto 0); 
	signal wr_en : std_logic; 
begin  
	process (CLK, RST) 
	begin 
		if RST = '1' then 
			array_reg <= (others => ( others=> '0'));
		elsif CLK'event and CLK = '1' then 
			if wr_en = '1' then 
				array_reg(to_integer(unsigned(write_ptr_reg))) <= DI; 
			end if; 
		end if; 
	end process; 
	
	-- read port 
	DO <= array_reg(to_integer(unsigned(read_ptr_reg))); 
    -- write enabled only when FIFO is not full 
	wr_en <= WR and (not full_reg);
	
	-- register for read and write pointers 
	process (CLK, RST)  
	begin 
		if RST = '1' then 
			write_ptr_reg <= (others => '0'); 
			read_ptr_reg <= (others => '0'); 
			full_reg <= '0'; 
			empty_reg <= '1'; 
		elsif CLK'event and CLK = '1' then
			write_ptr_reg <= write_ptr_next; 
			read_ptr_reg <= read_ptr_next; 
			full_reg <= full_next; 
			empty_reg <= empty_next; 
		end if; 
	end process;
	
	-- successive pointer values 
	write_ptr_succ <= std_logic_vector(unsigned(write_ptr_reg) + 1); 
	read_ptr_succ <= std_logic_vector(unsigned(read_ptr_reg) + 1); 
	
	-- next-state logic for read and write pointers 
	wr_op <= WR & RD; 
	process (write_ptr_reg, write_ptr_succ, read_ptr_reg, read_ptr_succ, wr_op, empty_reg , full_reg)
	begin 
		write_ptr_next <= write_ptr_reg; 
		read_ptr_next <= read_ptr_reg; 
		full_next <= full_reg; 
		empty_next <= empty_reg ; 
		
		case wr_op is 
			when "00" => -- no op 
			when "01" => -- read 
				if empty_reg /= '1' then -- not empty 
					read_ptr_next <= read_ptr_succ; 
					full_next <= '0'; 
					if read_ptr_succ = write_ptr_reg then 
					   	empty_next <= '1';
					end if; 
				end if ; 
				
			when "10" => -- write 
				if full_reg /= '1' then -- not full 
					write_ptr_next <= write_ptr_succ; 
					empty_next <= '0'; 
					if write_ptr_succ = read_ptr_reg then 
						full_next <= '1';
					end if; 
				end if; 
			when others => -- write/read 
				write_ptr_next <= write_ptr_succ; 
				read_ptr_next <= read_ptr_succ; 
		end case; 
	end process; 
	
	-- output
	FULL <= full_reg; 
	EMPT <= empty_reg;  

end architecture;