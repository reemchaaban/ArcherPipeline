library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_ID is
port (
ID_PC4, ID_instruction: in std_logic_vector (31 downto 0);
clk, reset: in std_logic;
ID_ALUSrc, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_RegWrite: in std_logic;

ID_ALUOp: out std_logic_vector (1 downto 0);
ID_branch: out std_logic;
ID_signext: out std_logic_vector (31 downto 0));
end pipe_ID;

architecture behavioral of pipe_ID is 

component pipe_IFID is
port (
	IF_PC4 : in std_logic_vector(31 downto 0);
	IF_instruction: in std_logic_vector( 31 downto 0);
	clk, reset : in std_logic;
	ID_PC4 : out std_logic_vector(31 downto 0);
	ID_instruction: out std_logic_vector( 31 downto 0)
);

component mux2to1 is
port (
	sel : in std_logic;
        input0 : in std_logic_vector (XLEN-1 downto 0);
        input1 : in std_logic_vector (XLEN-1 downto 0);
        output : out std_logic_vector (XLEN-1 downto 0)
);

component ID_add is
port (
	datain1, datain2: in std_logic_vector (XLEN-1 downto 0);
	result: out std_logic_vector (XLEN-1 downto 0)
);

component immgen is
port (
	instruction : in std_logic_vector (XLEN-1 downto 0);
        immediate : out std_logic_vector (XLEN-1 downto 0)
);

component regfile is
port (
        clk : in std_logic;
        rst_n : in std_logic;
        RegWrite : in std_logic;
        rs1 : in std_logic_vector (LOG2_XRF_SIZE-1 downto 0);
        rs2 : in std_logic_vector (LOG2_XRF_SIZE-1 downto 0);
        rd : in std_logic_vector (LOG2_XRF_SIZE-1 downto 0);
        datain : in std_logic_vector (XLEN-1 downto 0);
        regA : out std_logic_vector (XLEN-1 downto 0);
        regB : out std_logic_vector (XLEN-1 downto 0)
);

component control is 
port (
    instruction : in std_logic_vector (XLEN-1 downto 0);
    BranchCond : in std_logic; -- BR. COND. SATISFIED = 1; NOT SATISFIED = 0
    Jump : out std_logic;
    Lui : out std_logic;
    PCSrc : out std_logic;
    RegWrite : out std_logic;
    ALUSrc1 : out std_logic;
    ALUSrc2 : out std_logic;
    ALUOp : out std_logic_vector (3 downto 0);
    MemWrite : out std_logic;
    MemRead : out std_logic;
    MemToReg : out std_logic
);

component fwdunit is
port (
	Rs1, Rs2: in std_logic;
	EXMEMRegRd, MEMWBRegRd: in std_logic;
	forwardA, forwardB: out std_logic;
);

--equal sign - shift left 1

--signal(s)

--pipe_IFID signals
	signal d_IF_PC4: std_logic_vector(31 downto 0);
	signal d_IF_instruction: std_logic_vector (31 downto 0);
	signal d_ID_PC4: std_logic_vector(31 downto 0);
	signal d_ID_instruction: std_logic_vector( 31 downto 0));
	
--control signals
    signal c_branch_out : std_logic;
    signal c_jump : std_logic;
    signal c_lui : std_logic;
    signal c_PCSrc : std_logic;
    signal c_reg_write : std_logic;
    signal c_alu_src1 : std_logic;
    signal c_alu_src2 : std_logic;
    signal c_alu_op : std_logic_vector (3 downto 0);
    signal c_mem_write : std_logic;
    signal c_mem_read : std_logic;
    signal c_mem_to_reg : std_logic;
    
--mux2to1 signals
signal

--add4 signals
    signal d_branchtarget : std_logic_vector (XLEN-1 downto 0);
--immgen signals
    signal d_immediate : std_logic_vector (XLEN-1 downto 0);
--regfile signals
    signal d_reg_file_datain : std_logic_vector (XLEN-1 downto 0);
    signal d_regA : std_logic_vector (XLEN-1 downto 0);
    signal d_regB : std_logic_vector (XLEN-1 downto 0);
--instruction field signals
    signal d_rs1 : std_logic_vector (4 downto 0);
    signal d_rs2 : std_logic_vector (4 downto 0);
    signal d_rd : std_logic_vector (4 downto 0);
    signal d_funct3 : std_logic_vector (2 downto 0);
    signal d_funct7 : std_logic_vector (6 downto 0);
    
 

begin
--pipe_IFID port map
pipe_IFID_inst: pipe_IFID port map (IF_PC4 => d_IF_PC4, IF_instruction => d_IF_instruction, ID_PC4 => d_ID_PC4, ID_instruction => d_ID_instruction );
--control port map
control_inst : control port map (instruction => d_instr_word, BranchCond => c_branch_out, 
	Jump => c_jump, Lui => c_lui, PCSrc => c_PCSrc, RegWrite => c_reg_write,
	ALUSrc1 => c_alu_src1, ALUSrc2 => c_alu_src2, ALUOp => c_alu_op, MemWrite => c_mem_write,
	MemRead => c_mem_read, MemToReg => c_mem_to_reg);
--mux2to1 port map
pc_mux : mux2to1 port map (sel => c_PCSrc, input0 => d_pcplus4, input1 => d_alu_out, output => d_pc_in);
--ID_add port map
ID_add_inst : ID_add port map (datain1 => d_immediate, datain2 => d_ID_PC4, result => d_branchtarget);
--immgen port map
immgen_inst : immgen port map (instruction => d_instr_word, immediate => d_immediate);
--regfile port map
RF_inst : regfile port map (clk => clk, rst_n => rst_n, RegWrite => c_reg_write, rs1 => d_rs1, rs2 => d_rs2, rd => d_rd, datain => d_reg_file_datain, regA => d_regA, regB => d_regB);
--instruction field 
d_rs1 <= d_instr_word (LOG2_XRF_SIZE+14 downto 15);
d_rs2 <= d_instr_word (LOG2_XRF_SIZE+19 downto 20);
d_rd <= d_instr_word (LOG2_XRF_SIZE+6 downto 7);
d_funct3 <= d_instr_word (14 downto 12);
d_funct7 <= d_instr_word (31 downto 25);


end behavioral;


