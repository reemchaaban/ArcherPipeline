library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_IF is
port (
reset,clk: in std_logic;
pc: in std_logic_vector (31 downto 0);
instruction: out std_logic_vector (31 downto 0);


);
end pipe_IF;add,mux

architecture behavioral of pipe_IF is 
component add4
        port (
            datain : in std_logic_vector (XLEN-1 downto 0);
            result : out std_logic_vector (XLEN-1 downto 0)
        );
    end component;
 component pc
        port (
            clk : in std_logic;
            rst_n : in std_logic;
            datain : in std_logic_vector(XLEN-1 downto 0);
            dataout : out std_logic_vector(XLEN-1 downto 0)
        );
    end component;
component mux2to1
        port (
            sel : in std_logic;
            input0 : in std_logic_vector (XLEN-1 downto 0);
            input1 : in std_logic_vector (XLEN-1 downto 0);
            output : out std_logic_vector (XLEN-1 downto 0)
        );
    end component;
    
--signal(s)
   -- pc signals
    signal d_pc_in : std_logic_vector (XLEN-1 downto 0);
    signal d_pc_out : std_logic_vector (XLEN-1 downto 0);
  -- add4 signals
    signal d_pcplus4 : std_logic_vector (XLEN-1 downto 0);
    -- instruction word fields

    signal d_rs1 : std_logic_vector (4 downto 0);
    signal d_rs2 : std_logic_vector (4 downto 0);
    signal d_rd : std_logic_vector (4 downto 0);
    signal d_funct3 : std_logic_vector (2 downto 0);
    signal d_funct7 : std_logic_vector (6 downto 0);
    
begin
	pc_inst : pc port map (clk => clk, rst_n => rst_n, datain => d_pc_in, dataout => d_pc_out);
	add4_inst : add4 port map (datain => d_pc_out, result => d_pcplus4);
	pc_mux : mux2to1 port map (sel => c_PCSrc, input0 => d_pcplus4, input1 => d_alu_out, output => d_pc_in);

end behavioral;
