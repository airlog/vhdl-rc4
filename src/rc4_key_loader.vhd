--
--	rc4_key_loader
--		urz¹dzenie ³aduj¹ce kolejne bajty klucza do pamiêci
--
--	TODO: opis dzialania
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.ALL;

entity rc4_key_loader is
	generic (
		width: integer := 8;	-- ilosc bitow na wartosci
		key_width: integer := 8	-- ilosc bitow na dlugosc klucza
	);
	port (
		input: in std_logic_vector((width - 1) downto 0);		-- bajt do zaszyfrowania/deszyfrowania
		input_ctrl: in std_logic;								-- czytaj wartosc z wejscia
		input_stop: in std_logic;								-- koniec nadawania klucza
		go: in std_logic;										-- dzialac/nie dzialac
		clk: in std_logic;
		key_ctrl: out std_logic;								-- zapisz wartosc w pamieci
		key_index: out std_logic_vector((width - 1) downto 0);	-- indeks bajtu w pamieci
		key_output: out std_logic_vector((width - 1) downto 0);	-- perm_ctrl=1 => zapisz te wartosc
		key_len_ctrl: out std_logic;
		key_len_output: out std_logic_vector((key_width - 1) downto 0);
		rdy: out std_logic										-- gotowy do wczytywania klucza
	);
end rc4_key_loader;

architecture Behavioral of rc4_key_loader is
	type rc4_key_loader_state is (IDLE, ZERO_MEMORY, READING);

	constant key_length : integer := 2 ** key_width;
begin
	process (clk)
		variable clk_ctr : integer := 0;		
		variable i : integer := 0;
		variable state : rc4_key_loader_state := IDLE;
	begin
		if rising_edge(clk) then
			key_ctrl <= '0';
			key_len_ctrl <= '0';
			rdy <= '0';
			case state is
				when IDLE =>
					if go = '1' then
						clk_ctr := 0;
						i := 0;
						state := ZERO_MEMORY;
					end if;
			
				when ZERO_MEMORY =>
					if i >= key_length then
						clk_ctr := 0;
						i := 0;
						state := READING;
					else
						key_ctrl <= '1';
						key_index <= conv_std_logic_vector(i, width);
						key_output <= (others => '0');
						i := i + 1;
					
						clk_ctr := clk_ctr + 1;
						state := ZERO_MEMORY;
					end if;
			
				when READING =>
					if input_stop = '1' then
						key_len_ctrl <= '1';
						key_len_output <= conv_std_logic_vector(i, key_width);
						state := IDLE;
					else
						rdy <= '1';
						if i >= key_length then
							clk_ctr := 0;
							rdy <= '0';
						elsif input_ctrl = '1' then
							key_ctrl <= '1';
							key_index <= conv_std_logic_vector(i, width);
							key_output <= input;
							i := i + 1;
							state := READING;
						end if;
					end if;
						
				when others =>
			end case;
		end if;
	end process;
end Behavioral;
