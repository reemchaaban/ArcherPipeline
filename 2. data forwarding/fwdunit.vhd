library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.archer_pkg.all;

entity fwdunit is
    port (Rs1, Rs2: in std_logic_vector (31 downto 0);
    EXMEMRegRd, MEMWBRegRd: in std_logic_vector (31 downto 0);
    EXMEMRegWrite, MEMWBRegWrite: in std_logic;
    forwardA, forwardB: out std_logic_vector (1 downto 0)
    );
end fwdunit;

architecture behavioral of fwdunit is
begin
--if EXMEMRegWrite = '1' then

forwardA <= "10" when (EXMEMRegWrite) and (EXMEMRegRd != 0) and (EXMEMRegRD == Rs1)
	else "01" when (MEMWBRegWrite) and (MEMWBRegRd != 0) and (MEMWBRegRd == Rs1)
	else "00"

forwardB <= "10" when (EXMEMRegWrite) and (EXMEMRegRd != 0) and (EXMEMRegRD == Rs2)
	else "01" when (MEMWBRegWrite) and (MEMWBRegRd != 0) and (MEMWBRegRd == Rs2)
	else "00"

end architecture;


--in submission, we want to edit inputs to mux1 and mux2 in execute stage

