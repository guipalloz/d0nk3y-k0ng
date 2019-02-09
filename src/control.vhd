--------------------------------------------------------------------
--	Trabajo Donkey Kong - Complementos de Electrónica	 				--
--	Máster Universitario en Ingenierí­a de Telecomunicación 		 	--
--	Universidad de Sevilla, Curso 2018/2019			 					--	
--								 														--	
--	Autores:						 													--
--																						--
--		- José Manuel Gata Romero  			 								--
--		- Ildefonso Jiménez Silva			 									--
--		- Guillermo Palomino Lozano			 								--
--								 														--
--------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Descripción de la entidad: Declaración de puertos del bloque Control
-- RGBm: Señal de entrada correspondiente con los colores generados por el bloque Mario
-- RGBb1, RGBb2, RGBb3: Señales de entrada correspondiente con los colores generados por cada bloque de barril
-- RGBs: Señal de entrada correspondiente con los colores de las plataformas generada por el bloque Stage
-- RGBe: Señal de entrada correspondiente con los colores de la escalera generada por el bloque Stage
-- RGBin: Señal de salida corresponiente con el color con el que se representrá el píxel
-- sobrePlatM, sobrePlatB1, sobrePlatB3, sobrePlatB3: Señales que indicarán si tanto Mario como cada
-- uno de los barriles se encuentran sobre una plataforma
-- sobreEsc: Señal de salida que indica si Mario se encuentra en una escalera para habilitar la función de subir o bajar
-- gameover: Señal de salida que se activa cuando un barril choca con Mario para indicar que se debe hacer un reset síncrono

entity control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RGBm : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBb1 : in  STD_LOGIC_VECTOR(7 downto 0);
			  RGBb2 : in  STD_LOGIC_VECTOR(7 downto 0);
			  RGBb3 : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBe : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR(7 downto 0);
			  sobrePlatM : out  STD_LOGIC;
			  sobrePlatB1 : out  STD_LOGIC;
			  sobrePlatB2 : out  STD_LOGIC;
			  sobrePlatB3 : out  STD_LOGIC;
			  sobreEsc : out STD_LOGIC;
			  gameover : out STD_LOGIC);
end control;

-- Descripción de la arquitectura
architecture Behavioral of control is

-- Declaración de señales internas utilizadas en los procesos de este bloque
signal sobrePlataforma_mario, p_sobrePlataforma_mario: std_logic;
signal sobreEscalera, p_sobreEscalera: std_logic;
signal sobrePlataforma_barril1, p_sobrePlataforma_barril1: std_logic;
signal sobrePlataforma_barril2, p_sobrePlataforma_barril2: std_logic;
signal sobrePlataforma_barril3, p_sobrePlataforma_barril3: std_logic;

-- Declaración de constantes correspondientes con los colores utilizados para:
---- Representar las plataformas
constant color_plataforma: STD_LOGIC_VECTOR(7 downto 0):= "11000011"; 
---- Representar Mario
constant color_mario: STD_LOGIC_VECTOR(7 downto 0):= "11100000";
---- Representar barril
constant color_barril: STD_LOGIC_VECTOR(7 downto 0):= "11100000";
---- Representar escaleras
constant color_escalera: STD_LOGIC_VECTOR(7 downto 0):= "00011011";
---- Representar un punto amarillo para gestionar las acciones de Mario
constant color_aviso_mario: STD_LOGIC_VECTOR(7 downto 0):= "11100001";

begin
sobrePlatM<=sobrePlataforma_mario;
sobrePlatB1<=sobrePlataforma_barril1;
sobrePlatB2<=sobrePlataforma_barril2;
sobrePlatB3<=sobrePlataforma_barril3;
sobreEsc<= sobreEscalera;

comb: process(RGBm, RGBb1, RGBb2, RGBb3, RGBe, sobrePlataforma_barril1, sobrePlataforma_barril2, sobrePlataforma_barril3, RGBs,sobrePlataforma_mario, sobreEscalera)
begin
	-- Control de Mario sobre plataforma:
	-- Si el punto amarillo coincide en el mismo píxel que una plataforma, se indica que Mario está sobre una plataforma
	if (RGBm=color_aviso_mario and RGBs=color_plataforma)then
		p_sobrePlataforma_mario<='1';
	elsif(RGBm=color_aviso_mario and RGBs="00000000")then
		p_sobrePlataforma_mario<='0';
	else
		p_sobrePlataforma_mario <= sobrePlataforma_mario;
	end if;

	-- Control de barril sobre plataforma:
	-- Si el barril se encuentra sobre una plataforma, se indica activando la señal correspondiente a cada barril:
	
	-- Para el barril 1
	if (RGBb1=color_barril and RGBs=color_plataforma)then
		p_sobrePlataforma_barril1<='1';
	elsif(RGBb1=color_barril and RGBs="00000000")then
		p_sobrePlataforma_barril1<='0';
	else
		p_sobrePlataforma_barril1 <= sobrePlataforma_barril1;
	end if;
	
	-- Para el barril 2
	if (RGBb2=color_barril and RGBs=color_plataforma)then
		p_sobrePlataforma_barril2<='1';
	elsif(RGBb2=color_barril and RGBs="00000000")then
		p_sobrePlataforma_barril2<='0';
	else
		p_sobrePlataforma_barril2 <= sobrePlataforma_barril2;
	end if;
	
	-- Para el barril 3
	if (RGBb3=color_barril and RGBs=color_plataforma)then
		p_sobrePlataforma_barril3<='1';
	elsif(RGBb3=color_barril and RGBs="00000000")then
		p_sobrePlataforma_barril3<='0';
	else
		p_sobrePlataforma_barril3 <= sobrePlataforma_barril3;
	end if;
	
	-- Control de muerte:
	-- Si alguno de los barriles coincide con Mario, se activa una señal de gameover que se usará para reiniciar el juego
	if ((RGBb1=color_barril OR RGBb2=color_barril OR RGBb3=color_barril) and RGBm=color_mario)then
		gameover <= '1';
	else
		gameover <= '0';
	end if;
	
	-- Control de Mario sobre escalera:
	-- Si Mario coincide con una escalera, se activa la señal que lo indica
	if (RGBm=color_aviso_mario and RGBe=color_escalera)then
		p_sobreEscalera<='1';
	elsif(RGBm=color_aviso_mario and (RGBe="00000000" or RGBs=color_plataforma))then
		p_sobreEscalera<='0';
	else
		p_sobreEscalera <= sobreEscalera;
	end if;

	-- Finalmente, se determina el color que aparecerá por pantalla, priorizando algunos elementos para evitar solapes
	-- Se establece el orden de prioridad de la siguiente forma:
	if (RGBm /= "00000000") then
		RGBin <= RGBm; -- Primera prioridad para Mario
	elsif ((RGBb1 /= "00000000") OR (RGBb2 /= "00000000") OR (RGBb3 /= "00000000")) then
		RGBin <= RGBb1 OR RGBb2 OR RGBb3; -- Segunda prioridad para los barriles
	elsif (RGBs /= "00000000") then
		RGBin <= RGBs; -- Tercera prioridad para las plataformas
	elsif (RGBe /= "00000000") then
		RGBin <= RGBe; -- Cuarta prioridad para las escaleras
	else
		RGBin <= "00000000"; -- Por último, el fondo negro
	end if;
end process;

-- Proceso síncrono para actualizar las señales
sinc: process(clk,reset)
begin
	if(reset = '1') then
		sobrePlataforma_mario <= '0';
		sobrePlataforma_barril1 <= '0';
		sobrePlataforma_barril2 <= '0';
		sobrePlataforma_barril3 <= '0';
		sobreEscalera <= '0';
	elsif (rising_edge(clk)) then
		sobrePlataforma_mario <= p_sobrePlataforma_mario;
		sobrePlataforma_barril1 <= p_sobrePlataforma_barril1;
		sobrePlataforma_barril2 <= p_sobrePlataforma_barril2;
		sobrePlataforma_barril3 <= p_sobrePlataforma_barril3;
		sobreEscalera <= p_sobreEscalera;
	end if;
end process;
end Behavioral;
