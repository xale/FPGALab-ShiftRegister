----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		16:07:56 10/25/2010 
-- Design Name:		Lab ShReg
-- Module Name:		ToggleD - Behavioral 
-- Project Name:	Lab ShReg
-- Target Devices:	XILINX Spartan3 XC3S1000
-- Tool versions:	
-- Description:		Push-button toggle switch using a shift-register buffer.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package,
--					Xilinx primitives (IBUF, BUFG)
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

use WORK.AHeinzDeclares.all;

entity ToggleD is
	port
	(
		-- Raw push-button input (active low)
		buttonRaw_AL	: in	std_logic;
		
		-- Sampling/synchronization clock
		clk				: in	std_logic;
		
		-- Reset
		reset			: in	std_logic;
		
		-- Raw button input after clock buffers and inverter
		bufferedRawOut	: out	std_logic;
		
		-- Toggle output value, after shift-register buffer/synchonization
		Q				: out	std_logic
	);
end ToggleD;

architecture Behavioral of ToggleD is
	
	-- Internal signals
	-- Push-button input buffer stages
	signal bufferedRaw_AL	: std_logic;	-- After IBUF
	signal bufferedRaw		: std_logic;	-- After IBUF + inverter
	
	-- Shift register value
	signal shiftRegValue		: std_logic_vector(2 downto 0);
	signal nextShiftRegValue	: std_logic_vector(2 downto 0);
	
	-- Internal copy of output signal
	signal Q_internal	: std_logic;
	
	-- Next-output signal
	signal nextQ		: std_logic;
	
begin
	
	-- Add an input buffer and an inverter to the raw input
	C_BUF1: IBUF port map(I => buttonRaw_AL, O => bufferedRaw_AL);
	bufferedRaw <= NOT bufferedRaw_AL;
	
	-- Synchronized input process
	process (clk, reset)
	begin
	
		-- On reset, clear the shift register and the output value
		if (reset = AH_ON) then
		
			shiftRegValue <= (others => AH_OFF);
			Q_internal <= AH_OFF;
		
		-- On a clock edge, shift a new value into the register from the input
		-- button, and update the output value of the toggle
		elsif rising_edge(clk) then
		
			shiftRegValue <= nextShiftRegValue;
			Q_internal <= nextQ;
		
		end if;
		
	end process;
	
	-- Next-shift register value (shifts in one bit at a time from the button)
	nextShiftRegValue <= shiftRegValue(1 downto 0) & bufferedRaw;
	
	-- Next-output logic (high when shift register is all ones, low when all
	-- zeroes, and unchanged--i.e., waiting for input to settle--otherwise)	
	nextQ <=	AH_ON when (shiftRegValue = "111") else
				AH_OFF when (shiftRegValue = "000") else
				Q_internal;
	
	-- Connect internal toggle value to output
	Q <= Q_internal;
	
	-- Expose the raw signal on an output via a clock buffer, for comparison
	C_BUF2:	BUFG port map(I=> bufferedRaw, O => bufferedRawOut);
	
end Behavioral;
