library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use work.archer_pkg.all;

entity control is
  port (
    instruction : in std_logic_vector (31 downto 0);
    instruction_out: out std_logic_vector (31 downto 0);
);
end control;
architecture behavior of control is
 instruction_out<=instruction --it is is not specified in the slides what the control unit does with the input

end architecture ;
