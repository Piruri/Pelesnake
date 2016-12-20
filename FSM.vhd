library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
    Port ( mov : in  STD_LOGIC_VECTOR (1 downto 0); --movimiento procedente del teclado
--           FSM_Plotter : out  STD_LOGIC_VECTOR (1 downto 0); --información que se enviará al plotter y a la musica
           bdir : out  STD_LOGIC_VECTOR (7 downto 0);
           bdata : in  STD_LOGIC_VECTOR (4 downto 0));
end FSM;

architecture Behavioral of FSM is
	type mi_estado is (Inicio, Reposo, Movimiento,  Analisis, KO, Avanza, Sumar, OK); --estados
	signal estado,p_estado: mi_estado;
	signal Dserp,p_Dserp,Dcola,p_Dcola : std_logic_vector(7 downto 0); --refistros de direcciones
	signal p_casilla : std_logic_vector (3 downto 0); --registro para analizar las casillas
	signal RS :std_logic_vector (4 downto 0); --bms bit de inicio, 3 y 2 mov cola, 1 y 0 mov cabeza
begin
	sync: process (clk, reset)
		begin 
			if (reset='1')then
				estado<=Inicio;
			elsif (rising_edge(clk) and reset='0') then
				estado<=p_estado;
			end if;
		end process;
	
	comb: process(estado)
		begin
			case estado is
				when inicio =>
				when reposo=>
				when movimiento=>
				when analisis=>
				when avanza=>
				when sumar=>
				when OK=>
				when KO=>
			end case;
		end process;

end Behavioral;
