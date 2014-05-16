--
--	kod �r�d�owy urz�dzenia trzymaj�cego stan permutacji RC4
--		zasada dzia�ania:
--			Jakiekolwiek operacje s� wykonywane co takt zegara (rising_edge).			
--
--			W normalnym trybie (SET = 0) zwraca warto�� INDEX-tej kom�rki tablicy zawieraj�cej
--			permutacj� na sygna� OUTVALUE.
--
--			W trybie zapisywania (SET = 1) ustawia warto�� INDEX-tej kom�rki tablicy zawieraj�cej
--			permutacj� na warto�� w sygnale INVALUE.
--
--	uwagi:
--		-	nie zaimplementowano resetowania bo nie wiadomo dlaczego generowa� zbyt du�y schemat RTL;
--			inne urz�dzenie korzystaj�ce z tego b�dzie mog�o odpowiednio resetowa� ten stan
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity sblock is
	generic (
		width: integer := 8	-- ilosc bitow adres�w
	);
	port (
		SET: in STD_LOGIC;												-- tryb pracy
		CLK: in STD_LOGIC;												-- zegar
		INDEX: in STD_LOGIC_VECTOR ((width - 1) downto 0);		-- indeks elementu tablicy
		INVALUE: in STD_LOGIC_VECTOR ((width - 1) downto 0);	-- warto�� wej�ciowa
		OUTVALUE: out STD_LOGIC_VECTOR ((width - 1) downto 0)	-- warto�� wyj�ciowa
	);
end sblock;

architecture Behavioral of sblock is
	type rc4_state_array is array (0 to 255) of std_logic_vector((width - 1) downto 0);
	
	shared variable state_array : rc4_state_array := (others => (others => '0'));
begin
	process (clk, index)
		variable arrindex : integer range 0 to 255 := 0;
	begin
		if rising_edge(clk) then
			arrindex := conv_integer(unsigned(index));	-- odczytaj numer ��danej kom�rki pami�ci
			case set is 
				when '0' =>		-- tryb odczytu
					outvalue <= state_array(arrindex);
				when '1' =>		-- tryb zapisu
					state_array(arrindex) := invalue;
				when others =>	-- w innych przypadkach (wymagane przez vhdl)
					outvalue <= (others => '0');
			end case;
		end if;
	end process;
end Behavioral;
