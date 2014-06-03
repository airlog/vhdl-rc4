
--
-- TODO: zapelnianie pamieci klucza, asercja
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
 
ENTITY rc4_key_loader_tb IS
END rc4_key_loader_tb;
 
ARCHITECTURE behavior OF rc4_key_loader_tb IS 
	component rc4_key_loader
		generic (
			width: integer := 8;
			key_width: integer := 8
		);
		port (
			input : IN  std_logic_vector((width - 1) downto 0);
			input_ctrl: in std_logic;
			input_stop : IN  std_logic;
			go : IN  std_logic;
			clk : IN  std_logic;
			key_ctrl : OUT  std_logic;
			key_index : OUT  std_logic_vector((key_width - 1) downto 0);
			key_output : OUT  std_logic_vector((width - 1) downto 0);
			key_len_ctrl : OUT  std_logic;
			key_len_output : OUT  std_logic_vector((key_width - 1) downto 0);
			rdy : OUT  std_logic
		);
	END COMPONENT;
	
	constant width : integer := 8;
	constant key_width : integer := 8;

	--Inputs
	signal input : std_logic_vector((width - 1) downto 0) := (others => '0');
	signal input_ctrl : std_logic;
	signal input_stop : std_logic := '0';
	signal go : std_logic := '0';
	signal clk : std_logic := '0';

	--Outputs
	signal key_ctrl : std_logic;
	signal key_index : std_logic_vector((width - 1) downto 0);
	signal key_output : std_logic_vector((width - 1) downto 0);
	signal key_len_ctrl : std_logic;
	signal key_len_output : std_logic_vector((width - 1) downto 0);
	signal rdy : std_logic;

	-- constants
	constant clk_period : time := 10 ns;
	constant keymemsize : integer := 2 ** width;
	constant realkeylen : integer := 8;

	-- types
	subtype rc4int is integer range 0 to (2 ** width) - 1;
	type rc4keymem is array (0 to keymemsize - 1) of rc4int;
	
	-- variables
	shared variable keymem : rc4keymem := (others => 0);
	shared variable keylen : integer := 0;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: rc4_key_loader
		generic map (
			width => width,
			key_width => key_width
		)
		port map (
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
 
	keymem_proc: process(key_ctrl, key_index, key_output)
	begin
		if key_ctrl = '1' then
			keymem(conv_integer(unsigned(key_index))) := conv_integer(unsigned(key_output));
		end if;
	end process;
	
	keylen_proc: process(key_len_ctrl, key_len_output)
	begin
		if key_len_ctrl = '1' then
			keylen := conv_integer(unsigned(key_len_output));
		end if;
	end process;
 
	-- Stimulus process
	stim_proc: process
		type key_array is array (0 to realkeylen - 1) of rc4int;
		
		variable key : key_array := (
				16#FA#, 16#EB#, 16#DC#, 16#00#,
				16#19#, 16#28#, 16#37#, 16#46#
			);
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;

		input_ctrl <= '0';
		go <= '1';
		
		-- poczekaj az urzadzenie bedzie gotowe
		while rdy = '0' loop
			wait for clk_period;
		end loop;

		-- wprowadzanie danych
		for i in 0 to realkeylen - 1 loop
			input_ctrl <= '1';
			input <= conv_std_logic_vector(key(i), key_width);
			wait for clk_period;
		end loop;
		go <= '0';
		input_stop <= '1';
		input_stop <= '0' after clk_period;

		-- poczekaj az urzadzenie ustawi wartosc klucza (zakonczy prace)
		while key_len_ctrl = '0' loop
			wait for clk_period;
		end loop;
		wait for clk_period;
		
		-- sprawdzenie dlugosci klucza
		assert (keylen = 8)
			report "Otrzymano zly rozmiar klucza!"
			severity failure;
		-- sprawdzenie pamieci klucza po zakonczeniu czytania
		for i in 0 to keymemsize - 1 loop
			if i >= keylen then
				assert (keymem(i) = 0)
					report "Klucz zosta³ zle wczytany!"
					severity failure;
			else
				assert (keymem(i) = key(i))
					report "Klucz zosta³ zle wczytany!"
					severity failure;
			end if;
		end loop;
		
		wait;
	end process;
END;
