library ieee;
use ieee.std_logic_1164.all;


entity Compx1 is port (

InputA : in std_logic;
InputB : in std_logic;

AGTB : out std_logic;
AEQB : out std_logic;
ALTB : out std_logic
					

);
end Compx1;

architecture Compx1_logic of Compx1 is

begin 

-- By truth table and SOP, these are the determined logic gates to compare one bit comparator
AGTB <= InputA AND (NOT InputB);
AEQB <= InputA XNOR InputB;
ALTB <= (NOT InputA) AND InputB;



end Compx1_logic;