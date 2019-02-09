
-------------------------------------------------------------------
--	Trabajo Donkey Kong - Complementos de Electrónica	 --
--	Máster Universitario en Ingeniería de Telecomunicación 	 --
--	Universidad de Sevilla, Curso 2018/2019			 --	
--								 --	
--	Autores:						 --
--								 --
--		- José Manuel Gata Romero  			 --
--		- Ildefonso Jiménez Silva			 --
--		- Guillermo Palomino Lozano			 --
--								 --
-------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Componente barril encargado tanto del movimiento como de la representación de los barriles. 
-- Recibe como entrada las coordenadas vertical y horizontal del píxel, y otras señales de activación como sobrePlatB o aparece.
-- Devuelve a su salida una señal de 8 bits que indica los colores correspondientes del barril que toca pintar

-- Señales de interés:

-- sobrePlatB. 		Señal de activación que se pone a '1' cuando el barril ha aterrizado sobre una Plataforma. Se activa en el bloque Control
-- aparece. 		Señal que habilita la aparición de un barril. Generada por el bloque contador_barriles
-- refresh. 		Señal que indica que todos los píxeles de la pantalla han sido pintados y se vuelve a comenzar. Para este bloque significa
--				que debe de actualizar el valor de la posición y velocidad de los barriles.
-- RGBb. 		Señal de salida que indica, dados un píxel determinado por ejex y ejey, qué valor debe pintarse en referencia al mapa de barriles.
-- resets. 		Reset síncrono que se activa a nivel alto cuando Mario muere o cuando acaba el juego.

entity barril is
    Port ( clk : in STD_LOGIC;
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
-- Declaración de las señales utilizadas en este bloque

-- Constantes que marcan distintas velocidades y aceleraciones prefijadas
constant MAX_VELY : unsigned(4 downto 0):=to_unsigned(25,5);
constant VELX : unsigned(4 downto 0):= to_unsigned(5,5);
constant ACEL : unsigned(4 downto 0):= to_unsigned(1,5);
constant suelo : unsigned (9 downto 0) := to_unsigned(431,10);

-- Señales auxiliares para garantizar el buen funcionamiento de los procesos síncronos.
signal p_posx, p_posy, posx, posy, ejex_aux, ejey_aux : unsigned(9 downto 0);
signal vely,p_vely: unsigned(4 downto 0);
signal p_sentido, sentido, restart,p_restart: STD_LOGIC; 

-- Los diferentes estados posibles de la FSM del barril
type estado is (WAITING, FALLING, POS_UPDATE, VEL_UPDATE);
signal state, p_state:estado;

--MEMORIA

-- Señal para el direccionamiento
signal s_addr : STD_LOGIC_VECTOR(8 downto 0);
-- Señal para los datos
signal s_data : STD_LOGIC_VECTOR(2 downto 0);

-- Declaración de la memoria generado por el CORE Generator
COMPONENT barrilROM
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;


begin
-- Instanciación de la memoria
mibarril : barrilROM
  PORT MAP (
    clka => clk,
    addra => s_addr,
    douta => s_data
  );

-- Proceso encargado de garantizar la sincronía. Bajo la estructura seguida durante toda la asignatura.
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
		-- Cuando pasa un ciclo de reloj: Los próximos valores pasan a ser los actuales
		posx <= p_posx;
		posy <= p_posy;
		vely <= p_vely;
		state <= p_state;
		sentido <= p_sentido;
		restart <= p_restart;
	end if;
end process;

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
	-- Señales adicionales para poder asociar una posición de la memoria a una posición en la pantalla
	ejex_aux <= unsigned(ejex)-posx;
	ejey_aux <= unsigned(ejey)-posy;
	
	if((unsigned(ejex) >= posx) AND (unsigned(ejex) < (posx + 16)) AND (unsigned(ejey) >= posy) AND (unsigned(ejey) < posy + 16)) then
		-- Si toca pintar el barril, vemos qué datos hay a la salida
		RGBb<= s_data(2) & s_data(2) & s_data(2) & s_data(1) & s_data(1) & s_data(1) & s_data(0) & s_data(0);
	else
		-- Si no toca pintar un barril, pintamos el color negro
		RGBb<="00000000"; --Pinta de negro
	end if;
	
	if((unsigned(ejex) = posx +8) AND (unsigned(ejey) = (posy + 16))) then
		-- Pintamos un único punto amarillo en el medio del barril para poder gestionar las acciones (se hace en Control.vhd)
		RGBb<="10001000";
	end if;
end process;


maquina_estado: process(restart,refresh,posx, posy, vely, state, sentido, aparece, sobrePlatB, resets)
begin
	-- resets: Reset síncrono activo a nivel alto asociado a fin de juego
	-- restart: Reset síncrono activo a nivel alto que se activa cuando un barril finaliza su recorrido
	if (resets = '1' OR restart = '1') then
		p_posx <= to_unsigned(1008,10);
		p_posy <= to_unsigned(0,10);
		p_vely <= (others => '0');
		p_state <= WAITING;
		p_sentido<='1';
		p_restart <= '0';
	else
		-- Si no se cambian durante el proceso, las señales conservan sus valores anteriores.
		p_state <= state;
		p_posx <= posx;
		p_posy <= posy;
		p_vely <= vely;
		p_sentido <= sentido;
		p_restart <= restart;
		case state is
			-- Estado WAITING. Permanece a la espera hasta que se activa la señal aparece 
			-- que indica la aparición de un barril en el juego
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
					-- Se actualiza la posición
					p_state<=POS_UPDATE;
				elsif ((posy + 15 = suelo) AND (posx < VELX)) then
					-- Hemos llegado al final, reset síncrono interno del barril para que vuelva a esperar señal de aparece
					p_restart <= '1';
					p_state <= WAITING;
				else
					p_state<=FALLING;
				end if;
			-- Estado POS_UPDATE. Actualiza la posición del barril como corresponda
			when POS_UPDATE =>
				p_state<=VEL_UPDATE;
			-- Control de posición horizontal
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
				
			-- Control de posición vertical
				if(sobrePlatB ='0') then
					-- Estoy Cayendo, aumento la velocidad
					p_posy <= posy + vely;
				else
					-- Para no salirme de la plataforma
					p_posy <= posy-1; 
				end if;
			
			-- Estado VEL_UPDATE
			when VEL_UPDATE =>
			-- Control de posición horizontal: es una constante (VELX) por lo que no se hace nada
			-- Control de posición vertical
				p_state <= FALLING;
				if sobrePlatB = '0' then
					-- Si no estoy sobre una plataforma tengo que caer
					if (vely<MAX_VELY) then
						-- Si no he llegado al límite de velocidad máxima sigo aumentando la velocidad
						p_vely<=vely+ACEL;
					else
						-- Si he llegado al límite máximo no acelero más
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
