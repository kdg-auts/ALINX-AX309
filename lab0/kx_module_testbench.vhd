--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:17:03 02/21/2019
-- Design Name:   
-- Module Name:   D:/APPDATA/xolonx_projects/Lab1/kx_testbench.vhd
-- Project Name:  Lab1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: kx_module
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY kx_testbench IS
END kx_testbench;
 
ARCHITECTURE behavior OF kx_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT kx_module
    PORT(
         x : IN  std_logic_vector(3 downto 0);
         y : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal t_x : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal t_y : std_logic_vector(3 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: kx_module PORT MAP (
          x => t_x,
          y => t_y
        );

 
 

   -- Stimulus process
   stim_proc: process
   begin
		t_x<="0000";
		wait for 10 ns;
		t_x<="0001";
		wait for 10 ns;
		t_x<="0010";
		wait for 10 ns;
		t_x<="0011";
		wait for 10 ns;
		t_x<="0100";
		wait for 10 ns;
		t_x<="0101";
		wait for 10 ns;
		t_x<="0110";
		wait for 10 ns;
		t_x<="0111";
		wait for 10 ns;
		t_x<="1000";
		wait for 10 ns;
		t_x<="1001";
		wait for 10 ns;
		t_x<="1010";
		wait for 10 ns;
		t_x<="1011";
		wait for 10 ns;
		t_x<="1100";
		wait for 10 ns;
		t_x<="1101";
		wait for 10 ns;
		t_x<="1110";
		wait for 10 ns;
		t_x<="1111";
		wait;
   end process;

END;
