
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;

ENTITY rc4_initer_tb IS
END rc4_initer_tb;

ARCHITECTURE behavior OF rc4_initer_tb IS
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT rc4_initer
		generic (
			width: integer := 8
		);
		port (
			CLK: in std_logic;
			GO: in std_logic;
			KEYLEN: in std_logic_vector((width - 1) downto 0);
			MEMINPUT: in std_logic_vector((width - 1) downto 0);
			KEYINPUT: in std_logic_vector((width - 1) downto 0);
			KEYINDEX: out std_logic_vector((width - 1) downto 0);
			MEMCTRL: out std_logic;
			MEMINDEX: out std_logic_vector((width - 1) downto 0);
			MEMOUTPUT: out std_logic_vector((width - 1) downto 0);
			DONE: out std_logic
		);
	END COMPONENT;

	-- Clock period definitions
	constant CLK_period : time := 10 ns;
	constant width : integer := 8;
	constant permemsize : integer := 256;
	constant keymemsize : integer := 2 ** width;
	constant realkeylen : integer := 8;
	
	-- Inputs
	signal CLK : std_logic := '0';
	signal GO : std_logic := '0';
	signal KEYLEN : std_logic_vector(7 downto 0) := (others => '0');
	signal MEMINPUT : std_logic_vector(7 downto 0) := (others => '0');
	signal KEYINPUT : std_logic_vector(7 downto 0) := (others => '0');

	-- Outputs
	signal KEYINDEX : std_logic_vector(7 downto 0);
	signal MEMCTRL : std_logic;
	signal MEMINDEX : std_logic_vector(7 downto 0);
	signal MEMOUTPUT : std_logic_vector(7 downto 0);
	signal DONE : std_logic;
	
	-- TB signals
	signal DEBUG_IND : std_logic_vector((width - 1) downto 0);
	signal DEBUG_VAL : std_logic_vector((width - 1) downto 0);
	
	subtype rc4int is integer range 0 to 255;
	type my_array is array (0 to (permemsize - 1)) of rc4int;
	type key_array is array (0 to realkeylen - 1) of rc4int;
 
	-- data
	shared variable key : my_array := (
			16#46#, 16#37#, 16#28#, 16#19#,
			16#00#, 16#DC#, 16#EB#, 16#FA#, 			
			others => 0
		);
	shared variable sarr : my_array := (others => 0);
	
	-- expected data
	shared variable sarr_expected : my_array := (
			185, 126, 115, 175, 200, 169, 108, 155,
			013, 041, 091, 189, 046, 116, 109, 163,
			120, 020, 078, 049, 012, 038, 213, 142,
			096, 094, 001, 178, 206, 067, 105, 148,
			156, 055, 158, 073, 081, 145, 009, 132,
			002, 050, 039, 172, 244, 243, 139, 166,
			040, 201, 063, 164, 165, 207, 170, 167,
			159, 118, 061, 010, 222, 247, 104, 089,
			223, 087, 193, 110, 099, 071, 031, 128,
			203, 135, 034, 015, 161, 174, 029, 225,
			019, 103, 080, 162, 056, 154, 058, 133,
			234, 209, 236, 023, 151, 051, 060, 232,
			090, 176, 113, 121, 230, 212, 251, 093,
			026, 245, 097, 003, 035, 191, 238, 199,
			249, 181, 188, 192, 205, 182, 027, 146,
			184, 195, 119, 028, 112, 235, 079, 048,
			086, 018, 171, 198, 007, 130, 043, 254,
			092, 076, 025, 147, 054, 150, 014, 123,
			030, 211, 084, 229, 037, 237, 000, 168,
			044, 157, 083, 246, 088, 137, 253, 064,
			075, 069, 017, 057, 047, 036, 059, 220,
			242, 006, 153, 129, 004, 052, 202, 042,
			085, 144, 106, 177, 190, 117, 187, 008,
			204, 070, 226, 194, 186, 127, 033, 138,
			136, 024, 100, 124, 180, 095, 173, 045,
			239, 072, 005, 219, 066, 149, 228, 179,
			210, 141, 143, 082, 208, 217, 215, 218,
			053, 125, 021, 131, 214, 231, 022, 250,
			074, 224, 252, 102, 107, 221, 077, 240,
			140, 068, 062, 248, 255, 233, 227, 122,
			114, 016, 065, 160, 111, 101, 196, 098,
			197, 032, 183, 152, 216, 241, 011, 134
		);
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: rc4_initer
		generic map (
			width => width
		)
		port map (
			CLK => CLK,
			GO => GO,
			KEYLEN => KEYLEN,
			MEMINPUT => MEMINPUT,
			KEYINPUT => KEYINPUT,
			KEYINDEX => KEYINDEX,
			MEMCTRL => MEMCTRL,
			MEMINDEX => MEMINDEX,
			MEMOUTPUT => MEMOUTPUT,
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

	-- key memory mock
	key_mem: process (clk)
		variable index : rc4int := 0;
	begin
		if rising_edge(clk) then		
			index := conv_integer(unsigned(keyindex));
			if index >= realkeylen then
				assert False
					report "Odczytano zbyt duza wartosc z pamieci klucza!"
					severity warning;
			end if;
			
			keyinput <= conv_std_logic_vector(key(index), width);
		end if;
	end process;
	
	-- permutation memory mock
	perm_mem: process (clk)
		variable index, value : rc4int := 0;
	begin
		if rising_edge(clk) then
			index := conv_integer(unsigned(memindex));
			if memctrl = '1' then
				value := conv_integer(unsigned(memoutput));
				sarr(index) := value;
--				assert False
--					report "value = " & integer'image(sarr(index))
--					severity info;
			else
				meminput <= conv_std_logic_vector(sarr(index), width);
			end if;
		end if;	
	end process;
	
	-- Stimulus process
	stim_proc: process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		keylen <= conv_std_logic_vector(realkeylen, width);
		go <= '1';
		wait for 2 * clk_period;
		
		-- czekaj na koniec dzialania
		go <= '0';
		while done = '0' loop
			wait for clk_period / 2;
		end loop;		
		
		keylen <= conv_std_logic_vector(0, width);
		assert done = '1'
			report "Praca jeszcze nie skonczona!"
			severity failure;
		for i in 0 to permemsize - 1 loop
			debug_ind <= conv_std_logic_vector(i, width);
			debug_val <= conv_std_logic_vector(sarr(i), width);
			wait for clk_period;
			assert sarr(i) = sarr_expected(i)
				report "Niepoprawna wartosc!"
				severity warning;
		end loop;
		
		wait;
	end process;
END;
