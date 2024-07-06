--pb_inverters


library ieee;
use ieee.std_logic_1164.all;



entity PB_Inverters is
port (
	pb_n	:	IN std_logic_vector(3 downto 0); -- Push buttons on active low
	pb		:	OUT std_logic_vector(3 downto 0) -- Push buttons on active high

);

end PB_Inverters;

architecture gates of PB_Inverters is

begin

pb <= not(pb_n);-- This operation will switch the polairty from low to high for the push buttons
				
end gates;		