library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Plotter is
    Port ( clk :in STD_LOGIC;
		reset: in STD_LOGIC;
		--FSM : in  STD_LOGIC;
		Y : in  STD_LOGIC_VECTOR (9 downto 0); --coordenada y proveniente del vga
		X : in  STD_LOGIC_VECTOR (9 downto 0); --coordenada x proceniente del vga
		objeto : in  STD_LOGIC_VECTOR (3 downto 0); -- tipo de objeto a representar
		yxt : out  STD_LOGIC_VECTOR (7 downto 0); --coordenada yx que va al tablero
		RGB : out  STD_LOGIC_VECTOR (7 downto 0)); --color a representar
end Plotter;

architecture Behavioral of Plotter is

COMPONENT CabezaIzq	PORT
		(clka : IN STD_LOGIc;
		addra :IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		douta :OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
COMPONENT CabezaUp	PORT
		(clka : IN STD_LOGIc;
		addra :IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		douta :OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
COMPONENT CabezaDown	PORT
		(clka : IN STD_LOGIc;
		addra :IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		douta :OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;

signal yt, xt:unsigned (3 downto 0); --señales de y x para el tablero
signal yr, xr:unsigned (4 downto 0); --señales de y x para las imagenes
signal addraCI, addraCU, addraCD: std_logic_vector(9 downto 0); --direcciones de lectura a las memorias
signal doutaCI, doutaCU, doutaCD: std_logic_vector(7 downto 0); --info dentro de memorias

begin

RomCI:CabezaIzq
		Port map(clka=>clk,addra=>addraCI,douta=>doutaCI);
RomCU:CabezaUp
		Port map(clka=>clk,addra=>addraCU,douta=>doutaCU);
RomCD:CabezaDown
		Port map(clka=>clk,addra=>addraCD,douta=>doutaCD);

yxt(7 downto 4)<=std_logic_vector(yt); --asignación de las coordenadas
yxt(3 downto 0)<=std_logic_vector(xt); --yx que iran al tablero

xt<= unsigned(X(8 downto 5))-2; --coordenadas yt y xt serán los bits
yt<= unsigned(Y(8 downto 5)); --que dividen el tablero en grupos de 32 bits

xr<= unsigned(X(4 downto 0)); --coordenadas yr y xr serán los bits
yr<= unsigned(Y(4 downto 0)); --que cuentan de 32 en 32

comb: process(objeto,yr,xr,Y,X,doutaCI,doutaCU,doutaCD)
	begin
		if(unsigned(X)<63 or unsigned(X)>575)then 
			RGB<="00101011";
		else
			case objeto is
				when "0000" => --vacio (tablero libre)
					addraCI<=(others=>'0');
					addraCU<=(others=>'0');
					addraCD<=(others=>'0');
					RGB<="11111010";
				when "0100"=> --cabeza arriba
					addraCU(9 downto 5)<=std_logic_vector(yr);
					addraCU(4 downto 0)<=std_logic_vector(xr);
					addraCI<=(others=>'0');
					addraCD<=(others=>'0');
					RGB<=doutaCU;
				when "0101"=> --cabeza derecha (inversión)
					addraCI(9 downto 5)<=std_logic_vector(yr);
					addraCI(4 downto 0)<=std_logic_vector(31-xr); --le restamos 31 a la coordenada x para invertir la matriz		
					addraCU<=(others=>'0');
					addraCD<=(others=>'0');
					RGB<=doutaCI;
				when "0110"=> --cabeza izquierda
					addraCI(9 downto 5)<=std_logic_vector(yr);
					addraCI(4 downto 0)<=std_logic_vector(xr);		
					addraCU<=(others=>'0');
					addraCD<=(others=>'0');
					RGB<=doutaCD;
				when "0111"=> --cabeza abajo
					addraCD(9 downto 5)<=std_logic_vector(yr);
					addraCD(4 downto 0)<=std_logic_vector(xr);		
					addraCI<=(others=>'0');
					addraCU<=(others=>'0');
					RGB<=doutaCD;
				when "1111"=> --muro
					addraCI<=(others=>'0');
					addraCU<=(others=>'0');
					addraCD<=(others=>'0');
					RGB<="00011011";
				when others =>
					addraCI<=(others=>'0');
					addraCU<=(others=>'0');
					addraCD<=(others=>'0');
					RGB<="00011100";
			end case;
		end if;
end process;

end Behavioral;
