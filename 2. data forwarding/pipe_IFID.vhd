library ieee;
use ieee.std_logic_1164.all;
 

entity pipe_IFID is
port (	IF_PC4 : in std_logic_vector(31 downto 0);
	IF_instruction: in std_logic_vector( 31 downto 0);
	clk, reset : in std_logic;
	ID_PC4 : out std_logic_vector(31 downto 0);
	ID_instruction: out std_logic_vector( 31 downto 0));
end pipe_IFID;

architecture behavioral of pipe_IFID is
begin
process
begin
if rising_edge(clk) then
ID_PC4 <= x"00000000";
ID_instruction <= x"00000000";
else
ID_PC4 <= IF_PC4;
ID_instruction <= IF_instruction;
end if;
end process;
end behavioral;
