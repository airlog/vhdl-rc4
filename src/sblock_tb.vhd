LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY sblock_tb IS
END sblock_tb;
 
ARCHITECTURE behavior OF sblock_tb IS 
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT sblock
		port (
			SET: in STD_LOGIC;
			CLK: in STD_LOGIC;
			INDEX: in STD_LOGIC_VECTOR (7 downto 0);
			INVALUE: in STD_LOGIC_VECTOR (7 downto 0);
			OUTVALUE: out STD_LOGIC_VECTOR (7 downto 0)
		);
	END COMPONENT;
    
	--Inputs
	signal SET : std_logic := '0';
	signal CLK : std_logic := '0';
	signal RST : std_logic := '0';
	signal INDEX : std_logic_vector(7 downto 0) := (others => '0');
	signal INVALUE : std_logic_vector(7 downto 0) := (others => '0');

	--Outputs
	signal OUTVALUE : std_logic_vector(7 downto 0);

	-- Clock period definitions
	constant CLK_period : time := 10 ns;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: sblock PORT MAP (
		SET => SET,
		CLK => CLK,
		RST => RST,
		INDEX => INDEX,
		INVALUE => INVALUE,
		OUTVALUE => OUTVALUE
	);

	-- Clock process definitions
	CLK_process : process
	begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
	end process;
 
	-- Stimulus process
	stim_proc : process
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;	

		-- ustawianie wartoœci tablicy
		set <= '1';
		for i in 0 to 255 loop
			index <= conv_std_logic_vector(i, 8);
			invalue <= conv_std_logic_vector(i, 8);
			wait for clk_period;
		end loop;
		invalue <= (others => '0');
		
		-- odczytywanie wartoœci tablicy
		set <= '0';
		for i in 0 to 255 loop
			index <= conv_std_logic_vector(i, 8);
			wait for clk_period;
			assert (outvalue = conv_std_logic_vector(i, 8))
				report "Oczekiwana inna wartosc"
				severity failure;
		end loop;
		
      wait;
   end process;
END;
