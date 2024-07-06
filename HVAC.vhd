library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- clk input is the LogicalStep 50MHz clock input
entity HVAC is

	port
	(
		HVAC_SIM					: in boolean;
		clk						: in std_logic; 
		run		   			: in std_logic;
		increase, decrease	: in std_logic;
		temp						: out std_logic_vector (3 downto 0)
	);

end entity;

architecture rtl of HVAC is

signal clk_2hz 			: std_logic;
signal HVAC_clock			: std_logic;
signal digital_counter 	: std_logic_vector(23 downto 0);


begin

-- clk_divider process generates a 2Hz Clck from the 50 Mhz clk

clk_divider: process (clk)
	variable   counter		:  unsigned(23 downto 0);
	
	begin
-- Synchronously update counter
		if (rising_edge(clk))  then
				 counter :=  counter + 1;
		end if;
		digital_counter <= std_logic_vector(counter);		

	end process;
	
clk_2hz <= digital_counter(23);

clk_mux: process (HVAC_SIM)
	begin
		if (HVAC_SIM)  then
				 HVAC_clock<=  clk;
		else
				 HVAC_clock<=  clk_2hz;
		end if;
	end process;



counter:	process (HVAC_clock)
	variable   cnt		:  unsigned(3 downto 0) := "0111";
	begin
		
	-- Synchronously update counter
	-- (ADD YOUR HVAC COUNTER FOR TEMPERATURE IF STATEMENTS HERE)
 
		if (rising_edge(HVAC_clock) AND run = '1') then -- HVAC only turns on when "run" is active
			
			if (increase = '1' AND cnt < "1111") then -- increase is active, so increment count by 1 (and check that max hasn't been reached)
				cnt := cnt + 1;
			
			elsif (decrease = '1' AND cnt > "0000") then -- decrease is active, so decrement count by 1 (and check that min hasn't been reached)
				cnt := (cnt - 1 );
			
			end if;
	end if;

	-- Output the current count	
		temp <= std_logic_vector(cnt);		
	end process;

end rtl;


