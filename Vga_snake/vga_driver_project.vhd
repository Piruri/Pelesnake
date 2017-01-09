library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_driver_project is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RED_in : in  STD_LOGIC_VECTOR (2 downto 0);
           GRN_in : in  STD_LOGIC_VECTOR (2 downto 0);
           BLUE_in : in  STD_LOGIC_VECTOR (1 downto 0);
			  HS : out STD_LOGIC;
			  VS : out STD_LOGIC;
           RED : out  STD_LOGIC_VECTOR (2 downto 0);
           GRN : out  STD_LOGIC_VECTOR (2 downto 0);
           BLUE : out  STD_LOGIC_VECTOR (1 downto 0);
           eje_x : out  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : out  STD_LOGIC_VECTOR (9 downto 0));
end vga_driver_project;

architecture Behavioral of vga_driver_project is
component contador is
		Generic (Nbit : INTEGER := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end component;
component comparador is
	Generic (Nbit : INTEGER := 8;
		End_Of_Screen : INTEGER := 10;
		Start_Of_Pulse : INTEGER := 20;
		End_Of_Pulse : INTEGER := 30;
		End_Of_Line : INTEGER := 40);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (Nbit-1 downto 0);
           o1 : out  STD_LOGIC;
           o2 : out  STD_LOGIC;
           o3 : out  STD_LOGIC);
end component;
signal x,y : std_logic_vector (9 downto 0);
signal clk_pixel, p_clk_pixel, o3_resets_h, o3_resets_v, Blank_h, Blank_v,enable_v : std_logic;
begin
p_clk_pixel <= not clk_pixel;
div_frec: process (reset,clk)
	begin
		if (reset='1') then
			clk_pixel <= '0';
		elsif (rising_edge(clk)) then
			clk_pixel <= p_clk_pixel;
		end if;
	end process;
	
gen_color: process (Blank_h,Blank_v,RED_in,GRN_in,BLUE_in)
	begin
		if (Blank_v='1' or Blank_h='1') then
			RED <= (others=>'0');
			GRN <= (others=>'0');
			BLUE <= (others=>'0');
		else
			RED <= RED_in;
			GRN <= GRN_in;
			BLUE <= BLUE_in;
		end if;
	end process;
	
conth: contador
	GENERIC MAP (Nbit=>10)
	PORT MAP (
		clk => clk,
		reset => reset,
		enable => clk_pixel,
		resets => o3_resets_h,
		Q => x);
		
comph: comparador
	GENERIC MAP (Nbit => 10, End_Of_Screen => 639, Start_Of_Pulse => 655, End_Of_Pulse => 751, End_Of_Line => 799)
	PORT MAP (
		clk => clk,
		reset => reset,
		data => x,
		o1 => Blank_h,
		o2 => HS,
		o3 => o3_resets_h);
		
enable_v <= clk_pixel and o3_resets_h;
contv: contador
	GENERIC MAP (Nbit=>10)
	PORT MAP (
		clk => clk,
		reset => reset,
		enable => enable_v,
		resets => o3_resets_v,
		Q => y);
		
compv: comparador
	GENERIC MAP (Nbit=>10, End_Of_Screen=>479, Start_Of_Pulse=>489, End_Of_Pulse=>491, End_Of_Line=>520)
	PORT MAP (
		clk => clk,
		reset => reset,
		data => y,
		o1 => Blank_v,
		o2 => VS,
		o3 => o3_resets_v);
eje_x <= x;
eje_y <= y;
end Behavioral;

