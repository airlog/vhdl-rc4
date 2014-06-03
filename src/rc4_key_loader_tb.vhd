
--
-- TODO: zapelnianie pamieci klucza, asercja
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
 
ENTITY rc4_key_loader_tb IS
END rc4_key_loader_tb;
 
ARCHITECTURE behavior OF rc4_key_loader_tb IS 
	COMPONENT rc4_key_loader
		PORT(
			input : IN  std_logic_vector(7 downto 0);
			input_ctrl: in std_logic;
			input_stop : IN  std_logic;
			go : IN  std_logic;
			clk : IN  std_logic;
			key_ctrl : OUT  std_logic;
			key_index : OUT  std_logic_vector(7 downto 0);
			key_output : OUT  std_logic_vector(7 downto 0);
			key_len_ctrl : OUT  std_logic;
			key_len_output : OUT  std_logic_vector(7 downto 0);
			rdy : OUT  std_logic
		);
	END COMPONENT;    

	--Inputs
	signal input : std_logic_vector(7 downto 0) := (others => '0');
	signal input_ctrl : std_logic;
	signal input_stop : std_logic := '0';
	signal go : std_logic := '0';
	signal clk : std_logic := '0';

	--Outputs
	signal key_ctrl : std_logic;
	signal key_index : std_logic_vector(7 downto 0);
	signal key_output : std_logic_vector(7 downto 0);
	signal key_len_ctrl : std_logic;
	signal key_len_output : std_logic_vector(7 downto 0);
	signal rdy : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: rc4_key_loader
		PORT MAP (
			input => input,
			input_ctrl => input_ctrl,
			input_stop => input_stop,
			go => go,
			clk => clk,
			key_ctrl => key_ctrl,
			key_index => key_index,
			key_output => key_output,
			key_len_ctrl => key_len_ctrl,
			key_len_output => key_len_output,
			rdy => rdy
		);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
 
	-- Stimulus process
	stim_proc: process
		subtype rc4int is integer range 0 to 255;
		type key_array is array (0 to 7) of rc4int;
		
		variable key : key_array := (
				16#FA#, 16#EB#, 16#DC#, 16#00#,
				16#19#, 16#28#, 16#37#, 16#46#
			);
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;

		input_ctrl <= '0';
		go <= '1';
		while rdy = '0' loop
			wait for clk_period;
		end loop;
		for i in 0 to 7 loop
			input_ctrl <= '1';
			input <= conv_std_logic_vector(key(i), 8);
			wait for clk_period;
		end loop;
		go <= '0';
		input_stop <= '1';
		input_stop <= '0' after clk_period;

		wait;
	end process;
END;
