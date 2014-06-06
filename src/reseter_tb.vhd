
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;

ENTITY reseter_tb IS
END reseter_tb;

ARCHITECTURE behavior OF reseter_tb IS
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT reseter
		generic (
			size: integer := 256;
			width: integer := 8;
			addrwidth: integer := 8;
			rstvalue : integer := 0
		);
		PORT(
			CLK: in std_logic;
			GO: in std_logic;
			CTRL: out std_logic;
			INDEX: out std_logic_vector((addrwidth - 1) downto 0);
			VALUE: out std_logic_vector((width - 1) downto 0);
			DONE: out std_logic
		);
	END COMPONENT;

	-- Inputs
	signal CLK : std_logic := '0';
	signal GO : std_logic := '0';

	-- Outputs
	signal CTRL : std_logic := '0';
	signal INDEX : std_logic_vector(7 downto 0);
	signal VALUE : std_logic_vector(7 downto 0);
	signal DONE : std_logic;
	
	-- Constants
	constant CLK_period : time := 10 ns;
	constant width : integer := 8;
	constant mem_size : integer := 16;
	
	-- Types
	subtype int8 is integer range 0 to (2 ** width - 1);
	type int8_array is array (0 to mem_size - 1) of int8;
	
	-- Variables
	shared variable memory : int8_array := (
			1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
		);
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: reseter
		generic map(
			size => mem_size,
			width => width
		)
		port map(
			CLK => CLK,
			GO => GO,
			CTRL => CTRL,
			INDEX => INDEX,
			VALUE => VALUE,
			DONE => DONE
		);

	-- Clock process definitions
	CLK_process: process
	begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
	end process;

	mem_writer: process (clk, ctrl, index, value)
	begin
		if rising_edge(clk) then
			if ctrl = '1' then
				memory(conv_integer(unsigned(index))) := conv_integer(unsigned(value));
			else
			end if;
		end if;
	end process;
	
	-- Stimulus process
	stim_proc: process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
	
		for i in 0 to (mem_size - 1) loop
			assert memory(i) /= 0
				report "Zly stan poczatkowy pamieci!"
				severity warning;
		end loop;
		wait for clk_period;
		
		go <= '1';
		wait for 2 * clk_period;
		go <= '0';
		while done = '0' loop
			wait for clk_period/2;
		end loop;
		
		wait for 5 * clk_period;
		assert done = '1'
			report "Dzialanie urzadzenia powinno juz sie zakonczyc!"
			severity failure;
		for i in 0 to (mem_size - 1) loop
			assert memory(i) = 0
				report "Zly stan koncowy pamieci!"
				severity failure;
		end loop;

		wait;
	end process;
END;
