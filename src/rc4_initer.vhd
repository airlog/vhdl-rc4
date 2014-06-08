
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity rc4_initer is
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
end rc4_initer;

architecture Behavioral of rc4_initer is
	constant permlength : integer := 256;
begin
	process (clk)
		type rc4_initer_state is (IDLE, INIT, SHUFFLE);
		subtype rc4int is integer range 0 to 255;
		
		variable state : rc4_initer_state := IDLE;
		variable clk_ctr, ctr : integer := 0;
		variable i, j, si, sj, k, tmp : rc4int := 0;
		variable keylength : integer := 0;
	begin
		if rising_edge(clk) then
			keylength := conv_integer(unsigned(keylen));
			case state is
				when IDLE =>
					if go = '1' then
						clk_ctr := 0;
						ctr := 0;
						done <= '0';
						i := 0;
						j := 0;
						si := 0;
						sj := 0;
						state := INIT;
					else
						done <= '1';
						state := IDLE;
					end if;
				
				when INIT =>
					if ctr >= permlength then
						clk_ctr := 0;
						ctr := 0;
						state := SHUFFLE;
					else
						if clk_ctr mod 2 = 0 then
							-- nie rob nic (podtrzymaj ostatnia komende)
						else
							memctrl <= '1';
							memindex <= conv_std_logic_vector(ctr, width);
							memoutput <= conv_std_logic_vector(ctr, width);
							ctr := ctr + 1;
						end if;
						clk_ctr := clk_ctr + 1;
					end if;
				
				when SHUFFLE =>
					if i >= permlength then
						clk_ctr := 0;
						ctr := 0;
						i := 0;
						j := 0;
						si := 0;
						sj := 0;
						memctrl <= '0';
						done <= '1';
						state := IDLE;
					else
						case clk_ctr is
							when 0 =>
								si := 0;
								sj := 0;
								k := 0;
								memctrl <= '0';
								memindex <= conv_std_logic_vector(i, width);
								clk_ctr := clk_ctr + 1;
								state := SHUFFLE;
							
							when 1 =>
								clk_ctr := clk_ctr + 1;
								state := SHUFFLE;
							
							when 2 =>
								si := conv_integer(unsigned(meminput));
								tmp := i mod keylength;
								keyindex <= conv_std_logic_vector(tmp, width);
								clk_ctr := clk_ctr + 1;
								state := SHUFFLE;
							
							when 3 =>
								clk_ctr := clk_ctr + 1;
								state := SHUFFLE;
							
							when 4 =>
								k := conv_integer(unsigned(keyinput));
								j := (j + si + k) mod 256;
								memctrl <= '0';
								memindex <= conv_std_logic_vector(j, width);
								clk_ctr := clk_ctr + 1;
								state := SHUFFLE;
							
							when 5 =>
								clk_ctr := clk_ctr + 1;
								state := SHUFFLE;
							
							when 6 =>
								sj := conv_integer(unsigned(meminput));
								memoutput <= conv_std_logic_vector(si, width);
								memctrl <= '1';
								clk_ctr := clk_ctr + 1;
								state := SHUFFLE;
							
							when 7 =>
								memindex <= conv_std_logic_vector(i, width);
								memoutput <= conv_std_logic_vector(sj, width);
								memctrl <= '1';
								clk_ctr := 0;
								i := i + 1;
								state := SHUFFLE;

							when others =>
								memindex <= "11111111";
								memoutput <= "11111111";
								memctrl <= '0';
								state := SHUFFLE;
						end case;
					end if;
			end case;
		end if;
	end process;
end Behavioral;
