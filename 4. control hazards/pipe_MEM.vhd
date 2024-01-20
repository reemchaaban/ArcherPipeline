library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_MEM is
port (reset, clk: in std_logic;
         MEM_MemToReg, MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_branch, MEM_zero: in std_logic;
      MEM_ALURes, MEM_register_rt, MEM_branchPC : in std_logic_vector(31 downto 0);
      MEM_wreg_addr :in std_logic_vector(4 downto 0));
      WB_MemToReg, WB_RegWrite : out std_logic;
      WB_MemData, WB_ALURes: out std_logic_vector(31 downto 0);
      WB_wreg_addr: out std_logic_vector(4 downto 0));
);
end pipe_MEM;

architecture behavioral of pipe_MEM is 
  -- lmb signals

    signal d_byte_mask : std_logic_vector (1 downto 0);
    signal d_sign_ext_n : std_logic;
    signal d_data_mem_out : std_logic_vector (XLEN-1 downto 0);
begin
 ldmb_inst : lmb port map (proc_addr => d_alu_out, proc_data_send => d_regB,
                               proc_data_receive => d_data_mem_out, proc_byte_mask => d_byte_mask,
                               proc_sign_ext_n => d_sign_ext_n, proc_mem_write => c_mem_write, proc_mem_read => c_mem_read,
                               mem_addr => dmem_addr, mem_datain => dmem_datain, mem_dataout => dmem_dataout,
                               mem_wen => dmem_wen, mem_ben => dmem_ben);
end behavioral;
