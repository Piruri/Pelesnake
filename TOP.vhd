library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           Up : in  STD_LOGIC;
           Lef : in  STD_LOGIC;
           Rig : in  STD_LOGIC;
           Dow : in  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (7 downto 0));
end TOP;

architecture Behavioral of TOP is

COMPONENT ControlPad is
    Port ( UP : in STD_LOGIC;
		LEF : in STD_LOGIC;
		RIG : in STD_LOGIC;
		DOW : in STD_LOGIC;
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
      salbuscontrol : out  STD_LOGIC_VECTOR (1 downto 0));
end COMPONENT;

COMPONENT vga_driver_project is
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
end COMPONENT;

COMPONENT Plotter is
    Port ( clk :in STD_LOGIC;
		reset: in STD_LOGIC;
		--FSM : in  STD_LOGIC;
		Y : in  STD_LOGIC_VECTOR (9 downto 0); --coordenada y proveniente del vga
		X : in  STD_LOGIC_VECTOR (9 downto 0); --coordenada x proceniente del vga
		objeto : in  STD_LOGIC_VECTOR (3 downto 0); -- tipo de objeto a representar
		yxt : out  STD_LOGIC_VECTOR (7 downto 0); --coordenada yx que va al tablero
		RGB : out  STD_LOGIC_VECTOR (7 downto 0)); --color a representar
end COMPONENT;
--
signal ControlBus : std_logic_vector(1 downto 0);
signal BdataPlot : STD_LOGIC_VECTOR(3 downto 0); --bus de datos del tablero al plotter, tipo de objeto
Signal RGBin, RGBout, yxtab : STD_LOGIC_VECTOR(7 downto 0); -- , , yx del plotter sl tablero
Signal X, Y : STD_LOGIC_VECTOR(9 downto 0);
signal Vsinc, Hsinc : STD_LOGIC;

begin

control : ControlPad
	Port Map(clk=>clk,
		reset=>reset,
		UP=>Up,
		LEF=>Lef,
		RIG=>Rig,
		DOW=>Dow,
		salbuscontrol=>ControlBus);

VGA : vga_driver_project
    Port Map( clk=>clk,
           reset=>reset,
           RED_in =>RGBin(7 downto 5),
           GRN_in =>RGBin(4 downto 2),
           BLUE_in =>RGBin(1 downto 0),
			  HS =>hsinc,
			  VS =>vsinc,
           RED =>RGBout(7 downto 5),
           GRN =>RGBout(4 downto 2),
           BLUE =>RGBout(1 downto 0),
           eje_x =>X,
           eje_y =>Y);

Plot : Plotter
    Port Map ( clk =>clk,
		reset=>reset,
		--FSM : in  STD_LOGIC;
		Y =>Y,
		X =>X,
		objeto => BdataPlot,
		yxt => yxtab,
		RGB => RGBout);
		
		
end Behavioral;
