library ieee;
use ieee.std_logic_1164.all;
 

entity pipe_IFID is
port (	IF_PC4 : in std_logic_vector(31 downto 0);
	IF_instruction: in std_logic_vector( 31 downto 0);
	clk, reset : in std_logic;
	ID_PC4 : out std_logic_vector(31 downto 0);
	ID_instruction: out std_logic_vector( 31 downto 0);
	IF_Flush: in std_logic_vector (31 downto 0));
end pipe_IFID;

component control is 
port (
	instruction : in std_logic_vector (XLEN-1 downto 0);
	BranchCond : in std_logic; -- BR. COND. SATISFIED = 1; NOT SATISFIED = 0
	ALUOp : out std_logic_vector (3 downto 0)
);
end component;

architecture behavioral of pipe_IFID is
constant nop: std_logic_vector(31 downto 0) := x"00000000";
signal d_IF_Flush: std_logic_vector (31 downto 0);
signal d_ID_instruction: std_logic_vector (31 downto 0);
signal d_BranchCond: std_logic;
signal d_ALUOp: std_logic_vector (3 down to 0);


begin 
        a1: control port map(instruction => d_ID_instruction, BranchCond => d_BranchCond, ALUOp => d_ALUOp, IF_Flush => d_IF_Flush)
process
begin
if rising_edge(clk) then
if BranchCond = '1' then --if branch condition is satisfied i.e., branch is taken, IF_Flush so nop is injected 
	ID_PC4 <= nop;
	ID_instruction <= nop;
else
ID_PC4 <= IF_PC4;
ID_instruction <= IF_instruction;
end if;
end process;

end behavioral;
