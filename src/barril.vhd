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

-- Componente barril encargado tanto del movimiento como de la representaci�n de los barriles. 
-- Recibe como entrada las coordenadas vertical y horizontal del p�xel, y otras se�ales de activaci�n como sobrePlatB o aparece.
-- Devuelve a su salida una se�al de 8 bits que indica los colores correspondientes del barril que toca pintar

-- Puertos de inter�s:

-- sobrePlatB. 	Se�al de activaci�n que se pone a '1' cuando el barril ha aterrizado sobre una Plataforma. Se activa en el bloque Control
-- aparece. 		Se�al que habilita la aparici�n de un barril. Generada por el bloque contador_barriles
-- refresh. 		Se�al que indica que todos los p�xeles de la pantalla han sido pintados y se vuelve a comenzar. Para este bloque significa
--							que debe de actualizar el valor de la posici�n y velocidad de los barriles.
-- RGBb. 			Se�al de salida que indica, dados un p�xel determinado por ejex y ejey, qu� valor debe pintarse en referencia al mapa de barriles.
-- resets. 			Reset s�ncrono que se activa a nivel alto cuando Mario muere o cuando acaba el juego.

entity barril is
    Port ( 	clk : in STD_LOGIC;
				reset : in STD_LOGIC;
				ejex : in  STD_LOGIC_VECTOR(9 downto 0);
				ejey : in  STD_LOGIC_VECTOR(9 downto 0);
				sobrePlatB : in  STD_LOGIC;
				aparece : in  STD_LOGIC;
				refresh : in STD_LOGIC;
				RGBb : out  STD_LOGIC_VECTOR(7 downto 0);
				resets : in STD_LOGIC);
end barril;

architecture Behavioral of barril is
-- Declaraci�n de las se�ales utilizadas en este bloque

-- Constantes que marcan distintas velocidades y aceleraciones prefijadas
constant MAX_VELY : unsigned(4 downto 0):=to_unsigned(25,5);
constant VELX : unsigned(4 downto 0):= to_unsigned(5,5);
constant ACEL : unsigned(4 downto 0):= to_unsigned(1,5);
constant suelo : unsigned (9 downto 0) := to_unsigned(431,10);

-- Se�ales auxiliares para garantizar el buen funcionamiento de los procesos s�ncronos.
signal p_posx, p_posy, posx, posy, ejex_aux, ejey_aux : unsigned(9 downto 0);
signal vely,p_vely: unsigned(4 downto 0);
signal p_sentido, sentido, restart,p_restart: STD_LOGIC; 

-- Los diferentes estados posibles de la FSM del barril
type estado is (WAITING, FALLING, POS_UPDATE, VEL_UPDATE);
signal state, p_state:estado;

--MEMORIA

-- Se�al para el direccionamiento
signal s_addr : STD_LOGIC_VECTOR(8 downto 0);
-- Se�al para los datos
signal s_data : STD_LOGIC_VECTOR(2 downto 0);

-- Declaraci�n de la memoria generado por el CORE Generator
COMPONENT barrilROM
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;


begin
-- Instanciaci�n de la memoria
mibarril : barrilROM
  PORT MAP (
    clka => clk,
    addra => s_addr,
    douta => s_data
  );

-- Proceso encargado de garantizar la sincron�a. Bajo la estructura seguida durante toda la asignatura.
sinc: process(clk,reset)
begin
	if(reset = '1') then
		-- Si hay un  reset fijamos valores iniciales
		posx <= to_unsigned(1008,10);
		posy <= to_unsigned(0,10);
		vely <= (others => '0');
		state <= WAITING;
		sentido<='1';
		restart <= '0';
	elsif(rising_edge(clk)) then
		-- Cuando pasa un ciclo de reloj: Los pr�ximos valores pasan a ser los actuales
		posx <= p_posx;
		posy <= p_posy;
		vely <= p_vely;
		state <= p_state;
		sentido <= p_sentido;
		restart <= p_restart;
	end if;
end process;

-- Proces combinacional encargado de pintar el barril accediendo a la memoria correspondiente
comb: process(ejex,ejey, posx, posy, vely, ejey_aux, ejex_aux, s_data,resets, refresh)
begin
	-- Pintamos el barril, generado por memoria
	if (vely > 2) then
		-- Si estoy cayendo tengo que cambiar de sprite
		s_addr(8) <= '1'; -- Con este bit a '1' me voy a las zonas bajas de la memoria (barril cayendo)
		s_addr(7 downto 4) <= std_logic_vector(ejey_aux(3 downto 0));
		s_addr(3 downto 0) <= std_logic_vector(ejex_aux(3 downto 0));
	else
		s_addr(8) <='0'; -- con este bit a '0' me voy a las zonas altas de la memoria (barril rodando)
		s_addr(7 downto 4) <= std_logic_vector(ejey_aux(3 downto 0));
		s_addr(3 downto 0) <= std_logic_vector(ejex_aux(3 downto 0));
	end if;
	-- Se�ales adicionales para poder asociar una posici�n de la memoria a una posici�n en la pantalla
	ejex_aux <= unsigned(ejex)-posx;
	ejey_aux <= unsigned(ejey)-posy;
	
	if((unsigned(ejex) >= posx) AND (unsigned(ejex) < (posx + 16)) AND (unsigned(ejey) >= posy) AND (unsigned(ejey) < posy + 16)) then
		-- Si toca pintar el barril, vemos qu� datos hay a la salida
		RGBb<= s_data(2) & s_data(2) & s_data(2) & s_data(1) & s_data(1) & s_data(1) & s_data(0) & s_data(0);
	else
		-- Si no toca pintar un barril, pintamos el color negro
		RGBb<="00000000"; --Pinta de negro
	end if;
	
	if((unsigned(ejex) = posx +8) AND (unsigned(ejey) = (posy + 16))) then
		-- Pintamos un �nico punto amarillo en el medio del barril para poder gestionar las acciones (se hace en Control.vhd)
		RGBb<="10001000";
	end if;
end process;

-- M�quina de Estados Finita asociada al comportamiento del barril
maquina_estado: process(restart,refresh,posx, posy, vely, state, sentido, aparece, sobrePlatB, resets)
begin
	-- resets: Reset s�ncrono activo a nivel alto asociado a fin de juego
	-- restart: Reset s�ncrono activo a nivel alto que se activa cuando un barril finaliza su recorrido
	if (resets = '1' OR restart = '1') then
		p_posx <= to_unsigned(1008,10);
		p_posy <= to_unsigned(0,10);
		p_vely <= (others => '0');
		p_state <= WAITING;
		p_sentido<='1';
		p_restart <= '0';
	else
		-- Si no se cambian durante el proceso, las se�ales conservan sus valores anteriores.
		p_state <= state;
		p_posx <= posx;
		p_posy <= posy;
		p_vely <= vely;
		p_sentido <= sentido;
		p_restart <= restart;
		case state is
			-- Estado WAITING. Permanece a la espera hasta que se activa la se�al aparece 
			-- que indica la aparici�n de un barril en el juego
			when WAITING =>
				if aparece='1' then
					p_state <= FALLING;
					p_posx <= to_unsigned(0,10);
					p_posy <= to_unsigned(0,10);
					p_sentido  <= '1';
				else
					p_state <= WAITING;
				end if;
			-- Estado FALLING. El barril cae por todo el escenario hasta que llega al final del mapa
			when FALLING =>
				if (refresh ='1') then
					-- Se actualiza la posici�n
					p_state<=POS_UPDATE;
				elsif ((posy + 15 = suelo) AND (posx < VELX)) then
					-- Hemos llegado al final, reset s�ncrono interno del barril para que vuelva a esperar se�al de aparece
					p_restart <= '1';
					p_state <= WAITING;
				else
					p_state<=FALLING;
				end if;
			-- Estado POS_UPDATE. Actualiza la posici�n del barril como corresponda
			when POS_UPDATE =>
				p_state<=VEL_UPDATE;
				-- Control de posici�n horizontal
				if (sentido ='0') then
					-- Si vamos hacia la izquierda, esperamos hasta llegar al final de la pantalla
					if (posx < VELX) then
						-- Hemos llegado al final (parte izquierda de la pantalla)
						p_posx<=posx+VELX; -- Nos comenzamos a desplazar a la derecha
						p_sentido <= '1'; -- Cambio el sentido
					else
						p_posx<=posx-VELX; -- Nos continuamos desplazando hacia la izquierda
					end if;
				else
					-- Si vamos hacia la derecha, esperamos hasta llegar al final de la pantalla
					if (posx + 16 > to_unsigned(639,10)) then
						-- Hemos llegado al final (parte derecha de la pantalla)
						p_posx <= posx-VELX; -- Nos comenzamos a desplazar a la izquierda
						p_sentido <= '0'; -- Cambio de sentido
					else
						p_posx <= posx+VELX; -- Nos continuamos desplazando hacia la derecha
					end if;
				end if;			
				
			-- Control de posici�n vertical
				if(sobrePlatB ='0') then
					-- Estoy Cayendo, aumento la velocidad
					p_posy <= posy + vely;
				else
					-- Para no salirme de la plataforma
					p_posy <= posy-1; 
				end if;
			
			-- Estado VEL_UPDATE
			when VEL_UPDATE =>
			-- Control de posici�n horizontal: es una constante (VELX) por lo que no se hace nada
			-- Control de posici�n vertical
				p_state <= FALLING;
				if sobrePlatB = '0' then
					-- Si no estoy sobre una plataforma tengo que caer
					if (vely<MAX_VELY) then
						-- Si no he llegado al l�mite de velocidad m�xima sigo aumentando la velocidad
						p_vely<=vely+ACEL;
					else
						-- Si he llegado al l�mite m�ximo no acelero m�s
						p_vely<=vely;
					end if;
				else 
					-- Si estoy sobre el barril establezco la velocidad a 0.
					p_vely <= (others => '0');
				end if;
		end case;
	end if;
end process;

end Behavioral;
