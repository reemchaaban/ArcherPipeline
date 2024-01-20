library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_WB is
port (
reset, clk: in std_logic;

);
end pipe_WB;

architecture behavioral of pipe_WB is 
component mux2to1
        port (
            sel : in std_logic;
            input0 : in std_logic_vector (XLEN-1 downto 0);
            input1 : in std_logic_vector (XLEN-1 downto 0);
            output : out std_logic_vector (XLEN-1 downto 0)
        );
    end component;
    
--signal(s)
    signal d_mem_mux_out : std_logic_vector (XLEN-1 downto 0);
    signal c_mem_to_reg : std_logic;
    signal d_alu_out : std_logic_vector (XLEN-1 downto 0);
    signal d_data_mem_out : std_logic_vector (XLEN-1 downto 0);

begin
   mem_mux : mux2to1 port map (sel => c_mem_to_reg, input0 => d_alu_out, input1 => d_data_mem_out, output => d_mem_mux_out);
   
end behavioral;
