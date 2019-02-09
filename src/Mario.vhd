--------------------------------------------------------------------
--	Trabajo Donkey Kong - Complementos de Electr�nica	 				--
--	M�ster Universitario en Ingenier�a de Telecomunicaci�n 		 	--
--	Universidad de Sevilla, Curso 2018/2019			 					--	
--								 														--	
--	Autores:						 													--
--																						--
--		- Jos� Manuel Gata Romero  			 								--
--		- Ildefonso Jim�nez Silva			 									--
--		- Guillermo Palomino Lozano			 								--
--								 														--
--------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Componente Mario encargado tanto del movimiento como de la representaci�n del Mario. 
-- Recibe como entrada cada uno de los botones disponibles en el juego, las coordenadas vertical
-- y horizontal del p�xel. Devuelve a su salida una se�al de 8 bits que indica los colores
-- correspondientes de Mario que toca pintar

-- Descripci�n de la entidad: Declaraci�n de puertos del Mario
-- refresh: se�al de control que se activa cuando llegamos al final de la pantalla
-- sobrePlatM: se�al de control que se activa cuando el Mario est� sobre una plataforma
-- sobreEsc: se�al de control que se activa cuando el Mario est� sobre una escalera
-- resets: se�al de control

entity Mario is
    Port ( 	ejex : in  STD_LOGIC_VECTOR(9 downto 0);
				ejey : in  STD_LOGIC_VECTOR(9 downto 0);
				refresh : in  STD_LOGIC;
				reset : in  STD_LOGIC;
				clk : in  STD_LOGIC;
				left : in STD_LOGIC;
				right : in  STD_LOGIC;
				up : in  STD_LOGIC;
				down : in  STD_LOGIC;
				jump : in  STD_LOGIC;
       	   sobrePlatM: in STD_LOGIC;
				resets : in STD_LOGIC;
				sobreEsc : in STD_LOGIC;
				RGBm : out  STD_LOGIC_VECTOR(7 downto 0));
end Mario;

-- Descripci�n de la arquitectura
architecture Behavioral of Mario is
-- Declaraci�n de se�ales
signal p_posx, p_posy, posx, posy, ejex_aux,ejey_aux : unsigned(9 downto 0);

signal vely,p_vely: unsigned(4 downto 0);
signal p_goingUp, goingUp, jumping, p_jumping : STD_LOGIC;

--Se�ales para controlar la memoria
signal s_addr: STD_LOGIC_VECTOR(10 downto 0);
signal s_data : STD_LOGIC_VECTOR(2 downto 0);

-- Tipo de dato empleado para la m�quina de estados
type estado is (WAITING, POS_UPDATE, VEL_UPDATE);

signal state, p_state:estado;

-- Declaraci�n de diferentes constantes
constant VELX : unsigned(4 downto 0):= to_unsigned(3,5);
constant ACEL : unsigned(4 downto 0):= to_unsigned(1,5);
constant MAX_VELY:unsigned(4 downto 0):=to_unsigned(25,5);
constant VELY_SALTO:unsigned(4 downto 0):=to_unsigned(10,5);

-- Declaraci�n de la memoria generada por el Core Generator
COMPONENT marioROM
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;

begin
-- Instanciaci�n de la memoria
memoriaMario : marioROM
  PORT MAP (
    clka => clk,
    addra => s_addr,
    douta => s_data
  );
  
-- Proceso s�ncrono	
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

-- Proceso combinacional encargado de la representaci�n del Mario
comb: process(ejex,ejey, posx, posy, ejex_aux, ejey_aux, s_data, s_addr, up, down, left)
begin
	if (up = '1' or down = '1') then
	-- Mostramos la segunda imagen almacenada en la memoria correspondiente al Mario para cuando est� subiendo o bajando la escalera
		s_addr(10)<='1';
		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
		s_addr(4 downto 0) <= std_logic_vector(ejex_aux(4 downto 0));
	elsif (left = '1') then
	-- Mostramos la primera imagen almacenada en la memoria correspondiente al Mario haci�ndole la simetr�a cuando nos movemos a la izquierda
		s_addr(10)<='0';
		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
		s_addr(4 downto 0) <= std_logic_vector(32-ejex_aux(4 downto 0));
	else
	-- Mostramos la primera imagen almacenada en la memoria correspondiente al Mario cuando nos movemos a la derecha o nos quedamos parados en una plataforma o escalera	
		s_addr(10)<='0';
		s_addr(9 downto 5) <= std_logic_vector(ejey_aux(4 downto 0));
		s_addr(4 downto 0) <= std_logic_vector(ejex_aux(4 downto 0));
	end if;
	-- Se�ales adicionales para poder asociar una direcci�n de la memoria a una posici�n en la pantalla
	ejex_aux <= unsigned(ejex)-posx;
	ejey_aux <= unsigned(ejey)-posy;
	
	if((unsigned(ejex) >= posx) AND (unsigned(ejex) < (posx + 32)) AND (unsigned(ejey) >= posy) AND (unsigned(ejey) < posy + 32)) then
		-- Pintamos el Mario
		RGBm<= s_data(2) & s_data(2) & s_data(2) & s_data(1) & s_data(1) & s_data(1) & s_data(0) & s_data(0);
	else
		RGBm<="00000000";
	end if;
	
	-- Pintamos un �nico punto amarillo en el medio del borde inferior del Mario
	if((unsigned(ejex) = posx +16) AND (unsigned(ejey) = (posy + 31))) then
		RGBm<="11100001";
	end if;
	
end process;

-- M�quina de estados donde gestionamos todo lo correspondiente al movimiento del Mario		
maquina_estado: process(refresh,posx, posy, vely, state, left, right, sobrePlatM, jump, jumping, goingUp, resets, sobreEsc, up, down)
begin
	-- Realizamos un reset s�ncrono cuando el Mario muere o llega al final de la partida
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
			-- WAITING: estado en el que el Mario permanece a la espera hasta que se activa la se�al refresh
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
				
			-- POS_UPDATE: estado en el que se actualiza la posici�n del Mario			
			when POS_UPDATE =>
				p_state<=VEL_UPDATE;
				
				-- Control de posici�n horizontal
				if (left='1' and posx>VELX) then -- Restricci�n para no salirme de la pantalla cuando nos movemos a la izquierda
					p_posx<=posx-VELX;
				elsif (right='1' and posx + 32 < to_unsigned(639,10)) then -- Misma restricci�n en el otro lado de la pantalla
					p_posx<=posx+VELX;
				else
					p_posx<=posx;
				end if;
				
				-- Control de posici�n vertical
				if(sobreEsc='1' and jumping = '0') then
					-- Gesti�n del movimiento del Mario en la escalera
					if (up ='1') then
						p_posy <= posy-1;
					elsif(down='1') then
						p_posy <= posy+1;
					else
						p_posy <= posy;
					end if;
				elsif(goingUp='0')then
					-- Controlamos el Mario cuando est� cayendo
					if(sobrePlatM ='0') then
					-- Sino estamos en la plataforma, seguimos cayendo	
						p_posy <= posy + vely;
					else
					-- Si estamos en la plataforma, nos vamos saliendo de la misma de un p�xel en un p�xel 
						p_posy <= posy-1;
						p_jumping<='0';
					end if;
				else
					if(posy>vely)then 
						p_posy<=posy-vely; -- Si no me salgo de la pantalla, actualizamos la posici�n con normalidad
					else
						p_posy<=posy; -- Si me salgo de la pantalla, establecemos un l�mite
					end if;
				end if;
				
			-- VEL_UPDATE: estado en el que se actualiza la velocidad del Mario		
			when VEL_UPDATE =>
				p_state <= WAITING;
				if (sobreEsc = '1' and (up = '1' or down ='1')) then
					-- Cuando estamos subiendo o bajando la escalera ponemos la velocidad del eje vertical a cero.
					p_vely <= (others => '0');
				else
					if goingUp = '0' then
					-- Cuando el Mario est� cayendo	
						if sobrePlatM = '0' then  -- No estamos sobre la plataforma
							if (vely<MAX_VELY) then
							-- Sino hemos llegado a la velocidad m�xima, seguimos aumentando dicha velocidad.
						        -- Con ello, conseguimos realizar el efecto gravitatorio en la ca�da del Mario
								p_vely<=vely+ACEL;
							else
								p_vely<=vely;
							end if;
						else 
						-- Si estamos en la plataforma, ponemos la velocidad del eje vertical a cero.
							p_vely <= (others => '0');
						end if;	
					else
						if vely > ACEL then
						-- Vamos decrementando la velocidad hasta que se deja de cumplir la condici�n anterior	
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

