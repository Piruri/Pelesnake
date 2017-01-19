library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Plotter is
    Port ( clk :in STD_LOGIC;
		reset: in STD_LOGIC;
		Y : in  STD_LOGIC_VECTOR (9 downto 0); --coordenada y proveniente del vga
		X : in  STD_LOGIC_VECTOR (9 downto 0); --coordenada x proceniente del vga
		objeto : in  STD_LOGIC_VECTOR (3 downto 0); -- tipo de objeto a representar
		yxt : out  STD_LOGIC_VECTOR (7 downto 0); --coordenada yx que va al tablero
		RGB : out  STD_LOGIC_VECTOR (7 downto 0)); --color a representar
end Plotter;

architecture Behavioral of Plotter is
COMPONENT Imagenes
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;


signal yt, xt:unsigned (3 downto 0); --seales de y x para el tablero
signal yr, xr:unsigned (4 downto 0); --seales de y x para las imagenes
signal addraIm: std_logic_vector(12 downto 0); --direcciones de lectura a las memorias
signal doutaIm: std_logic_vector(7 downto 0); --info dentro de memorias

begin

RomIma: Imagenes
	Port Map (clka=>clk,addra=>addraIm,douta=>doutaIm);

yxt(7 downto 4)<=std_logic_vector(yt); --asignacin de las coordenadas
yxt(3 downto 0)<=std_logic_vector(xt); --yx que iran al tablero

xt<= unsigned(X(8 downto 5))-2; --coordenadas yt y xt sern los bits
yt<= unsigned(Y(8 downto 5)); --que dividen el tablero en grupos de 32 bits

xr<= unsigned(X(4 downto 0)); --coordenadas yr y xr sern los bits
yr<= unsigned(Y(4 downto 0)); --que cuentan de 32 en 32

comb: process(objeto,yr,xr,Y,X,doutaIm)
	begin
		if(unsigned(X)<63 or unsigned(X)>575)then 
			RGB<="00101011";
			addraIm<=(others=>'0');
		else
		
			case objeto is
				when "0000" => --vacio (tablero libre)
					addraIm<=(others=>'0');
					RGB<="11111010";
				when "0100"=> --cabeza arriba
					addraIm(12 downto 10)<="001";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(xr);
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "0101"=> --cabeza derecha (inversin)
					addraIm(12 downto 10)<="000";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(31-xr); --le restamos 31 a la coordenada x para invertir la matriz		
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "0110"=> --cabeza izquierda
					addraIm(12 downto 10)<="000";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(xr);		
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "0111"=> --cabeza abajo
					addraIm(12 downto 10)<="010";
					addraIm(9 downto 5)<=std_logic_vector(31-yr);
					addraIm(4 downto 0)<=std_logic_vector(xr);		
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "0011" => --pescado
					addraIm(12 downto 10)<="110";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(xr);
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "1000" => --gato arriba
					addraIm(12 downto 10)<="100";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(xr);
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "1001"=> --gato derecha (inversin)
					addraIm(12 downto 10)<="011";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(31-xr); --le restamos 31 a la coordenada x para invertir la matriz		
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "1010"=> --gato izquierda
					addraIm(12 downto 10)<="011";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(xr);		
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "1011"=> --gato abajo
					addraIm(12 downto 10)<="101";
					addraIm(9 downto 5)<=std_logic_vector(yr);
					addraIm(4 downto 0)<=std_logic_vector(xr);		
					if (doutaIm = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaIm;
					end if;
				when "1111"=> --muro
					addraIm<=(others=>'0');
					RGB<="00011011";
				when others =>
					addraIm<=(others=>'0');
					RGB<="11111010";--"00011100" es para detectar errores
			end case;
		end if;
end process;

end Behavioral;
