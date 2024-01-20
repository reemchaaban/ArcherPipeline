library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archer_pkg.all;

entity archer_rv32i_pipe is
	port (
	clk,reset : in std_logic;
        IN_PORT : in std_logic_vector (31 downto 0);
        OUT_PORT : out std_logic_vector (31 downto 0));
end archer_rv32i_pipe;


architecture rtl of archer_rv32i_pipe is 

component pipe_IF
port (
reset,clk: in std_logic;
pc: in std_logic_vector (31 downto 0);
PCWrite: in std_logic;
instruction: out std_logic_vector (31 downto 0);
IF_PC4: out std_logic_vector (31 downto 0));
end component pipe_IF;

component pipe_ID
port (
ID_PC4, ID_instruction: in std_logic_vector (31 downto 0);
clk, reset: in std_logic;
ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite: in std_logic;

ID_ALUOp: out std_logic_vector (1 downto 0);
ID_branch: out std_logic;
ID_signext: out std_logic_vector (31 downto 0));
end component pipe_ID;

component pipe_EX
port (
       reset, clk: in std_logic;
	EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite: in std_logic;
	EX_ALUOp: in std_logic_vector (1 downto 0);
	EX_branch: in std_logic;
	EX_PC4, EX_signext, EX_instruction: in std_logic_vector (31 downto 0);
	MEM_MemToReg, MEM_RegWrite : out std_logic;
      MEM_MemData, MEM_ALURes: out std_logic_vector(31 downto 0);
      MEM_wreg_addr: out std_logic_vector(4 downto 0));
end component pipe_EX;

component pipe_MEM
port (
      reset, clk: in std_logic;
         MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero: in std_logic;
      MEM_ALURes, MEM_register_rt, MEM_branchPC : in std_logic_vector(31 downto 0);
      MEM_wreg_addr :in std_logic_vector(4 downto 0));
      WB_MemToReg, WB_RegWrite : out std_logic;
      WB_MemData, WB_ALURes: out std_logic_vector(31 downto 0);
      WB_wreg_addr: out std_logic_vector(4 downto 0));
end component pipe_MEM;

component pipe_WB
port (
reset, clk: in std_logic);
end component pipe_WB;    
                                            
component pipe_IFID_mod4
port(
        IF_PC4 : in std_logic_vector(31 downto 0);
	IF_instruction: in std_logic_vector( 31 downto 0);
	clk, reset : in std_logic;
        IFIDWrite: in std_logic;
	ID_PC4 : out std_logic_vector(31 downto 0);
	ID_instruction: out std_logic_vector( 31 downto 0)
	IF_Flush: in: std_logic_vector (31 downto 0));
end component;

component pipe_IDEX
port(ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite: in std_logic;
	reset, clk: in std_logic;
	ID_ALUOp: in std_logic_vector (1 downto 0);
	ID_branch: in std_logic;
	ID_PC4, ID_signext, ID_instruction: in std_logic_vector (31 downto 0);
	
	EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite: out std_logic;
	EX_ALUOp: out std_logic_vector (1 downto 0);
	EX_branch: out std_logic;
	EX_PC4, EX_signext, EX_instruction: out std_logic_vector (31 downto 0)
 
        id_RegDst: in std_logic;
        id_register_rs, id_register_rt: in std_logic_vector(31 downto 0); 
        id_wreg_rd, id_wreg_rt : in std_logic_vector(4 downto 0);
   

        ex_RegDst : out std_logic;  
        ex_register_rs, ex_register_rt: out std_logic_vector(31 downto 0);  
        ex_wreg_rd, ex_wreg_rt : out std_logic_vector(4 downto 0);
);
end component;

component pipe_EXMEM
port(EX_MemToReg, EX_RegWrite, EX_MemWrite, EX_MemRead, EX_branch, EX_zero: in std_logic;
      EX_ALURes, EX_register_rt, EX_branchPC : in std_logic_vector(31 downto 0);
      EX_wreg_addr :in std_logic_vector(4 downto 0);
      clk, reset : in std_logic;

      MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero: out std_logic;
      MEM_ALURes, MEM_register_rt, MEM_branchPC : out std_logic_vector(31 downto 0);
      MEM_wreg_addr :out std_logic_vector(4 downto 0));
end component;

component pipe_MEMWB
port(
      MEM_MemToReg, MEM_RegWrite : in std_logic;
      MEM_MemData, MEM_ALURes: in std_logic_vector(31 downto 0);
      MEM_wreg_addr: in std_logic_vector(4 downto 0);
      clk,reset : in std_logic;

      WB_MemToReg, WB_RegWrite : out std_logic;
      WB_MemData, WB_ALURes: out std_logic_vector(31 downto 0);
      WB_wreg_addr: out std_logic_vector(4 downto 0));
end component;
component hazarddetection 
PORT (
                IDEXMemread: in std_logic;
                IDEXRd : in std_logic_vector(31 downto 0);
                IFIDRs1: in std_logic_vector(31 downto 0);
                IFIDRs2: in std_logic_vector(31 downto 0);
                PCWrite: out std_logic;
                IFIDWrite: out std_logic;
                
        );
end component;

component control
PORT (
	instruction : in std_logic_vector (XLEN-1 downto 0);
	BranchCond : in std_logic; -- BR. COND. SATISFIED = 1; NOT SATISFIED = 0
	ALUOp : out std_logic_vector (3 downto 0)
	IF_Flush: in std_logic_vector (31 downto 0)
);
end component;

component lmb
port (
    proc_addr : in std_logic_vector (XLEN-1 downto 0);
    proc_data_send : in std_logic_vector (XLEN-1 downto 0);
    proc_data_receive : out std_logic_vector (XLEN-1 downto 0);
    proc_byte_mask : in std_logic_vector (1 downto 0); -- "00" = byte; "01" = half-word; "10" = word
    proc_sign_ext_n : in std_logic;
    proc_mem_write : in std_logic;
    proc_mem_read : in std_logic;
    mem_addr : out std_logic_vector (ADDRLEN-1 downto 0);s
    mem_datain : out std_logic_vector (XLEN-1 downto 0);
    mem_dataout : in std_logic_vector (XLEN-1 downto 0);
    mem_wen : out std_logic; -- write enable signal
    mem_ben : out std_logic_vector (3 downto 0) -- byte enable signals
);
end component;

--fwdunit components + signals found in pipe_EX file

architecture behavior of archer_rv32i_pipe is
	signal ifpc_addr: std_logic_vector(31 downto 0);
        signal idpc_branch: std_logic;
        signal if_instruction: std_logic_vector (31 downto 0);
        signal idpc_addr: std_logic_vector(31 downto 0);
        signal id_instruction: std_logic_vector (31 downto 0);
        signal idalu_op:std_logic_vector (1 downto 0);
        signal ID_signext: std_logic_vector (31 downto 0));
        signal ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite: std_logic;
        signal EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite: std_logic;
        signal EX_ALUOp: std_logic_vector (1 downto 0);
        signal expc_branch: std logic;
        signal EX_PC4, EX_signext, EX_instruction: std_logic_vector (31 downto 0);
        signal EX_MemToReg, EX_RegWrite, EX_MemWrite, EX_MemRead, EX_branch, EX_zero: std_logic;
        signal EX_ALURes, EX_register_rt, EX_branchPC :  std_logic_vector(31 downto 0);
        signal EX_wreg_addr : std_logic_vector(4 downto 0);
        signal MEM_MemToReg, MEM_RegWrite, MEM_MemWrite: std_logic;
        signal MEM_MemRead, MEM_branch, MEM_zero: std_logic;
        signal MEM_ALURes, MEM_register_rt, MEM_branchPC : std_logic_vector(31 downto 0);
        signal MEM_wreg_addr : std_logic_vector(4 downto 0));
        signal WB_MemToReg, WB_RegWrite : std_logic;
        signal WB_MemData, WB_ALURes: std_logic_vector(31 downto 0);
        signal WB_wreg_addr: std_logic_vector(4 downto 0));
	signal d_IF_Flush: std_logic_vector (31 downto 0);
	signal d_BranchCond: std_logic;
	signal d_ALUOp: std_logic_vector (3 down to 0);
        signal forwardA: std_logic_vector (1 downto 0);
        signal forwardB: std_logic_vector (1 downto 0);
	signal d_byte_mask : std_logic_vector (1 downto 0);
	signal d_sign_ext_n : std_logic;
	signal d_data_mem_out : std_logic_vector (XLEN-1 downto 0); 
begin

	a1: pipe_IF port map(clk,reset,IF_PC4,PCWrite,if_instruction,ifpc_addr)
	
        a2: pipe_IFID_mod4 port map(d_IF_FLush, ifpc_addr,if_instruction, clk, reset,IFIDWrite ,idpc_addr,id_instruction)
        
        a3: pipe_ID port map( idpc_addr,id_instruction, clk, reset, ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite, idalu_op, idpc_branch,ID_signext)
        
        a4: pipe_IDEX port map(ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite, reset, clk, alu_op, idpc_branch, idpc_addr, ID_signext, id_instruction, 
EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite,EX_ALUOp, expc_branch, EX_PC4, EX_signext, EX_instruction)  

        a5: pipe_EX port map(reset, clk, EX_ALUSrc, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_RegWrite, EX_ALUOp, expc_branch, EX_PC4, EX_signext, EX_instruction)
        
        a6: pipe_EXMEM port map(EX_MemToReg, EX_RegWrite, EX_MemWrite, EX_MemRead, EX_branch, EX_zero, EX_ALURes, EX_register_rt, EX_branchPC, EX_wreg_addr 
clk, reset, MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero, MEM_ALURes, MEM_register_rt, MEM_branchPC, MEM_ALURes, MEM_register_rt, MEM_branchPC)

        a7: pipe_MEM port map(MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero,MEM_ALURes, MEM_register_rt, MEM_branchPC,
MEM_wreg_addr, WB_MemToReg, WB_RegWrite, WB_MemData, WB_ALURes, WB_wreg_addr)

        a8: pipe_MEMWB port map(EM_MemToReg, MEM_RegWrite, MEM_MemData, MEM_ALURes, MEM_MemData, MEM_ALURes, clk, reset, WB_MemToReg, WB_RegWrite, WB_MemData, WB_ALURes, WB_wreg_addr)
        
        a9: pipe_MEM port map(reset, clk)
        
        a10: control port map (instruction => d_ID_instruction, BranchCond => d_BranchCond, ALUOp => IF_Flush)
        
        a11: lmb port map (d_alu_out, d_regB, d_data_mem_out, d_byte_mask, d_sign_ext_n, c_mem_write, c_mem_read, dmem_addr, dmem_datain, dmem_dataout, dmem_wen, dmem_ben);
        
        
        
end architecture;

