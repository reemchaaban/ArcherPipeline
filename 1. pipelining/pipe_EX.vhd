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

component mux2to1
        port (
            sel : in std_logic;
            input0 : in std_logic_vector (XLEN-1 downto 0);
            input1 : in std_logic_vector (XLEN-1 downto 0);
            output : out std_logic_vector (XLEN-1 downto 0)
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


architecture behavioral of pipe_EX is 
    -- alu_src1_mux signals 

    signal d_alu_src1 : std_logic_vector (XLEN-1 downto 0);

    -- alu_src2_mux signals 

    signal d_alu_src2 : std_logic_vector (XLEN-1 downto 0);

    -- alu signals

    signal d_alu_out : std_logic_vector (XLEN-1 downto 0);
    
begin
    alu_src1_mux : mux2to1 port map (sel => c_alu_src1, input0 => d_regA, input1 => d_lui_mux_out, output => d_alu_src1);
 
    alu_src2_mux : mux2to1 port map (sel => c_alu_src2, input0 => d_regB, input1 => d_immediate, output => d_alu_src2);

    alu_inst : alu port map (inputA => d_alu_src1, inputB => d_alu_src2, ALUop => c_alu_op, result => d_alu_out);
    
end behavioral;
