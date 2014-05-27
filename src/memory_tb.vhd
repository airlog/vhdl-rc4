LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY sblock_tb IS
END sblock_tb;
 
ARCHITECTURE behavior OF sblock_tb IS 
	-- Component Declaration for the Unit Under Test (UUT)
	component memory
		generic (
			width: integer := 8;	-- ilosc bitow adresów
			size: integer := 256	-- rozmiar pamieci w bajtach
		);
		port (
			SET: in STD_LOGIC;												-- tryb pracy
			CLK: in STD_LOGIC;												-- zegar
			INDEX: in STD_LOGIC_VECTOR ((width - 1) downto 0);		-- indeks elementu tablicy
			INVALUE: in STD_LOGIC_VECTOR ((width - 1) downto 0);	-- wartoœæ wejœciowa
			OUTVALUE: out STD_LOGIC_VECTOR ((width - 1) downto 0)	-- wartoœæ wyjœciowa
		);
	end component;
    
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
	uut: memory PORT MAP (
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
