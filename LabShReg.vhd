----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		13:06:19 10/26/2010 
-- Design Name:		Lab ShReg
-- Module Name:		LabShReg - Behavioral 
-- Project Name:	Lab ShReg
-- Target Devices:	XILINX Spartan3 XC3S1000
-- Description:		Top-level entity for a LFSR-based LED duty-cycle controller.
--
-- Dependencies:	IEEE standard libraries, ToggleD entity,
--					CounterClockDivider entity, AHeinzDeclares package,
--					FPGALabDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;
use WORK.FPGALabDeclares.all;

entity LabShReg is
	port
	(
		-- Input 50 MHz clock
		clk50	: in	std_logic;
		
		-- Input push-button switch (active-low)
		sw1		: in	std_logic;
		
		-- Reset button (active-low)
		swrst	: in	std_logic;
		
		-- Flash memory controller-enable/disable
		fceb	: out	std_logic;
		
		-- Seven-segment LEDs
		ls		: out	std_logic_vector(6 downto 0);
		rs		: out	std_logic_vector(6 downto 0)
	);
end LabShReg;

architecture Behavioral of LabShReg is
	
	-- Internal signals
	-- Inverted reset signal
	signal swrst_inv	: std_logic;
	
	-- Toggle entity sampling clock
	constant SAMPLE_CLK_DIVISOR	: integer := 1_500_000;
	signal sampleClk			: std_logic;
	
	-- Toggle entity outputs
	signal bufferedRaw		: std_logic;
	signal bufferedSynched	: std_logic;
	
	-- LED counter values (one nibble each)
	signal rawCount		: unsigned(3 downto 0)	:= "0000";
	signal synchedCount	: unsigned(3 downto 0)	:= "0000";
	
begin
	
	-- Disable flash memory
	fceb <= AL_OFF;
	
	-- Invert reset signal
	swrst_inv <= NOT swrst;
	
	-- Instantiate clock divider for synchronized toggle sampling clock
	SampleClkSource: CounterClockDivider
	generic map (MAX_DIVISOR => SAMPLE_CLK_DIVISOR)
	port map
	(
		-- Input from master 50MHz clock
		clkIn => clk50,
		
		-- Global reset
		reset => swrst_inv,
		
		-- Constant divisor
		divisor => SAMPLE_CLK_DIVISOR,
		
		-- Output to sampling clock
		clkOut => sampleClk
	);
	
	-- Instantiate toggle entity
	Toggle: ToggleD
	port map
	(
		-- Toggle input from push-button
		buttonRaw_AL => sw1,
		
		-- Clocked by sampling clock
		clk => sampleClk,
		
		-- Global reset
		reset => swrst_inv,
		
		-- Raw output
		bufferedRawOut => bufferedRaw,
		
		-- Filtered/synched output
		Q => bufferedSynched
	);
	
	-- Raw counter process
	process(bufferedRaw, swrst_inv)
	begin
		-- On reset, clear counter
		if (swrst_inv = AH_ON) then
			rawCount <= (others => '0');
		-- On rising edge, increment raw counter
		elsif rising_edge(bufferedRaw) then
			rawCount <= (rawCount + 1);
		end if;
	end process;
	
	-- Synchronized counter process
	process(bufferedSynched, swrst_inv)
	begin
		-- On reset, clear counter
		if (swrst_inv = AH_ON) then
			synchedCount <= (others => '0');
		-- On rising edge, increment synched counter
		elsif rising_edge(bufferedSynched) then
			synchedCount <= (synchedCount + 1);
		end if;
	end process;
	
	-- Output counter values on seven-segment LEDs
	ls <= NibbleToHexDigit(rawCount);
	rs <= NibbleToHexDigit(synchedCount);
	
end Behavioral;

