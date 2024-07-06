library ieee;
use ieee.std_logic_1164.all;



entity hex_mux is
port (
	desired_temp, vacation_temp 				: in std_logic_vector(3 downto 0); -- four 4-bit hex inputs
	vacation_mode									: in std_logic; -- 2-bit select input
	mux_temp											: out std_logic_vector (3 downto 0) -- The hex output
);

end hex_mux;

architecture mux_logic of hex_mux is

begin




	-- for the multiplexing of four hex input busses
	with vacation_mode select
	mux_temp <= desired_temp when '0',
				  vacation_temp when '1';
				
end mux_logic;		
