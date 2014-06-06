
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity reseter is
	generic (
		size: integer := 256;
		width: integer := 8;
		addrwidth: integer := 8;
		rstvalue : integer := 0
	);
	port (
		CLK: in std_logic;
		GO: in std_logic;
		CTRL: out std_logic;
		INDEX: out std_logic_vector((addrwidth - 1) downto 0);
		VALUE: out std_logic_vector((width - 1) downto 0);
		DONE: out std_logic
	);
end reseter;

architecture Behavioral of reseter is
	type reseter_state is (IDLE, WORKING);
begin
	process (clk)
		variable state : reseter_state := IDLE;
		variable clk_ctr : integer := 0;
		variable ctr : integer := 0;
	begin
		if rising_edge(clk) then
			case state is
				when IDLE =>
					if go = '1' then
						done <= '0';
						clk_ctr := 0;
						ctr := 0;
						state := WORKING;
					else
						ctrl <= '0';
						done <= '1';
					end if;
				
				when WORKING =>
					if ctr >= size then
						ctrl <= '0';
						done <= '1';
						state := IDLE;
					else
						ctrl <= '1';
						index <= conv_std_logic_vector(ctr, addrwidth);
						value <= conv_std_logic_vector(rstvalue, width);
						ctr := ctr + 1;
						state := WORKING;
					end if;
			end case;
		end if;
	end process;
end Behavioral;
