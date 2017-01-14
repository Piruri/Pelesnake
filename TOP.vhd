library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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
           RGB : out  STD_LOGIC_VECTOR (7 downto 0);
			  Vsinc : out STD_LOGIC;
			  Hsinc : out STD_LOGIC);
end TOP;

architecture Behavioral of TOP is

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

COMPONENT tablero	PORT(
	  clka: in STD_LOGIC;
	  wea: in STD_LOGIC_VECTOR(0 downto 0);
	  addra: in STD_LOGIC_VECTOR (7 downto 0);
	  dina: in STD_LOGIC_VECTOR(7 downto 0);
	  douta : out STD_LOGIC_VECTOR (7 downto 0);
	  clkb : in STD_LOGIC;
	  web :in STD_LOGIC_VECTOR (0 downto 0);
	  addrb : in STD_LOGIC_VECTOR(7 downto 0);
	  dinb : in STD_LOGIC_VECTOR(7 downto 0);
	  doutb : out STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;

Component FSM is
	Generic( CNT: integer :=26); -- numero de veces que cuenta antes de hacer otro movimiento
    Port (
		reset : in std_logic;
		clk : in std_logic;
		tframe : in std_logic; --señal Vsincs del vga, está a 0 un clk al refrescar terminar una pantalla    
		UP : in STD_LOGIC;
		LEF : in STD_LOGIC;
		RIG : in STD_LOGIC;
		DOW : in STD_LOGIC;
		bdir : out  STD_LOGIC_VECTOR (7 downto 0); --bus direcciones
		bdatin : out  STD_LOGIC_VECTOR (3 downto 0); --bus datos que introduce info en la memoria
		bdatout : in  STD_LOGIC_VECTOR (3 downto 0); --bus datos que saxa datos de la memoria
		rw : out STD_LOGIC_VECTOR (0 downto 0); --señal de lectura/escritura
		muerto : out STD_LOGIC; --señal para reiniciar
		revivo : in STD_LOGIC); --señal para saber que hemos terminado de reiniciar
		end COMPONENT;

signal BdataPlot, BdatFSMin, BdatFSMout: STD_LOGIC_VECTOR(3 downto 0); --bus de datos del tablero al plotter(objeto del tablero), Bus data FSM introduce en la memoria, Bus data FSM lee de la memoria
Signal RGBin, yxtab ,BdirFSMt, Bdattabin, Bdattabout, Bdirtab: STD_LOGIC_VECTOR(7 downto 0); -- , , yx del plotter sl tablero, Bus direc FSM a Tablero, Bus de datos del tablero, será utiñizado para reiniciar la partida, uno de entrada y otro de salida de la memoria.
Signal X, Y : STD_LOGIC_VECTOR(9 downto 0);
signal Vsincs, Hsincs, muertos, revivos : STD_LOGIC;
signal cero,rwFSM ,rwreini: STD_LOGIC_VECTOR(0 downto 0);
signal pk, k: unsigned (7 downto 0); --Variable para el bucle de reinicio
signal pdoutareini, doutareini : std_logic_vector (3 downto 0); --Variable para reiniciar el tablero
	

begin
cero<="0";
Hsinc <= Hsincs;
Vsinc <= Vsincs;

VGA : vga_driver_project
    Port Map( clk=>clk,
           reset=>reset,
           RED_in =>RGBin(7 downto 5),
           GRN_in =>RGBin(4 downto 2),
           BLUE_in =>RGBin(1 downto 0),
			  HS =>Hsincs,
			  VS =>Vsincs,
           RED =>RGB(7 downto 5),
           GRN =>RGB(4 downto 2),
           BLUE =>RGB(1 downto 0),
           eje_x =>X,
           eje_y =>Y);

Plot : Plotter
    Port Map ( clk =>clk,
		reset=>reset,
		Y =>Y,
		X =>X,
		objeto => BdataPlot,
		yxt => yxtab,
		RGB => RGBin);
		
tablerito : tablero	
	PORT Map(
	  clka=>clk,
	  wea=>rwreini,
	  addra=> Bdirtab,
	  dina => Bdattabin,
	  douta =>Bdattabout,
	  clkb => clk,
	  web => cero,
	  addrb => yxtab,
	  dinb => "00000000",
	  doutb (7 downto 4) => open,
	  doutb (3 downto 0) => BdataPlot);
		
Maquinita : FSM 
	Generic Map( CNT =>26) -- numero de veces que cuenta antes de hacer otro movimiento
    Port Map(
		reset => reset,
		clk => clk,
		tframe => Vsincs,
		UP => Up,
		LEF => Lef,
		RIG => Rig,
		DOW => Dow,
		bdir => BdirFSMt,
		bdatin => BdatFSMin,
		bdatout => BdatFSMout,
		rw => rwFSM,
		muerto => muertos,
		revivo => revivos);
		
sinc: process(reset,clk)
	begin
		if (reset = '1') then
			k <= (others=>'0');
			doutareini <= (others=>'0');
		elsif (rising_edge(clk)) then
			k<=pk;
			doutareini <= pdoutareini;
		end if;
	end process;

reinicio : process(muertos,BdirFSMt,BdatFSMin,rwFSM,k,Bdattabout,doutareini)
	begin
		pk<= (others=>'0');
		if (muertos = '1') then
			Bdirtab <= (others=>'0');
			BdatFSMout <= (others=>'0');
			Bdattabin <= (others=>'0');
			rwreini <= "0";
			pdoutareini<= (others=>'0');
			while k < "11110000" loop
				rwreini <= "0"; --Leemos de tablero
				pdoutareini <= Bdattabout (7 downto 4); --Guardamos el tablero incial
				rwreini <= "1"; --Escribimos en tablero
				Bdattabin (3 downto 0) <= doutareini; --Reiniciamos contenido
				Bdirtab <= std_logic_vector(k); --Incrementamos dirección
				pk<=k+1;
			end loop;
			revivos <= '1';
		else 
			Bdirtab <= BdirFSMt;
			rwreini <= rwFSM;
			BdatFSMout <= Bdattabout (3 downto 0) ;
			Bdattabin (3 downto 0) <= BdatFSMin;
			revivos <= '0';
			pdoutareini<= (others=>'0');
		end if;
	end process;
		
end Behavioral;
