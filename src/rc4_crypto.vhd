library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.ALL;

entity rc4_crypto is
	generic (
		width: integer := 8
	);
	port (
		enc_input: in std_logic_vector((width - 1) downto 0);	-- bajt do zaszyfrowania/deszyfrowania
		perm_input: in std_logic_vector((width - 1) downto 0);	-- wejscie wartosci z pamieci
		go: in std_logic;										-- dzialac/nie dzialac
		clk: in std_logic;
		enc_output: out std_logic_vector((width - 1) downto 0);	-- zaszyfrowany/deszyfrowany bajt
		perm_ctrl: out std_logic;								-- zapis/odczyt z pamieci
		perm_index: out std_logic_vector((width - 1) downto 0);	-- indeks bajtu w pamieci
		perm_output: out std_logic_vector((width - 1) downto 0);-- perm_ctrl=1 => zapisz te wartosc
		rdy: out std_logic										-- wartosc na enc_output jest poprawna
	);
end rc4_crypto;

architecture Behavioral of rc4_crypto is
	type rc4_crypto_state is (
			WHILE_GO_TEST, WHILE_GO_RET,
			MAIN_BODY, MAIN_BODY_SET_J, MAIN_BODY_SWAP_SI, MAIN_BODY_SWAP_SJ,
			MAIN_BODY_PREPARE_OUTPUT, MAIN_BODY_OUTPUT,
			WHILE_0_RET
		);
	subtype rc4int is integer range 0 to 255;
	
	shared variable cstate : rc4_crypto_state := WHILE_GO_TEST;
	shared variable i, j, tmp, si, sj, sm : rc4int := 0;
begin
	process (clk)
		variable clk_ctr : integer := 0;
	begin
		if rising_edge(clk) then
			rdy <= '0';
			perm_ctrl <= '0';
			case cstate is
				when WHILE_GO_TEST =>
					if go = '1' then
						enc_output <= "11000000";
						cstate := MAIN_BODY;
					else
						enc_output <= "00000000";
					end if;
					
				when WHILE_GO_RET =>
					cstate := WHILE_GO_TEST;
				
				when MAIN_BODY =>
					i := i + 1;
					perm_index <= conv_std_logic_vector(i, width);
					si := conv_integer(unsigned(perm_input));
					cstate := MAIN_BODY_SET_J;
				
				when MAIN_BODY_SET_J =>
					j := j + si;
					perm_index <= conv_std_logic_vector(j, width);
					sj := conv_integer(unsigned(perm_input));
					cstate := MAIN_BODY_SWAP_SI;

				when MAIN_BODY_SWAP_SI =>
					perm_ctrl <= '0';
					perm_index <= conv_std_logic_vector(i, width);
					perm_output <= conv_std_logic_vector(sj, width);
					perm_ctrl <= '1';
					cstate := MAIN_BODY_SWAP_SJ;
				
				when MAIN_BODY_SWAP_SJ =>
					perm_ctrl <= '0';
					perm_index <= conv_std_logic_vector(j, width);
					perm_output <= conv_std_logic_vector(si, width);
					perm_ctrl <= '1';
					cstate := MAIN_BODY_PREPARE_OUTPUT;

				when MAIN_BODY_PREPARE_OUTPUT =>
					perm_ctrl <= '0';
					tmp := (si + sj) mod 256;
					perm_index <= conv_std_logic_vector(tmp, width);
					sm := conv_integer(unsigned(perm_input));
					cstate := MAIN_BODY_OUTPUT;
					
				when MAIN_BODY_OUTPUT =>
					enc_output <= enc_input xor conv_std_logic_vector(sm, width);
					rdy <= '1';
					cstate := WHILE_0_RET;

				when WHILE_0_RET =>
					cstate := WHILE_GO_TEST;

				when others =>
					enc_output <= "11111111";

			end case;
		end if;
	end process;
end Behavioral;
