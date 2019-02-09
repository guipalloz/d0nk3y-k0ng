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
			  sobrePlatM: in STD_LOGIC;
			  resets : in STD_LOGIC;
			  sobreEsc : in STD_LOGIC);
end Mario;

architecture Behavioral of Mario is
signal p_posx, p_posy, posx, posy, ejex_aux,ejey_aux : unsigned(9 downto 0);

signal vely,p_vely: unsigned(4 downto 0);
signal p_goingUp, goingUp, jumping, p_jumping : STD_LOGIC;

--Señales para la memoria
signal s_addr: STD_LOGIC_VECTOR(10 downto 0);
signal s_data : STD_LOGIC_VECTOR(2 downto 0);

type estado is (WAITING, POS_UPDATE, VEL_UPDATE);
signal state, p_state:estado;

constant VELX : unsigned(4 downto 0):= to_unsigned(3,5);
constant ACEL : unsigned(4 downto 0):= to_unsigned(1,5);
constant MAX_VELY:unsigned(4 downto 0):=to_unsigned(25,5);
constant VELY_SALTO:unsigned(4 downto 0):=to_unsigned(10,5);

COMPONENT marioROM
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;

begin
memoriaMario : marioROM
  PORT MAP (
    clka => clk,
    addra => s_addr,
    douta => s_data
  );
  
sinc: process(clk,reset,resets)
begin
	if(reset = '1') then
		posx <= to_unsigned(50,10);
		posy <= to_unsigned(395,10);
		vely <= (others => '0');
		state <= WAITING;
		jumping <= '0';
		goingUp <= '0';
		
	elsif(rising_edge(clk)) then
		posx <= p_posx;
		posy <= p_posy;
		vely <= p_vely;
		state <= p_state;
		jumping <= p_jumping;
		goingUp <= p_goingUp;
	end if;
end process;

comb: process(ejex,ejey, posx, posy, ejex_aux, ejey_aux, s_data, s_addr, up, down, left)
begin
	--reverse <= s_addr(9 downto 0);
	if (up = '1' or down = '1') then
		s_addr(10)<='1';
		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
		s_addr(4 downto 0) <= std_logic_vector(ejex_aux(4 downto 0));
	elsif (left = '1') then
		s_addr(10)<='0';
		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
		s_addr(4 downto 0) <= std_logic_vector(32-ejex_aux(4 downto 0));
	else
		s_addr(10)<='0';
		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
		s_addr(4 downto 0) <= std_logic_vector(ejex_aux(4 downto 0));
	end if;
	ejex_aux <= unsigned(ejex)-posx;
	ejey_aux <= unsigned(ejey)-posy;
--	if (up = '1' or down = '1') then
--		s_addr(10)<='1';
--		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
--		s_addr(4 downto 0) <= std_logic_vector(ejex_aux(4 downto 0));
--	else
--		s_addr(10) <= '0';
--		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
--		s_addr(4 downto 0) <= std_logic_vector(ejex_aux(4 downto 0));
--	end if;
--	ejex_aux <= unsigned(ejex)-posx;
--	ejey_aux <= unsigned(ejey)-posy;
	
	if((unsigned(ejex) >= posx) AND (unsigned(ejex) < (posx + 32)) AND (unsigned(ejey) >= posy) AND (unsigned(ejey) < posy + 32)) then
		-- Estoy dentro del Mario
		RGBm<= s_data(2) & s_data(2) & s_data(2) & s_data(1) & s_data(1) & s_data(1) & s_data(0) & s_data(0);
	else
		RGBm<="00000000"; --Pinta de negro
	end if;
	
	if((unsigned(ejex) = posx +16) AND (unsigned(ejey) = (posy + 31))) then
		RGBm<="11100001"; --Pintamos un único punto amarillo en el medio del cuadrado
	end if;
	
end process;


maquina_estado: process(refresh,posx, posy, vely, state, left, right, sobrePlatM, jump, jumping, goingUp, resets, sobreEsc, up, down)
begin
	if (resets = '1') then
		p_posx <= to_unsigned(50,10);
		p_posy <= to_unsigned(395,10);
		p_vely <= (others => '0');
		p_state <= WAITING;
		p_jumping <= '0';
		p_goingUp <= '0';
	else
		p_state<=state;
		p_posx<=posx;
		p_posy<=posy;
		p_vely<= vely;
		p_jumping<=jumping;
		p_goingUp <= goingUp;
		case state is
			when WAITING =>
				if (refresh ='1') then
					p_state<=POS_UPDATE;
				else
					p_state<=WAITING;
				end if;
				
				-- Cuando estoy saltando no puedo volver a saltar
				if (jump = '1') AND (jumping = '0') then
					p_goingUp <= '1';
					p_vely <= VELY_SALTO;
					p_jumping <= '1';
				end if;
				
				
			when POS_UPDATE =>
				p_state<=VEL_UPDATE;
				
				-- Control de posición horizontal
				if (left='1' and posx>VELX) then -- Restricción de no salirme de la pantalla
					p_posx<=posx-VELX;
				elsif (right='1' and posx + 32 < to_unsigned(639,10)) then -- Misma restricción en el otro lado de la pantalla
					p_posx<=posx+VELX;
				else
					p_posx<=posx;
				end if;
				
				-- Control de posición vertical
				if(sobreEsc='1' and jumping = '0') then
					if (up ='1') then
						p_posy <= posy-1; -- Sube con velocidad 1
					elsif(down='1') then
						p_posy <= posy+1;
					else
						p_posy <= posy;
					end if;
				elsif(goingUp='0')then
					if(sobrePlatM ='0') then
						p_posy <= posy + vely;
					else
						p_posy <= posy-1; -- Me salgo de la plataforma
						p_jumping<='0';
					end if;
				else
					if(posy>vely)then 
						p_posy<=posy-vely; -- Si no me salgo de la pantalla, actualizo gravedad
					else
						p_posy<=posy; -- Si me salgo de la pantalla, hay tope
					end if;
				end if;
				
			when VEL_UPDATE =>
				p_state <= WAITING;
					if (sobreEsc = '1' and (up = '1' or down ='1')) then
						p_vely <= (others => '0');
					else
						if goingUp = '0' then
							if sobrePlatM = '0' then
								if (vely<MAX_VELY) then
									p_vely<=vely+ACEL;
								else
									p_vely<=vely;
								end if;
							else 
								p_vely <= (others => '0');
							end if;	
						else
							if vely > ACEL then -- 
								p_vely <= vely - ACEL;
							else
								-- He terminado de subir, empiezo a caer
								p_vely <= (others => '0');
								p_goingUp <= '0';
							end if;
						end if;
					end if;
		end case;
	end if;
end process;

end Behavioral;

