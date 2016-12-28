library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_driver is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  button : in STD_LOGIC;
           VS : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           RED : out  STD_LOGIC_VECTOR (2 downto 0);
           GRN : out  STD_LOGIC_VECTOR (2 downto 0);
           BLUE : out  STD_LOGIC_VECTOR (1 downto 0));
end vga_driver;

architecture Behavioral of vga_driver is
signal clk_pixel, p_clk_pixel, Blank_H, Blank_V, o3_resets_h, o3_resets_v, enable_v : std_logic;
signal RED_in, GRN_in : std_logic_vector (2 downto 0);
signal BLUE_in : std_logic_vector (1 downto 0);
signal eje_x, eje_y: std_logic_vector (9 downto 0);
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
component dibuja is
    Port ( eje_x : in  STD_LOGIC_VECTOR (9 downto 0);
           eje_y : in  STD_LOGIC_VECTOR (9 downto 0);
			  change : in STD_LOGIC;
           RED : out  STD_LOGIC_VECTOR (2 downto 0);
           GRN : out  STD_LOGIC_VECTOR (2 downto 0);
           BLUE : out  STD_LOGIC_VECTOR (1 downto 0));
end component;
begin
p_clk_pixel <= not clk_pixel;
div_frec: process(clk,reset)
	begin
		if (reset='1') then
			clk_pixel <= '0';
		elsif (rising_edge(clk)) then
			clk_pixel <= p_clk_pixel;
		end if;
	end process;
	
gen_color: process(Blank_H,Blank_V,RED_in,GRN_in,BLUE_in)
	begin
		if (Blank_H='1' or Blank_V='1') then
			RED <= (others=>'0');
			GRN <= (others=>'0');
			BLUE <= (others =>'0');
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
		Q => eje_x);
		
comparadorh: comparador
	GENERIC MAP (Nbit => 10, End_Of_Screen => 639, Start_Of_Pulse => 655, End_Of_Pulse => 751, End_Of_Line => 799)
	PORT MAP (
		clk => clk,
		reset => reset,
		data => eje_x,
		o1 => Blank_H,
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
		Q => eje_y);
		
comparadorv: comparador
	GENERIC MAP (Nbit=>10, End_Of_Screen=>479, Start_Of_Pulse=>489, End_Of_Pulse=>491, End_Of_Line=>520)
	PORT MAP (
		clk => clk,
		reset => reset,
		data => eje_y,
		o1 => Blank_V,
		o2 => VS,
		o3 => o3_resets_v);

dib: dibuja
	PORT MAP (
		eje_x => eje_x,
		eje_y => eje_y,
		change => button,
		RED => RED_in,
		GRN => GRN_in,
		BLUE => BLUE_in);
end Behavioral;