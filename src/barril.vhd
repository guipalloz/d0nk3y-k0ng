----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:41:07 12/19/2018 
-- Design Name: 
-- Module Name:    barril - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity barril is
    Port ( ejex : in  STD_LOGIC;
           ejey : in  STD_LOGIC;
           sobrePlat_barril : in  STD_LOGIC;
           aparece : in  STD_LOGIC;
           RGBb : out  STD_LOGIC_VECTOR(7 downto 0);
end barril;

architecture Behavioral of barril is
signal p_posx, p_posy, posx, posy : unsigned(9 downto 0);
constant VELX : unsigned(4 downto 0):= to_unsigned(5,5);
constant ACEL : unsigned(4 downto 0):= to_unsigned(1,5);
signal vely,p_vely: unsigned(4 downto 0);
signal p_sentido, sentido: STD_LOGIC; --Si 0, se mueve a la izq, si 1 a derecha

type estado is (WAITING, FALLING, POS_UPDATE, VEL_UPDATE);
signal state, p_state:estado;

constant MAX_VELY:unsigned(4 downto 0):=to_unsigned(25,5);

begin

sinc: process(clk,reset)
begin
	if(reset = '1') then
		posx <= to_unsigned(1008,10);
		posy <= to_unsigned(0,10);
		vely <= (others => '0');
		state <= WAITING;
		sentido<='1';
	elsif(rising_edge(clk)) then
		posx <= p_posx;
		posy <= p_posy;
		vely <= p_vely;
		state <= p_state;
		p_sentido <= sentido;
	end if;
end process;

repr: process(ejex,ejey, posx, posy)
	begin
	if((unsigned(ejex) >= posx) AND (unsigned(ejex) < (posx + 16)) AND (unsigned(ejey) >= posy) AND (unsigned(ejey) < posy + 16)) then
		RGBm<="10101100"; --Pinta de marron
	else
		RGBm<="00000000"; --Pinta de negro
	end if;
	
	if((unsigned(ejex) = posx + 8) AND (unsigned(ejey) = (posy + 15))) then
		RGBm<="10101101"; --Pintamos un único punto de señal en el medio del cuadrado
	end if;
end process;


maquina_estado: process(refresh,posx, posy, vely, state, sentido, aparece, sobrePlat_barril)
begin
	p_state<=state;
	p_posx<=posx;
	p_posy<=posy;
	p_vely<= vely;
	p_sentido<=sentido;
	case state is
		when WAITING =>
			if aparece='1' then
				p_state <= FALLING;
				p_posx <= to_unsigned(0,10);
				p_posy <= to_unsigned(0,10);
				p_sentido  <= '1';
			else
				p_state <= WAITING;
			end if;
		when FALLING =>
			if (refresh ='1') then
				p_state<=POS_UPDATE;
			else
				p_state<=WAITING;
			end if;
			
		when POS_UPDATE =>
			p_state<=VEL_UPDATE;
			if (sentido ='0') then
				if (posx < VELX) then
					p_posx<=posx+VELX;
					p_sentido <= '1';
				else
					p_posx<=posx-VELX;
				end if;
			else
				if (posx + 16 > to_unsigned(639,10)) then
					p_posx <= posx-VELX;
					p_sentido <= '0';
				else
					p_posx <= posx+VELX;
				end if;
			end if;			
			
			if(sobrePlat_barril ='0') then
				p_posy <= posy + vely;
			else
				p_posy <= posy-1; -- Me salgo de la plataforma
			end if;
			
		when VEL_UPDATE =>
			p_state <= FALLING;
			if sobrePlat_barril = '0' then
				if (vely<MAX_VELY) then
					p_vely<=vely+ACEL;
				else
					p_vely<=vely;
				end if;
			else 
				p_vely <= (others => '0');
			end if;
	end case;
end process;

end Behavioral;
