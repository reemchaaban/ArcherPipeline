library ieee;
use ieee.std_logic_1164.all;

entity pipe_IDEX is
port (ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite: in std_logic;
	reset, clk: in std_logic;
	ID_ALUOp: in std_logic_vector (1 downto 0);
	ID_branch: in std_logic;
	ID_PC4, ID_signext, ID_instruction: in std_logic_vector (31 downto 0);
	
	EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite: out std_losgic;
	EX_ALUOp: out std_logic_vector (1 downto 0);
	EX_branch: out std_logic;
	EX_PC4, EX_signext, EX_instruction: out std_logic_vector (31 downto 0);
 
        ID_RegDst: in std_logic;
        ID_RegRs1, ID_RegRs2: in std_logic_vector(31 downto 0); 
        ID_WRegRd, ID_WRegRs2 : in std_logic_vector(4 downto 0);
   

        EX_RegDst : out std_logic;  
        EX_RegRs1, EX_RegRs2: out std_logic_vector(31 downto 0);  
        EX_WRegRd, EX_WRegRs2 : out std_logic_vector(4 downto 0);
      
end pipe_IDEX;


architecture behavioral of pipe_IDEX is
begin
process
begin
if rising_edge(clk) then
	 EX_branch <= '0';
	 EX_MemToReg <= '0';
	 EX_RegWrite <= '0';
	 EX_MemWrite <= '0';
	 EX_MemRead <= '0';
	 EX_ALUSrc <= '0';
	 EX_RegDst <= '0';
         EX_ALUOp  <= "00";
	 EX_PC4 <= x"00000000";
	 EX_RegRs1  <= x"00000000";
	 EX_RegRs2  <=  x"00000000";
	 EX_signext  <=  x"00000000";
	 EX_WRegRd  <= "00000";
	 EX_WRegRs2  <= "00000";
else

	 EX_branch <= ID_branch;
	 EX_MemToReg <= ID_MemToReg;
	 EX_RegWrite <= ID_RegWrite;
	 EX_MemWrite <= ID_MemWrite;
	 EX_MemRead <= ID_MemRead;
	 EX_ALUSrc <= ID_ALUSrc;
	 EX_RegDst <= ID_RegDst;
     	 EX_ALUOp  <= ID_ALUOp;
	 EX_PC4 <= ID_PC4;
 	 EX_RegRs1  <= ID_RegRs1;
	 EX_RegRs2  <= ID_RegRs2;
	 EX_signext <= ID_signext;
	 EX_WRegRd  <= ID_WRegRd;
	 EX_WRegRs2  <= ID_WRegRs2;
         EX_instruction <= ID_instruction;

end if;
end process;
end behavioral;
