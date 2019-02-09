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

-- Descripción de la entidad: Declaración de puertos del archivo principal
entity main is
    Port ( RGBout : out  STD_LOGIC_VECTOR(7 downto 0);
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           left : in  STD_LOGIC;
           right : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC);
end main;

-- Descripción de la arquitectura
architecture Behavioral of main is

-- Declaración de señales intermedias para interconexión de bloques
signal s_ejex, s_ejey: STD_LOGIC_VECTOR(9 downto 0);
signal s_RGBm, s_RGBs, s_RGBb1, s_RGBb2, s_RGBb3, s_RGB, s_RGBe: STD_LOGIC_VECTOR(7 downto 0);
signal s_refresh, s_sobrePlatM, s_sobrePlatB1, s_sobrePlatB2, s_sobrePlatB3, s_resets, s_sobreEsc: STD_LOGIC;
signal s_aparece : STD_LOGIC_VECTOR(2 downto 0);

-- Declaración de componentes

-- Driver VGA encargado de la representación de las imágenes en formato de 60 Herzios, 640x480 píxeles y 256 colores
component DriverVGA is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
	   RGBin : in  STD_LOGIC_VECTOR(7 downto 0);
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
	   refresh : out STD_LOGIC;
	   ejex, ejey : out STD_LOGIC_VECTOR(9 downto 0);
           RGBout : out  STD_LOGIC_VECTOR(7 downto 0));
end component;

-- Componente Mario encargado tanto del movimiento como de la representación del Mario. 
-- Recibe como entrada cada uno de los botones disponibles en el juego, las coordenadas vertical
-- y horizontal del píxel. Devuelve a su salida una señal de 8 bits que indica los colores
-- correspondientes de Mario que toca pintar
component Mario is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
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
end component;
	
-- Componente barril encargado tanto del movimiento como de la representación de los barriles. 
-- Recibe como entrada las coordenadas vertical y horizontal del píxel, y otras señales de activación como sobrePlatB o aparece.
-- Devuelve a su salida una señal de 8 bits que indica los colores correspondientes del barril que toca pintar
component barril is
    Port ( clk : in STD_LOGIC;
	   reset : in STD_LOGIC;
	   ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           sobrePlatB : in  STD_LOGIC;
           aparece : in  STD_LOGIC;
	   refresh : in STD_LOGIC;
	   resets : in STD_LOGIC;
           RGBb : out  STD_LOGIC_VECTOR(7 downto 0));
end component;

-- Componente encargado de pintar el escenario: las plataformas y las escaleras.
component stage is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           RGBs : out  STD_LOGIC_VECTOR(7 downto 0);
           RGBe : out  STD_LOGIC_VECTOR(7 downto 0));
end component;

-- Bloque de control que se encarga de recibir todas las componentes RGB de cada bloque y decidir cuál debe pintarse
-- en cada momento. Además, se controlan otros aspectos como la muerte del personaje y que tanto Mario como
-- los barriles estén en contacto con las plataformas.
component control is
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
end component;

-- Elemento encargado de la generación de los barriles permitiendo que los barriles salgan con diferentes distancias entre sí.
component contador_barriles is
    Port ( clk : in  STD_LOGIC;
	   reset : in  STD_LOGIC;
	   resets : in STD_LOGIC;
	    aparece : out  STD_LOGIC_VECTOR (2 downto 0));
end component;
	

begin
-- Instanciación de cada uno de los componentes ya mencionados arriba.
MiBarril1 : barril
	Port MAP( clk => clk,
		  reset => reset,
		  ejex => s_ejex,
		  ejey => s_ejey,
		  sobrePlatB => s_sobrePlatB1,
		  refresh => s_refresh,
		  aparece => s_aparece(0),
		  RGBb=> s_RGBb1,
		  resets => s_resets);

MiBarril2 : barril
	Port MAP( clk => clk,
		  reset => reset,
		  ejex => s_ejex,
		  ejey => s_ejey,
		  sobrePlatB => s_sobrePlatB2,
		  refresh => s_refresh,
		  aparece => s_aparece(1),
		  RGBb=> s_RGBb2,
		  resets => s_resets);

MiBarril3 : barril
	Port MAP( clk => clk,
		  reset => reset,
		  ejex => s_ejex,
		  ejey => s_ejey,
		  sobrePlatB => s_sobrePlatB3,
		  refresh => s_refresh,
		  aparece => s_aparece(2),
		  RGBb=> s_RGBb3,
		  resets => s_resets);
				 
MiMario: Mario
	Port MAP( ejex => s_ejex,
		  ejey => s_ejey,
		  refresh => s_refresh,
		  RGBm=> s_RGBm,
		  reset => reset,
		  clk => clk,
		  left => left,
		  right => right,
		  up => up,
		  down => down,
		  jump => jump,
		  sobrePlatM => s_sobrePlatM,
		  resets => s_resets,
		  sobreEsc => s_sobreEsc);
VGA: DriverVGA
    Port MAP( clk => clk,
              reset => reset,
	      RGBin => s_RGB,
	      HS => HS,
	      VS => VS,
	      refresh => s_refresh,
	      ejex => s_ejex,
	      ejey=> s_ejey,
	      RGBout => RGBout);
MiStage: stage
	Port MAP( ejex => s_ejex,
		  ejey => s_ejey,
		  RGBs => s_RGBs,
		  RGBe => s_RGBe);
MiControl: control
	Port MAP(clk => clk,
		 reset => reset,
		 RGBm => s_RGBm,
		 RGBb1 => s_RGBb1,
		 RGBb2 => s_RGBb2,
		 RGBb3 => s_RGBb3,
		 RGBs => s_RGBs,
		 RGBe => s_RGBe,
		 RGBin => s_RGB,
		 sobrePlatM => s_sobrePlatM,
		 sobrePlatB1 => s_sobrePlatB1,
		 sobrePlatB2=> s_sobrePlatB2,
		 sobrePlatB3 => s_sobrePlatB3,
		 sobreEsc => s_sobreEsc,
		 gameover => s_resets);

MiContador : contador_barriles
	Port MAP (clk => clk,
		  reset => reset,
		  resets => s_resets,
		  aparece => s_aparece);
				 
end Behavioral;

