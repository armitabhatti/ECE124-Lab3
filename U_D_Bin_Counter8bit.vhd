-- U_D_Bin_Counter8bit

-- we are not creating a 8 bit up/down counter with synch reset

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity U_D_Bin_Counter8bit is port
	(
		CLK				: in std_logic :='0' ; --clock input
		RESET				: in std_logic :='0' ; --synch reset
		CLK_EN			: in std_logic :='0' ; --enable input to allow counting
		UP1_DOWN0		: in std_logic :='0' ; --counts up if 1 and down if 0
		COUNTER_BITS   : out std_logic_vector (7 downto 0) -- output of 8 bits!
	);
end Entity;

	ARCHITECTURE one OF U_D_Bin_Counter8bit IS
	
	Signal ud_bin_counter : unsigned(7 downto 0); -- declare signal to store counter output, and unsigned for only pos numbers

Begin

process (CLK) is -- the only sensitivity input is the clock signal
begin
	if (rising_edge(CLK)) then -- only make changed during rising edge (no asynch processes at all)
		if (RESET = '1') then -- if reset is true, set to 0'
			ud_bin_counter <= "00000000";
		
		elsif (CLK_EN = '1') then -- check that it is enabled to start counting
	
			if(UP1_DOWN0 ='1') then --if 1 then count up by adding 1 bit
				ud_bin_counter <= (ud_bin_counter +1);
			
			else
				ud_bin_counter <= (ud_bin_counter -1); -- otherwise, it must be 0, so count down by subtracting one bit
			
			end if;
		end if;
	end if;
	
	COUNTER_BITS <= std_logic_vector (ud_bin_counter); --type cast unsigned binary number to logic vector
	
end process;

end;