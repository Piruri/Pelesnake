library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity contador is
		Generic (Nbit : INTEGER := 8);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end contador;

architecture Behavioral of contador is
signal cuenta, p_cuenta : unsigned (Nbit-1 downto 0);
constant MAX_CUENTA : integer := 2**Nbit-1;
begin
sinc: process(reset,clk)
	begin
		if (reset ='1') then
			cuenta <= (others => '0');
		elsif (rising_edge(clk)) then
			cuenta <= p_cuenta;
		end if;
	end process;
	
comb: process(enable,resets,cuenta)
	begin
		if (resets='1' or cuenta=MAX_CUENTA) then
			p_cuenta <= (others => '0');
		elsif (enable='1') then
			p_cuenta <= cuenta + 1;
		else 
			p_cuenta <= cuenta;
		end if;
	end process;
Q <= std_logic_vector(cuenta);
end Behavioral;

