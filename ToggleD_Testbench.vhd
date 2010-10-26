		----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		16:57 10/25/2010 
-- Design Name:		Lab ShReg
-- Module Name:		ToggleD_Testbench
-- Project Name:	Lab ShReg
-- Target Devices:	N/A (Behavioral Simulation)
-- Description:		Test bench for a shift-register buffered toggle switch.
--
-- Dependencies:	IEEE standard libraries, ToggleD entity
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ToggleD_Testbench is
end ToggleD_Testbench;

architecture model of ToggleD_Testbench is

	-- Component declaration for Unit Under Test (UUT)
	component ToggleD is
	port
	(
		buttonRaw_AL	: in	std_logic;
		clk				: in	std_logic;
		reset			: in	std_logic;
		bufferedRawOut	: out	std_logic;
		Q				: out	std_logic
	);

	end component;
	
	-- UUT control clock
	signal clk			: std_logic := '0';
	
	-- Inputs to UUT (w/ initial values)
	constant NUM_INPUTS	: integer := 2;
	signal INPUTS		: std_logic_vector(0 to (NUM_INPUTS - 1)) := "11";
	alias buttonRaw_AL	: std_logic is INPUTS(0);
	alias reset			: std_logic is INPUTS(1); -- Should always start high, to simulate power-on reset
	
	-- Outputs read from UUT
	signal bufferedRawOut	: std_logic;
	signal Q				: std_logic;
	
	-- Vectors containing input values to test
	constant NUM_VALUES		: integer := 20;
	type InputVector is array(natural range <>) of std_logic_vector(0 to (NUM_INPUTS - 1));
	constant INPUT_VALUES	: InputVector(0 to (NUM_VALUES - 1)) := ("10", "00", "10", "00", "00", "10", "00", "00", "00", "10", "00", "10", "10", "10", "00", "00", "00", "00", "01", "11");	
	
	-- Clock period
	constant CLK_PERIOD:	time := 20 ns;

begin

	-- Instantiate UUT, mapping inputs and outputs to local signals
	uut: ToggleD
	port map
	(
		buttonRaw_AL => buttonRaw_AL,
		clk => clk,
		reset => reset,
		bufferedRawOut => bufferedRawOut,
		Q => Q
	);
	
	-- Clock tick process
	process is begin
	
		-- Clock low for half period
		clk <= '0';
		wait for (CLK_PERIOD / 2);
	
		-- Clock high for half period
		clk <= '1';
		wait for (CLK_PERIOD / 2);
	
		-- (Repeats forever)
		
	end process;
	
	-- Main model process
	tb : process

		-- Process-local variables
		-- Loop counter
		variable valueIndex: integer := 0;

	begin

		-- Allow time for global reset
		wait for 100 ns;
		
		-- Loop over all test signal values
		for valueIndex in 0 to (NUM_VALUES - 1) loop
					-- Read next set of input values from constant list
			INPUTS <= INPUT_VALUES(valueIndex);
		
			-- Pause to allow state to settle
			wait for CLK_PERIOD;
		
		end loop;
		
		-- End of test; wait for simulation to finish
		wait;
		
	end process;

end model;
