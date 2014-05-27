library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.ALL;

entity rc4_crypto is
	generic (
		width : integer := 8
	);
	port (
		input : in std_logic_vector((width - 1) downto 0);
		go	: in std_logic;
		clk : in std_logic;
		output : out std_logic_vector((width - 1) downto 0);
		rdy : out std_logic
	);
end rc4_crypto;

architecture Behavioral of rc4_crypto is
	component sblock
		generic (
			width: integer := 8	-- ilosc bitow adresów
		);
		port (
			SET: in STD_LOGIC;												-- tryb pracy
			CLK: in STD_LOGIC;												-- zegar
			INDEX: in STD_LOGIC_VECTOR ((width - 1) downto 0);		-- indeks elementu tablicy
			INVALUE: in STD_LOGIC_VECTOR ((width - 1) downto 0);	-- wartoœæ wejœciowa
			OUTVALUE: out STD_LOGIC_VECTOR ((width - 1) downto 0)	-- wartoœæ wyjœciowa
		);
	end component;
	
	signal block_set : std_logic := '0';
	signal block_index : std_logic_vector((width - 1) downto 0);
	signal block_inval : std_logic_vector((width - 1) downto 0);
	signal block_outval : std_logic_vector((width - 1) downto 0);
	
	type rc4_crypto_state is (
			WHILE_0_TEST, WHILE_GO_TEST, WHILE_GO_RET,
			MAIN_BODY, MAIN_BODY_SET_J, MAIN_BODY_SWAP_SI, MAIN_BODY_SWAP_SJ,
			MAIN_BODY_PREPARE_OUTPUT, MAIN_BODY_OUTPUT,
			WHILE_0_RET
		);
	subtype rc4int is integer range 0 to 255;
	type rc4_array is array (0 to 255) of rc4int;
	
	shared variable cstate : rc4_crypto_state := WHILE_0_TEST;
	shared variable i, j, tmp, si, sj, sm : rc4int := 0;
begin
	sblk : sblock
		generic map(width => width)
		port map(block_set, clk, block_index, block_inval, block_outval);

	process (clk)
	begin
		if rising_edge(clk) then
			rdy <= '0';
			case cstate is
				when WHILE_0_TEST =>
					cstate := WHILE_GO_TEST;
				
				when WHILE_GO_TEST =>
					if go = '1' then
						cstate := MAIN_BODY;
					else
						cstate := WHILE_GO_RET;
					end if;
					
				when WHILE_GO_RET =>
					cstate := WHILE_GO_TEST;
				
				when MAIN_BODY =>
					i := i + 1;
					block_index <= conv_std_logic_vector(i, width);
					si := conv_integer(unsigned(block_outval));
					cstate := MAIN_BODY_SET_J;
				
				when MAIN_BODY_SET_J =>
					j := j + si;
					block_index <= conv_std_logic_vector(j, width);
					sj := conv_integer(unsigned(block_outval));
					cstate := MAIN_BODY_SWAP_SI;

				when MAIN_BODY_SWAP_SI =>
					block_index <= conv_std_logic_vector(i, width);
					block_inval <= conv_std_logic_vector(sj, width);
					block_set <= '1';
					cstate := MAIN_BODY_SWAP_SJ;
				
				when MAIN_BODY_SWAP_SJ =>
					block_set <= '0';
					block_index <= conv_std_logic_vector(j, width);
					block_inval <= conv_std_logic_vector(si, width);
					block_set <= '1';
					cstate := MAIN_BODY_PREPARE_OUTPUT;

				when MAIN_BODY_PREPARE_OUTPUT =>
					tmp := (si + sj) mod 256;
					block_set <= '0';
					block_index <= conv_std_logic_vector(tmp, width);
					sm := conv_integer(unsigned(block_outval));
					cstate := MAIN_BODY_OUTPUT;
					
				when MAIN_BODY_OUTPUT =>
					output <= input xor conv_std_logic_vector(sm, width);
					rdy <= '1';
					cstate := WHILE_0_RET;

				when WHILE_0_RET =>
					cstate := WHILE_0_TEST;

				when others =>
					output <= "11111111";

			end case;
		end if;
	end process;
end Behavioral;

