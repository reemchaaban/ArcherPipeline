library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_EX is
port (reset, clk: in std_logic;
	EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite: in std_logic;
	EX_ALUOp: in std_logic_vector (1 downto 0);
	EX_branch: in std_logic;
	EX_PC4, EX_signext, EX_instruction: in std_logic_vector (31 downto 0);
	
      MEM_MemToReg, MEM_RegWrite : out std_logic;
      MEM_MemData, MEM_ALURes: out std_logic_vector(31 downto 0);
      MEM_wreg_addr: out std_logic_vector(4 downto 0);

);
end pipe_EX;

component mux3to1
Port(sel: in std_logic_vector(1 downto 0);
     input0: in std_logic_vector (31 downto 0);
     input1: in std_logic_vector (31 downto 0);
     input2: in std_logic_vector (31 downto 0);
     output: out std_logic_vector (31 downto 0);
);
    end component;
    
component alu
        port (
            inputA : in std_logic_vector (XLEN-1 downto 0);
            inputB : in std_logic_vector (XLEN-1 downto 0);
            ALUop : in std_logic_vector (3 downto 0);
            result : out std_logic_vector (XLEN-1 downto 0)
        );
   end component;
   
component fwdunit	
port (
    Rs1, Rs2: in std_logic;
    EXMEMRegRd, MEMWBRegRd: in std_logic;
    EXMEMRegWrite, MEMWBRegWrite: in std_logic;
    forwardA, forwardB: out std_logic;
);
end component;
   
component pipe_IDEX 
	port (
	ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite: in std_logic;
	reset, clk: in std_logic;
	ID_ALUOp: in std_logic_vector (1 downto 0);
	ID_branch: in std_logic;
	ID_PC4, ID_signext, ID_instruction: in std_logic_vector (31 downto 0);
	
	EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite: out std_logic;
	EX_ALUOp: out std_logic_vector (1 downto 0);
	EX_branch: out std_logic;
	EX_PC4, EX_signext, EX_instruction: out std_logic_vector (31 downto 0);
 
        ID_RegDst: in std_logic;
        ID_RegRs1, ID_RegRs2: in std_logic_vector(31 downto 0); 
        ID_WRegRd, ID_WRegRs2 : in std_logic_vector(4 downto 0);
   

        EX_RegDst : out std_logic;  
        EX_RegRs1, EX_RegRs2: out std_logic_vector(31 downto 0)
        EX_WRegRd, EX_WRegRs2 : out std_logic_vector(4 downto 0)
	);
end component;

component pipe_EXMEM 
	port (
      EX_MemToReg, EX_RegWrite, EX_MemWrite, EX_MemRead, EX_branch, EX_zero: in std_logic;
      EX_ALURes, EX_RegRd, EX_branchPC : in std_logic_vector(31 downto 0);
      EX_wreg_addr :in std_logic_vector(4 downto 0);
      clk, reset : in std_logic;

      MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero: out std_logic;
      MEM_ALURes, MEM_RegRd, MEM_branchPC : out std_logic_vector(31 downto 0);
      MEM_wreg_addr :out std_logic_vector(4 downto 0)
	);

component pipe_MEMWB
	port (
      MEM_MemToReg, MEM_RegWrite : in std_logic;
      MEM_MemData, MEM_ALURes, MEM_RegRd: in std_logic_vector(31 downto 0);
      MEM_wreg_addr: in std_logic_vector(4 downto 0);
      clk,reset : in std_logic;

      WB_MemToReg, WB_RegWrite : out std_logic;
      WB_MemData, WB_ALURes, WB_RegRd: out std_logic_vector(31 downto 0);
      WB_wreg_addr: out std_logic_vector(4 downto 0)
	);

architecture behavioral of pipe_EX is 
    -- alu_src1_mux signals 

    signal d_alu_src1 : std_logic_vector (XLEN-1 downto 0);

    -- alu_src2_mux signals 

    signal d_alu_src2 : std_logic_vector (XLEN-1 downto 0);

    -- alu signals

    signal d_alu_out : std_logic_vector (XLEN-1 downto 0);
    
    --fwdunit signals
    signal d_forwardA: std_logic_vector (1 downto 0);
    signal d_forwardB: std_logic_vector (1 downto 0);
    
    --pipe_IDEX signals
    signal d_ID_RegRs1: std_logic_vector (31 downto 0);
    signal d_ID_RegRs2: std_logic_vector (31 downto 0);
    signal d_ID_ALUSrc: std_logic;
    signal d_ID_MemtoReg: std_logic;
    signal d_ID_MemRead: std_logic;
    signal d_ID_MemWrite: std_logic;
    signal d_ID_RegWrite: std_logic;
    signal d_ID_ALUOp: std_logic_vector (1 downto 0);
    signal d_ID_branch: std_logic;
    signal d_ID_PC4: std_logic_vector (31 downto 0);
    signal d_ID_signext: std_logic_vector (31 downto 0);
    signal d_ID_instruction: std_logic_vector (31 downto 0);
    signal d_EX_ALUSrc: std_logic;
    signal d_EX_MemtoReg: std_logic;
    
    
EX_MemRead, EX_MemWrite, EX_RegWrite: out std_logic;
	EX_ALUOp: out std_logic_vector (1 downto 0);
	EX_branch: out std_logic;
	EX_PC4, EX_signext, EX_instruction: out std_logic_vector (31 downto 0);
 
        ID_RegDst: in std_logic;
        --ID_WRegRd, ID_WRegRs2 : in std_logic_vector(4 downto 0);
   

        EX_RegDst : out std_logic;  
        --EX_WRegRd, EX_WRegRs2 : out std_logic_vector(4 downto 0)
    
    --pipe_EXMEM signals
	signal EX_MemToReg, EX_RegWrite, EX_MemWrite, EX_MemRead, EX_branch, EX_zero: std_logic;
        signal EX_ALURes, EX_RegRs2, EX_branchPC :  std_logic_vector(31 downto 0);
        signal EX_wreg_addr : std_logic_vector(4 downto 0);
        signal MEM_MemToReg, MEM_RegWrite, MEM_MemWrite: std_logic;
        signal MEM_MemRead, MEM_branch, MEM_zero: std_logic;
        signal MEM_ALURes, MEM_RegRs2, MEM_branchPC : std_logic_vector(31 downto 0);
        signal MEM_wreg_addr : std_logic_vector(4 downto 0));
    
    --pipe_MEMWB signals
  	signal MEM_MemToReg, MEM_RegWrite, MEM_MemWrite: std_logic;
        signal MEM_MemRead, MEM_branch, MEM_zero: std_logic;
        signal MEM_ALURes, MEM_RegRs2, MEM_branchPC : std_logic_vector(31 downto 0);
        signal MEM_wreg_addr : std_logic_vector(4 downto 0));
        signal WB_MemToReg, WB_RegWrite : std_logic;
        signal WB_MemData, WB_ALURes: std_logic_vector(31 downto 0);
        signal WB_wreg_addr: std_logic_vector(4 downto 0));

    
    
    
    
    
begin
    a1 : mux3to1 port map (d_forwardA, d_regA, d_lui_mux_out, d_alu_src1);
    
    a2 : mux3to1 port map (d_forwardB, d_regB, d_immediate, d_alu_src2);

    a3 : alu port map (d_alu_src1, d_alu_src2, c_alu_op, d_alu_out);
    
    a4 : fwdunit port map (d_ID_RegRs1, d_ID_RegRs2, d_MEM_RegRd, d_WB_RegRd, d_MEM_RegWrite, d_WB_RegWrite, d_forwardA, d_forwardB);
    
    a5: pipe_IDEX port map (ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite, reset, clk, alu_op, idpc_branch, idpc_addr, ID_signext, id_instruction, 
EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite,EX_ALUOp, expc_branch, EX_PC4, EX_signext, EX_instruction);
    
    a6: pipe_EXMEM port map (EX_MemToReg, EX_RegWrite, EX_MemWrite, EX_MemRead, EX_branch, EX_zero, EX_ALURes, EX_RegRs2, EX_branchPC, EX_wreg_addr 
clk, reset, MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero, MEM_ALURes, MEM_RegRs2, MEM_branchPC, MEM_ALURes, MEM_RegRs2, MEM_branchPC);
    
    a7: pipe_MEMWB port map (EM_MemToReg, MEM_RegWrite, MEM_MemData, MEM_ALURes, MEM_MemData, MEM_ALURes, clk, reset, WB_MemToReg, WB_RegWrite, WB_MemData, WB_ALURes, WB_wreg_addr);
    
    
    
    
end behavioral;
