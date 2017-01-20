--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:12:04 01/16/2017
-- Design Name:   
-- Module Name:   C:/Documents and Settings/Admin/Desktop/PELESNAKE/TOPtb.vhd
-- Project Name:  PELESNAKE
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TOP
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
use ieee.std_logic_textio.all;
use std.textio.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TOPtb IS
END TOPtb;
 
ARCHITECTURE behavior OF TOPtb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TOP
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         Up : IN  std_logic;
         Lef : IN  std_logic;
         Rig : IN  std_logic;
         Dow : IN  std_logic;
         RGB : OUT  std_logic_vector(7 downto 0);
         Vsinc : OUT  std_logic;
         Hsinc : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal Up : std_logic := '0';
   signal Lef : std_logic := '0';
   signal Rig : std_logic := '0';
   signal Dow : std_logic := '0';

 	--Outputs
   signal RGB : std_logic_vector(7 downto 0);
   signal Vsinc : std_logic;
   signal Hsinc : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TOP PORT MAP (
          clk => clk,
          reset => reset,
          Up => Up,
          Lef => Lef,
          Rig => Rig,
          Dow => Dow,
          RGB => RGB,
          Vsinc => Vsinc,
          Hsinc => Hsinc
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      reset<='1';-- hold reset state for 100 ns.
      wait for 100 ns;	
		reset<='0';
      wait for 10 ns;
		lef<='1';
		wait for 9 ms;
		lef<='0';
		dow<='1';
		wait for 20 ns;
		dow<='0';
		wait for 50 ms;
		rig <='1'; 
		wait for 8 ms;
		rig<='0';
		lef<='1';
		wait for 8 ms;
		lef<='0';
		up<='1';
		wait for 15 ms;
		up<='0';
		lef<='1';
		
		
      -- insert stimulus here 

      wait;
   end process;
	
	process (clk)
    file file_pointer: text is out "write.txt";
    variable line_el: line;
begin

    if rising_edge(clk) then

        -- Write the time
        write(line_el, now); -- write the line.
        write(line_el, ":"); -- write the line.

        -- Write the hsync
        write(line_el, " ");
        write(line_el, Hsinc); -- write the line.

        -- Write the vsync
        write(line_el, " ");
        write(line_el, Vsinc); -- write the line.

        -- Write the red
        write(line_el, " ");
        write(line_el, RGB(7 downto 5)); -- write the line.

        -- Write the green
        write(line_el, " ");
        write(line_el, RGB(4 downto 2)); -- write the line.

        -- Write the blue
        write(line_el, " ");
        write(line_el, RGB(1 downto 0)); -- write the line.

        writeline(file_pointer, line_el); -- write the contents into the file.

    end if;
end process;
END;
