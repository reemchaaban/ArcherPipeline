LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY hazarddetection IS
        PORT (
                IDEXMemread: in std_logic;
                IDEXRd : in std_logic_vector(31 downto 0);
                IFIDRs1: in std_logic_vector(31 downto 0);
                IFIDRs2: in std_logic_vector(31 downto 0);
                PCWrite: out std_logic;
                IFIDWrite: out std_logic;
                muxsel: out std_logic;
                
        );

END hazarddetection;
architecture behavior of hazarddetection is
signal stall:std_logic;
begin
       muxsel<= '1' when (IDEXMemread='1' and ((IDEXRd=IFIDRs1) or (IDEXRd=IFIDRs2))
       else '0';
end behavior;
