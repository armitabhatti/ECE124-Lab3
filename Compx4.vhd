library ieee;
use ieee.std_logic_1164.all;


entity Compx4 is port (

InputA : in std_logic_vector(3 downto 0);
InputB : in std_logic_vector(3 downto 0);

AGTB : out std_logic;
AEQB : out std_logic;
ALTB : out std_logic
					

);
end Compx4;

architecture Compx4_logic of Compx4 is

component Compx1 port (
	InputA : in std_logic;
	InputB : in std_logic;

	AGTB : out std_logic;
	AEQB : out std_logic;
	ALTB : out std_logic
);
end component;

-- we have declared 3 "lists" such that they store the compared value at each POSITION of the inputs
signal AGTB_list : std_logic_vector(3 downto 0);
signal AEQB_list : std_logic_vector(3 downto 0);
signal ALTB_list : std_logic_vector(3 downto 0);

begin

-- each instance takes in the input at a certain position, so inst1 is comparing the 0th bit and outputting it to get stored
-- in its corresponding list position. i.e if A's 2nd bit is bigger than B's second bit, the AGTB_list(2) = 1
inst1: Compx1 port map (InputA(0), InputB(0), AGTB_list(0), AEQB_list(0), ALTB_list(0));
inst2: Compx1 port map (InputA(1), InputB(1), AGTB_list(1), AEQB_list(1), ALTB_list(1));
inst3: Compx1 port map (InputA(2), InputB(2), AGTB_list(2), AEQB_list(2), ALTB_list(2));
inst4: Compx1 port map (InputA(3), InputB(3), AGTB_list(3), AEQB_list(3), ALTB_list(3));


AGTB <= AGTB_list(3) OR (AEQB_list(3) AND AGTB_list(2)) OR (AEQB_list(3) AND AEQB_list(2) AND AGTB_list(1)) OR  (AEQB_list(3) AND AEQB_list(2) AND AEQB_list(1) AND AGTB_list(0));

AEQB <= AEQB_list(0) AND AEQB_list(1) AND AEQB_list(2) AND AEQB_list(3); 

ALTB <= ALTB_list(3) OR (AEQB_list(3) AND ALTB_list(2)) OR (AEQB_list(3) AND AEQB_list(2) AND ALTB_list(1)) OR  (AEQB_list(3) AND AEQB_list(2) AND AEQB_list(1) AND ALTB_list(0));

end Compx4_logic;




