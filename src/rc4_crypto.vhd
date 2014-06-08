--
--	rc4_crypto
--		urz¹dzenie szyfruj¹co/deszyfruj¹ce strumieñ bajtów przy pomocy RC4
--	
--	Urz¹dzenie nie posiada swojej pamiêci na aktualny stan permutacji RC4, posiada natomiast
--	zestaw wejœæ i wyjœæ umo¿liwiaj¹cych kontakt z zewnêtrzn¹ pamiêci¹.
--
--	Urz¹dzenie rozpoczyna dzia³anie wtedy i tylko wtedy gdy wartoœæ sygna³u go = 1. Powoduje to zaszyfrowanie
--	dok³adnie jednego bajtu z wejœcia. Bajt na wejœciu powinien byæ trzymany tak d³ugo a¿ sygna³ rdy = 1. Oznacza
--	to, ¿e bajt na wyjœciu jest poprawnie zaszyfrowany/odszyfrowany.
--

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
			MAIN_BODY, MAIN_BODY_OUTPUT,
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
						cstate := MAIN_BODY;
					end if;
					
				when WHILE_GO_RET =>
					cstate := WHILE_GO_TEST;
				
				when MAIN_BODY =>
					case clk_ctr is
						when 0 =>
							clk_ctr := 0;
							i := i + 1;
							perm_index <= conv_std_logic_vector(i, width);
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						-- utrzymaj stan sygna³u perm_index ¿eby otrzymaæ poprawn¹ wartoœæ
						when 1 =>
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						when 2 =>
							si := conv_integer(unsigned(perm_input));
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						when 3 =>
							j := j + si;
							perm_index <= conv_std_logic_vector(j, width);
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						-- utrzymaj stan sygna³u perm_index ¿eby otrzymaæ poprawn¹ wartoœæ
						when 4 =>
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						when 5 =>
							sj := conv_integer(unsigned(perm_input));
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						when 6 =>
							perm_ctrl <= '0';
							perm_index <= conv_std_logic_vector(i, width);
							perm_output <= conv_std_logic_vector(sj, width);
							perm_ctrl <= '1';
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
							
						when 7 =>
							perm_ctrl <= '0';
							perm_index <= conv_std_logic_vector(j, width);
							perm_output <= conv_std_logic_vector(si, width);
							perm_ctrl <= '1';
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
							
						when 8 =>
							perm_ctrl <= '0';
							tmp := (si + sj) mod 256;
							perm_index <= conv_std_logic_vector(tmp, width);
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						-- utrzymaj stan sygna³u perm_index ¿eby otrzymaæ poprawn¹ wartoœæ
						when 9 =>
							clk_ctr := clk_ctr + 1;
							cstate := MAIN_BODY;
						
						when 10 =>
							sm := conv_integer(unsigned(perm_input));
							clk_ctr := 0;
							cstate := MAIN_BODY_OUTPUT;
							
						when others =>
					end case;					
				
				when MAIN_BODY_OUTPUT =>
					enc_output <= enc_input xor conv_std_logic_vector(sm, width);
					rdy <= '1';
					cstate := WHILE_0_RET;

				when WHILE_0_RET =>
					cstate := WHILE_GO_TEST;

			end case;
		end if;
	end process;
end Behavioral;
