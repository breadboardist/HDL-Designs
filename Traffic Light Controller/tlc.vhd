
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tlc is
	Port ( 	clk : in  STD_LOGIC;
			rst : in  STD_LOGIC;
			walk1, walk2 : in  STD_LOGIC;
			r1, r3, y1, y3, g1, g3, r2, r4, y2, y4, g2, g4 : out  STD_LOGIC;
			sign1, sign2 : out  STD_LOGIC);
end tlc;

architecture Behavioral of tlc is
	signal count:integer range 0 to 10 := 0;
	signal state:integer range 0 to 25 := 0;
	begin
		process(clk, rst)
		begin
			if(rst = '1') then
				state <= 0;
				r1 <= '0';
				r3 <= '0';
				y1 <= '0';
				y3 <= '0';
				g1 <= '0';
				g3 <= '0';
				r2 <= '0';
				r4 <= '0';
				y2 <= '0';
				y4 <= '0';
				g2 <= '0';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
				count <= 0;
	elsif (walk1='1') and (state <2) then
	state <= 12;
	elsif (walk1='1') and (state>10) then
	state <= 12;
	elsif (walk2='1') and (state <2) then
	state <= 12;
	elsif (walk2='1') and (state>10) then
	state <= 12;
	elsif clk'event and clk='1' then
	case state is
		when 0 =>  --Red Light
			if(count=2) then
				count <= 0;
				state <= 1;
				else
				count <= (count + 1);
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '0';
				y2 <= '1';
				g2 <= '0';
				r4 <= '1';
				y4 <= '0';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when 1 =>  --Green Light
			if(count=3) then
				count <= 0;
				state <= 2;
				else
				count <= count + 1;
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '0';
				y3 <= '0';
				g3 <= '1';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '1';
				y4 <= '0';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when 2 =>  --Yellow Light
			if(count=2) then
				count <= 0;
				state <= 3;
				else
				count <= count + 1;
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '0';
				y3 <= '0';
				g3 <= '1';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '0';
				y4 <= '0';
				g4 <= '1';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when 3 =>  --Yellow Light
			if(count=3) then
				count <= 0;
				state <= 4;
				else
				count <= count + 1;
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '0';
				y3 <= '1';
				g3 <= '0';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '0';
				y4 <= '0';
				g4 <= '1';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when 4 =>  --Yellow Light
			if(count=2) then
				count <= 0;
				state <= 5;
				else
				count <= count + 1;
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '0';
				y3 <= '1';
				g3 <= '0';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '0';
				y4 <= '1';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
		end if;

		when 5 =>  --Yellow Light
			if(count=2) then
				count <= 0;
				state <= 6;
				else
				count <= count + 1;
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '0';
				y4 <= '1';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when 6 =>  --Yellow Light
			if(count=1) then
				count <= 0;
				state <= 7;
				else
				count <= count + 1;
				r1 <= '0';
				y1 <= '0';
				g1 <= '1';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '0';
				y4 <= '1';
				g4 <= '0';
				sign1 <= '1';
				sign2 <= '0';
			end if;

		when 7 =>  --Yellow Light
			if(count=2) then
				count <= 0;
				state <= 8;
				else
				count <= count + 1;
				r1 <= '0';
				y1 <= '0';
				g1 <= '1';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '1';
				y4 <= '0';
				g4 <= '0';
				sign1 <= '1';
				sign2 <= '0';
			end if;

		when 8 =>  --Yellow Light
			if(count=3) then
				count <= 0;
				state <= 9;
				else
				count <= count + 1;
				r1 <= '0';
				y1 <= '0';
				g1 <= '1';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '0';
				y2 <= '0';
				g2 <= '1';
				r4 <= '1';
				y4 <= '0';
				g4 <= '0';
				sign1 <= '1';
				sign2 <= '1';
			end if;

		when 9 =>  --Yellow Light
			if(count=2) then
				count <= 0;
				state <= 10;
				else
				count <= count + 1;
				r1 <= '0';
				y1 <= '1';
				g1 <= '0';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '0';
				y2 <= '0';
				g2 <= '1';
				r4 <= '1';
				y4 <= '0';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '1';
			end if;

		when 10 =>  --Yellow Light
			if(count=1) then
				count <= 0;
				state <= 11;
				else
				count <= count + 1;
				r1 <= '0';
				y1 <= '1';
				g1 <= '0';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '0';
				y2 <= '1';
				g2 <= '0';
				r4 <= '1';
				y4 <= '0';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when 11 =>  --Yellow Light
			if(count=1) then
				count <= 0;
				state <= 0;
				else
				count <= count + 1;
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '1';
				y3 <= '0';
				g3 <= '0';
				r2 <= '0';
				y2 <= '1';
				g2 <= '0';
				r4 <= '1';
				y4 <= '0';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when 12 =>  --Yellow Light
			if(count=3) then
				count <= 0;
				state <= 4;
				else
				count <= count + 1;
				r1 <= '1';
				y1 <= '0';
				g1 <= '0';
				r3 <= '0';
				y3 <= '1';
				g3 <= '0';
				r2 <= '1';
				y2 <= '0';
				g2 <= '0';
				r4 <= '0';
				y4 <= '1';
				g4 <= '0';
				sign1 <= '0';
				sign2 <= '0';
			end if;

		when others =>
			state <= 0;
			count <= 0;
		end case;
	end if;
	end process;
end Behavioral;