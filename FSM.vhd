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
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           control : in  STD_LOGIC_VECTOR (1 downto 0);
           direc : out  STD_LOGIC_VECTOR (7 downto 0);
           data : in  STD_LOGIC_VECTOR (7 downto 0));
end FSM;

architecture Behavioral of FSM is

begin


end Behavioral;

