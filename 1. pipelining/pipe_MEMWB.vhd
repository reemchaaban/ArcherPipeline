Library IEEE;
use IEEE.std_logic_1164.all;
entity pipe_MEMWB is

port (MEM_MemToReg, MEM_RegWrite : in std_logic;
      MEM_MemData, MEM_ALURes: in std_logic_vector(31 downto 0);
      MEM_wreg_addr: in std_logic_vector(4 downto 0);
      clk,reset : in std_logic;

      WB_MemToReg, WB_RegWrite : out std_logic;
      WB_MemData, WB_ALURes: out std_logic_vector(31 downto 0);
      WB_wreg_addr: out std_logic_vector(4 downto 0));
end pipe_MEMWB;

architecture behavioral of pipe_MEMWB is
begin
process
begin
if (rising_edge(clk)) then
         WB_MemToReg <= '0';
	 WB_RegWrite <=  '0';
	 WB_MemData <=  x"00000000";
	 WB_ALURes <=  x"00000000";
 	 WB_wreg_addr <= "00000";
else
         WB_MemToReg <= MEM_MemToReg;
	 WB_RegWrite <=  MEM_RegWrite;
	 WB_MemData <=  MEM_MemData;
	 WB_ALURes <=  MEM_ALURes;
 	 WB_wreg_addr <= MEM_wreg_addr;
end if;
end process;
end behavioral;

