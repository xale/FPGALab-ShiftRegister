----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		11:01:18 10/27/2010 
-- Design Name:		Lab ShReg
-- Module Name:		MaximalLengthLFSR - Behavioral 
-- Project Name:	Lab ShReg
-- Target Devices:	XILINX Spartan3 XC3S1000
-- Description:		A generic maximal-length LFSR.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MaximalLengthLFSR is
	generic
	(
		-- Length of LFSR
		-- defaults to eight bits
		-- allows all values in range except 37
		NUM_BITS	: natural range 2 to 168	:= 8
	);
	port
	(
		-- LFSR shift-step clock
		clk		: in	std_logic;
		
		-- Reset
		reset	: in	std_logic;
		
		-- LFSR value
		value	: out	std_logic_vector((NUM_BITS - 1) downto 0)
	);
end MaximalLengthLFSR;

architecture Behavioral of MaximalLengthLFSR is
	
	-- Internal signals
	-- Internal value copy
	signal value_internal	: std_logic_vector((NUM_BITS - 1) downto 0);
	
	-- Next value
	signal nextValue		: std_logic_vector((NUM_BITS - 1) downto 0);
	
	-- Next shift-in bit (computed from feedback taps)
	signal nextBit			: std_logic;
	
begin
	
	-- Value-control process
	process (clk, reset)
	begin
		
		-- On reset, clear register
		if (reset = AH_ON) then
		
			value_internal <= (others => '0');
		
		-- On rising clock edge, advance register
		elsif rising_edge(clk) then
			
			value_internal <= nextValue;
			
		end if;
		
	end process;
	
	-- Feedback bit logic
	-- FIXME: WRITEME
	
	-- Next value (shift current value, append feedback bit)
	nextValue <= value_internal((NUM_BITS - 2) downto 1) & nextBit;
	
	-- Value output
	value <= value_internal;
	
end Behavioral;
