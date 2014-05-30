LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

ENTITY rc4_crypto_tb IS
END rc4_crypto_tb;
 
ARCHITECTURE behavior OF rc4_crypto_tb IS 
    -- Component Declaration for the Unit Under Test (UUT) 
    COMPONENT rc4_crypto
    PORT(
         enc_input : IN  std_logic_vector(7 downto 0);
         perm_input : IN  std_logic_vector(7 downto 0);
         go : IN  std_logic;
         clk : IN  std_logic;
         enc_output : OUT  std_logic_vector(7 downto 0);
         perm_ctrl : OUT  std_logic;
         perm_index : OUT  std_logic_vector(7 downto 0);
         perm_output : OUT  std_logic_vector(7 downto 0);
         rdy : OUT  std_logic
        );
    END COMPONENT;
    
    --Inputs
    signal enc_input : std_logic_vector(7 downto 0) := (others => '0');
    signal perm_input : std_logic_vector(7 downto 0) := (others => '0');
    signal go : std_logic := '0';
    signal clk : std_logic := '0';

  	--Outputs
    signal enc_output : std_logic_vector(7 downto 0);
    signal perm_ctrl : std_logic;
    signal perm_index : std_logic_vector(7 downto 0);
    signal perm_output : std_logic_vector(7 downto 0);
    signal rdy : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;
	
	subtype rc4int is integer range 0 to 255;
	type my_array is array (0 to 255) of rc4int;
 
	shared variable sarr : my_array := (
				000, 185, 126, 115, 175, 200, 169, 108,
				008, 013, 041, 091, 189, 046, 116, 109,
				016, 120, 020, 078, 049, 012, 038, 213,
				024, 096, 094, 001, 178, 206, 067, 105,
				032, 156, 055, 158, 073, 081, 145, 009,
				040, 002, 050, 039, 172, 244, 243, 139,
				048, 040, 201, 063, 164, 165, 207, 170,
				056, 159, 118, 061, 010, 222, 247, 104,
				064, 223, 087, 193, 110, 099, 071, 031,
				072, 203, 135, 034, 015, 161, 174, 029,
				080, 019, 103, 080, 162, 056, 154, 058,
				088, 234, 209, 236, 023, 151, 051, 060,
				096, 090, 176, 113, 121, 230, 212, 251,
				104, 026, 245, 097, 003, 035, 191, 238,
				112, 249, 181, 188, 192, 205, 182, 027,
				120, 184, 195, 119, 028, 112, 235, 079,
				128, 086, 018, 171, 198, 007, 130, 043,
				136, 092, 076, 025, 147, 054, 150, 014,
				144, 030, 211, 084, 229, 037, 237, 000,
				152, 044, 157, 083, 246, 088, 137, 253,
				160, 075, 069, 017, 057, 047, 036, 059,
				168, 242, 006, 153, 129, 004, 052, 202,
				176, 085, 144, 106, 177, 190, 117, 187,
				184, 204, 070, 226, 194, 186, 127, 033,
				192, 136, 024, 100, 124, 180, 095, 173,
				200, 239, 072, 005, 219, 066, 149, 228,
				208, 210, 141, 143, 082, 208, 217, 215,
				216, 053, 125, 021, 131, 214, 231, 022,
				224, 074, 224, 252, 102, 107, 221, 077,
				232, 140, 068, 062, 248, 255, 233, 227,
				240, 114, 016, 065, 160, 111, 101, 196,
				248, 197, 032, 183, 152, 216, 241, 011);
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: rc4_crypto PORT MAP (
		enc_input => enc_input,
        perm_input => perm_input,
        go => go,
		clk => clk,
        enc_output => enc_output,
        perm_ctrl => perm_ctrl,
        perm_index => perm_index,
        perm_output => perm_output,
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
	
	array_proc: process(clk, perm_ctrl, perm_index, perm_output)
	begin
		if rising_edge(clk) then
			if perm_ctrl = '1' then
				sarr(conv_integer(unsigned(perm_index))) := conv_integer(unsigned(perm_output));
			else
				perm_input <= conv_std_logic_vector(sarr(conv_integer(unsigned(perm_index))), 8);
			end if;
		end if;
	end process;
 
   -- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;	

		go <= '1';

		wait;
	end process;
END;
