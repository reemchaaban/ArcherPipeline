Library IEEE;
use IEEE.std_logic_1164.all;

entity pipe_EXMEM is
port (EX_MemToReg, EX_RegWrite, EX_MemWrite, EX_MemRead, EX_branch, EX_zero: in std_logic;
      EX_ALURes, EX_RegRs2, EX_branchPC : in std_logic_vector(31 downto 0);
      EX_wreg_addr :in std_logic_vector(4 downto 0);
      clk, reset : in std_logic;

      MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero: out std_logic;
      MEM_ALURes, MEM_RegRs2, MEM_branchPC : out std_logic_vector(31 downto 0);
      MEM_wreg_addr :out std_logic_vector(4 downto 0));
end pipe_EXMEM;


architecture behavioral of pipe_EXMEM is
begin
process
begin
if (rising_edge(clk)) then
	 MEM_zero <= '0';
	 MEM_branch <= '0';
	 MEM_MemToReg <= '0';
	 MEM_RegWrite <= '0';
	 MEM_MemWrite <= '0';
	 MEM_MemRead <= '0';
	 MEM_ALURes <= x"00000000";
	 MEM_RegRs2  <= x"00000000";
	 MEM_wreg_addr <= "00000";
	 MEM_branchPC <= x"00000000";

else

	 MEM_branchPC <=  EX_branch_PC;
	 MEM_zero <= EX_zero;
	 MEM_branch <= EX_branch;
	 MEM_MemToReg <= EX_MemToReg;
	 MEM_RegWrite <= EX_RegWrite;
	 MEM_MemWrite <= EX_MemWrite;
	 MEM_MemRead <= EX_MemRead;
	 MEM_ALURes <= EX_ALURes;
	 MEM_RegRs2  <= EX_RegRs2;
	 MEM_wreg_addr <= EX_wreg_addr;
end if;

end process;
end behavioral;
