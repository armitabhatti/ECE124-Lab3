-- Energy_monitor.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- energy control block DIRECTS hvac to increase or decrease, (depending on outputs from compx4 comparator)
-- this also includes activating the "run signal"- when current_temp = mux_temp, run is deactivated
-- run is also deactivated when window_open, door_open are detected as open=1, or if mc_test_mode is on=1
-- AC is active when mux_temp (desired) is less than current_temp (real)
-- fornace is active when mux_temp (desired) is greater than current temp (real)
-- blower active when mux_temp = current temp (make sure checkingg for window/door/MC)
-- door open os acyove of door_open sensor is ON as well as window opne and vacation on

-- for energy monitor, there are 7 inputs and 10 outputs that we can focus on


Entity Energy_monitor is port
	(
		--PBS
		vacation_mode			: in std_logic; -- PB 3	
		MC_test_mode			: in std_logic; -- PB 2- comparator testmode which deactivates run mode and blower
		window_open				: in std_logic; -- PB 1
		door_open				: in std_logic; -- PB 0
		
		AGTB						: in std_logic; -- activates LED furnace
		AEQB						: in std_logic; -- activates LED blower
		ALTB						: in std_logic; -- activates LED AC
		
		furnace					: out std_logic; --led 0
		at_temp					: out std_logic; --led 1
		AC							: out std_logic; --led 2
		blower					: out std_logic; --led 3
		window					: out std_logic; --led 4
		door						: out std_logic; --led 5
		vacation					: out std_logic; --led 7
		run, increase, decrease : out std_logic --run, increase, decrease outputs that connect to HVAC

	);
end Entity;

	ARCHITECTURE one OF Energy_monitor IS
	
Begin


	process(vacation_mode, MC_test_mode, window_open, door_open, AGTB, AEQB, ALTB) is 
	
	
	begin
	
	--basic push button  
	-- the following if statements turn on the associated indicators for push-button to led!
	

	
	--default values
		furnace <= '0';
		at_temp <= '0';
		AC <= '0';
		blower <= '0';
		window <= '0';
		door <= '0';
		vacation <= '0';
		increase <= '0';
		decrease <= '0';
		run <= '1';
		
		if AEQB='1' then
			run <= '0'; -- REQ 3
		end if;
		
		if window_open='1' or door_open='1' then
			run<= '0'; --REQ 4
		end if;
			
		if MC_test_mode = '1' then
			run <= '0'; --REQ 5
		end if;
		
		if ALTB='1' then
			AC <= '1'; --REQ 6
			decrease<= '1';
		end if;
		
		if AGTB='1' then
			furnace <= '1'; --REQ 7
			increase<='1';
		end if;
			
		if AEQB='1' then
			at_temp <= '1'; --REQ 8
			blower <= '0';
		end if;
		
		if AEQB='0' AND MC_test_mode='0' AND window_open='0' AND door_open='0' then
			blower <= '1';
		end if;
		
	
	if window_open ='1' then
		window <= '1'; --REQ 11
	end if;
	
	if door_open = '1' then
		door <= '1'; --REQ 10
	end if;
	
	if vacation_mode = '1' then
		vacation <= '1'; --REQ 12
	end if;

	
--	run <= NOT(AEQB='1' OR window_open='1' OR door_open='1' OR MC_test_mode='1');
--	
--	AC <= ALTB;
--	decrease <= ALTB;
--	
--	furnace <= AGTB;
--	increase <= AGTB;
--	
--	at_temp <= AEQB;
--	
--	blower <= NOT(AEQB='1') AND NOT(MC_test_mode='1' OR window_open='1' OR door_open='1');
--	
	
	

	end Process;

end one;