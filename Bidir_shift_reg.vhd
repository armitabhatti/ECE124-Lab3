-- Bidir_shift_reg

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Bidir_shift_reg is port --entity declaration of our bi directional shift register
	(
		CLK				: in std_logic := '0'; -- our clock signal
		RESET				: in std_logic := '0'; -- reset signal
		CLK_EN			: in std_logic := '0'; -- clock enable	
		LEFT0_RIGHT1	: in std_logic := '0'; -- to shit right?
		REG_BITS			: out std_logic_vector (7 downto 0)
	);
	end Entity;
	
Architecture ONE of Bidir_shift_reg IS

signal sreg : std_logic_vector (7 downto 0); --sreg stands for shift register

BEGIN

--inside our architecture, we have a process based on our only sensitive input being the CLOCK, so everytime the clock changes, the inputs are read again

process (CLK) is 
begin
	if (rising_edge(CLK)) then
		-- so we're on the rising edge of the clock, and now we consider different cases for our other inputs
		
		if (RESET = '1') then --since reset only occurs during clock rising edge, it is SYNCHRONOUS
		
			sreg <= "00000000"; -- if its rising edge of the clock abd reset is enabled, set the shift register all to 0
		
		elsif (CLK_EN = '1') then
		
			if (LEFT0_RIGHT1 = '1') then -- do we want to shift RIGHT
			
				sreg (7 downto 0) <= '1' & sreg(7 downto 1); -- if clock is enabled, we concatenate 1 to the beginning (SHIFT RIGHT)
				
			else -- so we want to shift LEFT
			
				sreg (7 downto 0) <= sreg(6 downto 0) & '0'; -- concatenate 0 at the end (SHIFT LEFT)
				
			end if;
			
		end if;
		
	end if;
	
	REG_BITS <= sreg; --assign the entity output to new sreg;
	
end process;

END one;