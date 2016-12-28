library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity comparador is
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
end comparador;

architecture Behavioral of comparador is
signal p_o1, p_o2, p_o3: std_logic;
signal data_s : unsigned (Nbit-1 downto 0);
begin
data_s <= unsigned(data);
comb: process(data_s)
	begin
		if (data_s>End_Of_Screen) then
			p_o1 <= '1';
		else
			p_o1 <= '0';
		end if;
		if (Start_Of_Pulse<data_s and data_s<End_Of_Pulse) then
			p_o2 <= '0';
		else
			p_o2 <= '1';
		end if;
		if (data_s=End_Of_Line) then
			p_o3 <= '1';
		else
			p_o3 <= '0';
		end if;
	end process;
	
sinc: process(clk,reset)
	begin
		if (reset='1') then
			o1 <= '0';
			o2 <= '1';
			o3 <= '0';
		elsif (rising_edge(clk)) then
			o1 <= p_o1;
			o2 <= p_o2;
			o3 <= p_o3;
		end if;
	end process;
end Behavioral;

