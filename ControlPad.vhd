library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ControlPad is
    Port ( direcciones : in STD_LOGIC_VECTOR (3 downto 0);
			  clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
           salbuscontrol : out  STD_LOGIC_VECTOR (1 downto 0));
end ControlPad;
--Se trata únicamente de un decodificador de 4 entradas y un bus de salida de 2.
architecture Behavioral of ControlPad is
signal pbuscontrol, buscontrol: unsigned (1 downto 0);
begin
sinc: process (reset,clk)
	begin
		if (reset='1') then
			buscontrol <= "00";
		elsif (rising_edge(clk)) then
			buscontrol <= pbuscontrol;
		end if;
	end process;
comb:process (direcciones,buscontrol)
	begin
		case direcciones is
			when "0001" => --
				pbuscontrol <= "00";
			when "0010" => --
				pbuscontrol <= "01";
			when "0100" =>
				pbuscontrol <= "10";
			when "1000" =>
				pbuscontrol <= "11";
			when others =>
				pbuscontrol <= buscontrol;
		end case;
	end process;
salbuscontrol <= std_logic_vector(buscontrol);
end Behavioral;

