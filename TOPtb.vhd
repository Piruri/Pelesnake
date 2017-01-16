LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
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
         RGB : OUT  std_logic_vector(7 downto 0)
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
          RGB => RGB
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
      wait for 100ms;
		rig<='1';
      wait for 100 ns;	
		rig<='0';
      wait for 100 ns;	
		up<='1';
		wait for 10 ns;	
		up<='0';
		wait for 100 ns;	
		up<='1';
		wait for 1000 ns;	
		up<='0';
		wait for 100 ns;	
		lef<='1';
		
		
      -- insert stimulus here 

      wait;
   end process;

END;
