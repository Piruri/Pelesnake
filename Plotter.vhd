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
COMPONENT BR1
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;
COMPONENT BR2
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;
COMPONENT BR3
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

signal yt, xt:unsigned (3 downto 0); --seales de y x para el tablero
signal yr, xr:unsigned (4 downto 0); --seales de y x para las imagenes
signal addraBR1, addraBR2: std_logic_vector(10 downto 0); --direcciones de lectura a las memorias
signal addraBR3: std_logic_vector(9 downto 0); --direcciones de lectura a la memoria del pez
signal doutaBR1, doutaBR2, doutaBR3: std_logic_vector(7 downto 0); --info dentro de memorias

begin

RomBR1:BR1
	Port Map(clka=>clk,addra=>addraBR1,douta=>doutaBR1);
RomBR2:BR2
	Port Map(clka=>clk,addra=>addraBR2,douta=>doutaBR2);
RomBR3:BR3
	Port Map(clka=>clk,addra=>addraBR3,douta=>doutaBR3);
yxt(7 downto 4)<=std_logic_vector(yt); --asignacin de las coordenadas
yxt(3 downto 0)<=std_logic_vector(xt); --yx que iran al tablero

xt<= unsigned(X(8 downto 5))-2; --coordenadas yt y xt sern los bits
yt<= unsigned(Y(8 downto 5)); --que dividen el tablero en grupos de 32 bits

xr<= unsigned(X(4 downto 0)); --coordenadas yr y xr sern los bits
yr<= unsigned(Y(4 downto 0)); --que cuentan de 32 en 32

comb: process(objeto,yr,xr,Y,X,doutaBR1,doutaBR2,doutaBR3)
	begin
		if(unsigned(X)<63 or unsigned(X)>575)then 
			RGB<="00101011";
			addraBR2<=(others=>'0');
			addraBR1<=(others=>'0');
			addraBR3<=(others=>'0');
		else
		
			case objeto is
				when "0000" => --vacio (tablero libre)
					addraBR1<=(others=>'0');
					addraBR2<=(others=>'0');
					addraBR3<=(others=>'0');
					RGB<="11111010";
				when "0100"=> --cabeza arriba
					addraBR1(10)<='1';
					addraBR1(9 downto 5)<=std_logic_vector(yr);
					addraBR1(4 downto 0)<=std_logic_vector(xr);
					addraBR2<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR1 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR1;
					end if;
				when "0101"=> --cabeza derecha (inversin)
					addraBR1(10)<='0';
					addraBR1(9 downto 5)<=std_logic_vector(yr);
					addraBR1(4 downto 0)<=std_logic_vector(31-xr); --le restamos 31 a la coordenada x para invertir la matriz
					addraBR2<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR1 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR1;
					end if;
				when "0110"=> --cabeza izquierda
					addraBR1(10)<='0';
					addraBR1(9 downto 5)<=std_logic_vector(yr);
					addraBR1(4 downto 0)<=std_logic_vector(xr);
					addraBR2<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR1 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR1;
					end if;
				when "0111"=> --cabeza abajo (inversion)
					addraBR1(10)<='1';
					addraBR1(9 downto 5)<=std_logic_vector(31-yr);
					addraBR1(4 downto 0)<=std_logic_vector(xr);
					addraBR2<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR1 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR1;
					end if;
				when "0011" => --pescado
					addraBR3(9 downto 5)<=std_logic_vector(yr);
					addraBR3(4 downto 0)<=std_logic_vector(xr);
					addraBR2<=(others=>'0');
					addraBR1<=(others=>'0');
					if (doutaBR3 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR3;
					end if;
				when "1000" => --gato arriba
					addraBR2(10)<='1';
					addraBR2(9 downto 5)<=std_logic_vector(yr);
					addraBR2(4 downto 0)<=std_logic_vector(xr);
					addraBR1<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR2 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR2;
					end if;
				when "1001"=> --gato derecha (inversin)
					addraBR2(10)<='0';
					addraBR2(9 downto 5)<=std_logic_vector(yr);
					addraBR2(4 downto 0)<=std_logic_vector(31-xr); --le restamos 31 a la coordenada x para invertir la matriz		
					addraBR1<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR2 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR2;
					end if;
				when "1010"=> --gato izquierda
					addraBR2(10)<='0';
					addraBR2(9 downto 5)<=std_logic_vector(yr);
					addraBR2(4 downto 0)<=std_logic_vector(xr);
					addraBR1<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR2 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR2;
					end if;
				when "1011"=> --gato abajo (inversion)
					addraBR2(10)<='1';
					addraBR2(9 downto 5)<=std_logic_vector(31-yr);
					addraBR2(4 downto 0)<=std_logic_vector(xr);
					addraBR1<=(others=>'0');
					addraBR3<=(others=>'0');
					if (doutaBR2 = "11111111") then
						RGB<="11111010";
					else
						RGB<=doutaBR2;
					end if;
				when "1111"=> --muro
					addraBR2<=(others=>'0');
					addraBR1<=(others=>'0');
					addraBR3<=(others=>'0');
					RGB<="00011011";
				when others =>
					addraBR2<=(others=>'0');
					addraBR1<=(others=>'0');
					addraBR3<=(others=>'0');
					RGB<="00011100";--"00011100" es para detectar errores
			end case;
		end if;
end process;

end Behavioral;
