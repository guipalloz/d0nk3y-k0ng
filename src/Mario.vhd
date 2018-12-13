----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:30:52 12/05/2018 
-- Design Name: 
-- Module Name:    Mario - Behavioral 
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

entity Mario is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           refresh : in  STD_LOGIC;
           RGBm : out  STD_LOGIC_VECTOR(7 downto 0);
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           left : in STD_LOGIC;
           right : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
			  sobrePlat: in STD_LOGIC);
end Mario;

architecture Behavioral of Mario is
signal p_posx, p_posy, posx, posy : unsigned(9 downto 0);
constant VELX : unsigned(4 downto 0):= to_unsigned(1,5);
constant ACEL : unsigned(4 downto 0):= to_unsigned(1,5);
signal vely,p_vely: unsigned(4 downto 0);
signal flag : STD_LOGIC;

type estado is (WAITING, POS_UPDATE, VEL_UPDATE);
signal state, p_state:estado;

constant MAX_VELY:unsigned(4 downto 0):=to_unsigned(25,5);

begin

sinc: process(clk,reset)
begin
	if(reset = '1') then
		posx <= to_unsigned(150,10);
		posy <= to_unsigned(10,10);
		vely <= (others => '0');
		flag <= '0';
		
		state <= WAITING;
		
	elsif(rising_edge(clk)) then
		posx <= p_posx;
		posy <= p_posy;
		vely <= p_vely;
		state <= p_state;
	end if;
end process;

repr: process(ejex,ejey, posx, posy)
	begin
	flag <= '0';
	--posx+15=unsigned(ejex) AND
	if( posy+31=unsigned(ejey))then
		RGBm<="11111100"; --Pinta el punto de amarillo !!!!!!!!!!!!!!!!!!!
		flag <= '1';
	elsif(posx>=unsigned(ejex) AND posx<unsigned(ejex)+32 AND posy>=unsigned(ejey) AND posy < unsigned(ejey)+32) then
		RGBm<="11100000"; --Pinta de rojo
	else
		RGBm<="00000000"; --Pinta de negro
	end if;

end process;


maquina_estado: process(refresh,posx, posy, vely, sobrePlat, state, left, right)
begin
	p_state<=state;
	p_posx<=posx;
	p_posy<=posy;
	p_vely<= vely;
	case state is
		when WAITING =>
			p_posx<=posx;
			p_posy<=posy;
			if (refresh ='1') then
				p_state<=POS_UPDATE;
			else
				p_state<=WAITING;
			end if;
			
		when POS_UPDATE =>
		-- �Habria que restarle 1 en caso de sobreplataform = 1??
			p_state<=VEL_UPDATE;
			if (left='1' and posx>VELX) then
				p_posx<=posx-VELX;
			elsif (right='1' and posx + 32 < to_unsigned(639,10)) then
				p_posx<=posx+VELX;
			else
				p_posx<=posx;
			end if;
			if(sobrePlat ='0') then
				p_posy <= posy + VELY;
			else
				p_posy <= posy-1; -- �-1?
			end if;
-- IDEA: Poner el punto amarillo un pixel debajo del recuadro para evitar que fluctue en torno a la plataforma
		when VEL_UPDATE =>
			if sobrePlat = '0' then
				
				if (vely<MAX_VELY) then
					p_vely<=vely+ACEL;
				else
					p_vely<=vely;
				end if;
			else 
				p_vely <= (others => '0');
			end if;
			p_state <= WAITING;
	end case;
end process;

end Behavioral;
