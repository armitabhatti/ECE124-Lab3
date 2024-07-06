library ieee;
use ieee.std_logic_1164.all;

-- the inputs and outputs declared below are ALL the inputs and outputs reqd
entity LogicalStep_Lab3_top is port (
	clkin_50		: in 	std_logic;
	pb_n			: in	std_logic_vector(3 downto 0); -- active low, as p_n usually tags active-low signal
 	sw   			: in  std_logic_vector(7 downto 0); 	
	
	-- MAKE SURE: hvac below should be commented out for a full compile, and the ASSIGNMENTS TO THIS PORT in architecture 
-- also need to be commented out
	
	----------------------------------------------------
--	HVAC_temp : out std_logic_vector(3 downto 0); -- used for simulations only. Comment out for FPGA download compiles.
	----------------------------------------------------
	
   leds			: out std_logic_vector(7 downto 0);
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;				    		-- seg7 digit1 selector
	seg7_char2  : out	std_logic				    		-- seg7 digit2 selector
	
); 
end LogicalStep_Lab3_top;

architecture design of LogicalStep_Lab3_top is
--
-- Provided Project Components Used
------------------------------------------------------------------- 

component SevenSegment  port (
   hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end component SevenSegment;

component segment7_mux port (
          clk        : in  std_logic := '0';
			 DIN2 		: in  std_logic_vector(6 downto 0);	
			 DIN1 		: in  std_logic_vector(6 downto 0);
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
        );
end component segment7_mux;



	
component Tester port (
 MC_TESTMODE				: in  std_logic;
 I1EQI2,I1GTI2,I1LTI2	: in	std_logic;
	input1					: in  std_logic_vector(3 downto 0);
	input2					: in  std_logic_vector(3 downto 0);
	TEST_PASS  				: out	std_logic							 
	); 
	end component;
	
component HVAC 	port (
	HVAC_SIM					: in boolean; 										
	clk						: in std_logic; 
	run		   			: in std_logic;
	increase, decrease	: in std_logic;
	temp						: out std_logic_vector (3 downto 0)
	);
end component;
------------------------------------------------------------------
-- Add any Other Components here
------------------------------------------------------------------


--Pg 8: declare compx4 as component
component Compx4 is port (

InputA : in std_logic_vector(3 downto 0);
InputB : in std_logic_vector(3 downto 0);

AGTB : out std_logic;
AEQB : out std_logic;
ALTB : out std_logic
					

);
end component;

--Pg 18: declare bidir shift register as component
component Bidir_shift_reg is port --entity declaration of our bi directional shift register
	(
		CLK				: in std_logic := '0'; -- our clock signal
		RESET				: in std_logic := '0'; -- reset signal
		CLK_EN			: in std_logic := '0'; -- clock enable	
		LEFT0_RIGHT1	: in std_logic := '0'; -- to shit right of 1, to shift left if 0
		REG_BITS			: out std_logic_vector (7 downto 0)
	);
	end component;

--Pg 21: declare udbincounter as component and instance
component U_D_Bin_Counter8bit is port
	(
		CLK				: in std_logic ; --clock input
		RESET				: in std_logic ; --synch reset
		CLK_EN			: in std_logic ; --enable input to allow counting
		UP1_DOWN0		: in std_logic ; --counts up if 1 and down if 0
		COUNTER_BITS   : out std_logic_vector (7 downto 0) -- output of 8 bits!
	);
end component;

--pb inverters
component PB_Inverters is
port (
	pb_n	:	IN std_logic_vector(3 downto 0); -- Push buttons on active low
	pb		:	OUT std_logic_vector(3 downto 0) -- Push buttons on active high
	);
end component;


component hex_mux is
port (
	desired_temp, vacation_temp 				: in std_logic_vector(3 downto 0); -- four 4-bit hex inputs
	vacation_mode										: in std_logic; -- 2-bit select input
	mux_temp											: out std_logic_vector(3 downto 0) -- The hex output
);

end component;

component Energy_monitor is port
	(
		vacation_mode			: in std_logic; -- activates LED and changes inc/dec/run			
		MC_test_mode			: in std_logic; -- comparator testmode which deactivates run mode and blower
		window_open				: in std_logic; -- activates LED and changes inc/dec/run 
		door_open				: in std_logic; -- activates LED and changes inc/dec/run
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
end component;



------------------------------------------------------------------	
-- Create any additional internal signals to be used

signal pb_real       : std_logic_vector(3 downto 0); -- Inverted push buttons
signal mux_temp 		: std_logic_vector(3 downto 0);
signal current_temp 	: std_logic_vector(3 downto 0);
signal AGTB, AEQB, ALTB : std_logic;
signal run, increase, decrease: std_logic;
signal desired_temp, vacation_temp : std_logic_vector(3 downto 0);
------------------------------------------------------------------	
constant HVAC_SIM : boolean := FALSE; -- set to FALSE when compiling for FPGA download to LogicalStep board 
                                      -- or TRUE for doing simulations with the HVAC Component
------------------------------------------------------------------	

-- global clock
signal clk_in					: std_logic;
signal hex_A, hex_B 			: std_logic_vector(3 downto 0);
signal hexA_7seg, hexB_7seg: std_logic_vector(6 downto 0);

------------------------------------------------------------------- 
begin -- Here the circuit begins

clk_in <= clkin_50;	--hook up the clock input

-- temp inputs hook-up to internal busses.
desired_temp <= sw(3 downto 0);
vacation_temp <= sw(7 downto 4);


inst1: sevensegment port map (mux_temp, hexA_7seg);
inst2: sevensegment port map (current_temp, hexB_7seg);
inst3: segment7_mux port map (clk_in, hexA_7seg, hexB_7seg, seg7_data, seg7_char2, seg7_char1);

inst4: Compx4 port map (mux_temp, current_temp, AGTB, AEQB, ALTB); 

inst7: PB_Inverters port map (pb_n, pb_real);
inst8: HVAC port map (HVAC_SIM, clk_in, run, increase, decrease, current_temp);
inst9: hex_mux port map (desired_temp, vacation_temp, pb_real(3), mux_temp);
inst10: Energy_monitor port map (pb_real(3), pb_real(2), pb_real(1), pb_real(0), AGTB, AEQB, ALTB, leds(0), leds(1), leds(2), leds(3), leds(4), leds(5), leds(7), run, increase, decrease);
inst11: Tester port map (pb_real(2), AEQB, AGTB, ALTB, desired_temp, current_temp, leds(6));


		
end design;

