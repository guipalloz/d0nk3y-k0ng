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

-- Descripción de la entidad: Declaración de puertos del DriverVGA
-- RGBin: Señal de entrada que indica el color RGB generado por el bloque Control
-- HS: Señal de salida que indica el pulso de sincronismo horizontal
-- HV: Señal de salida que indica el pulso de sincronismo vertical
-- refresh: Señal de salida que indica la terminación de la representación de una pantalla
-- ejex, ejey: Señales de salida correspondientes con las coordenadas horizontal y vertical, respectivamente
-- RGBout: Señal de salida que representa el color en 8 bits que se corresponderá con el píxel indicado
entity DriverVGA is
    Port (clk : in  STD_LOGIC;
          reset : in  STD_LOGIC;
	  RGBin : in  STD_LOGIC_VECTOR(7 downto 0);
          HS : out  STD_LOGIC;
          VS : out  STD_LOGIC;
	  refresh : out STD_LOGIC;
	  ejex, ejey : out STD_LOGIC_VECTOR(9 downto 0);
          RGBout : out  STD_LOGIC_VECTOR(7 downto 0));
end DriverVGA;

-- Descripción de la arquitectura
architecture Behavioral of DriverVGA is
	
-- Declaración de señales internas utilizadas en procesos y para la interconexión de bloques
signal clk_pixel, pclk_pixel, resets1O, resets2O, Blank_h, Blank_v, enable2 : STD_LOGIC;
signal Qx, Qy : STD_LOGIC_VECTOR (9 downto 0);

-- Declaración de componentes

-- Contador síncrono de Nbit con habilitación y reset síncrono.
component contador is
    Generic (Nbit: INTEGER := 8);
	 Port ( enable : in  STD_LOGIC;
           	clk : in  STD_LOGIC;
		reset : in STD_LOGIC;
 	  	resets : in STD_LOGIC;
		Q : out STD_LOGIC_VECTOR (Nbit-1 downto 0)); 
end component;

-- Comparador síncrono
component comparador is
	Generic (Nbit: integer :=8;
	End_Of_Screen: integer :=10;
	Start_Of_Pulse: integer :=20;
	End_Of_Pulse: integer :=30;
	End_Of_Line: integer :=40);
	Port ( clk : in STD_LOGIC;
	       reset : in STD_LOGIC;
	       data : in STD_LOGIC_VECTOR (Nbit-1 downto 0);	
	       O1 : out STD_LOGIC;
	       O2 : out STD_LOGIC;
	       O3 : out STD_LOGIC);
end component;

begin
	
-- Instanciación de cada uno de los componentes ya mencionados arriba.			  
contadorh: contador
	GENERIC MAP (Nbit => 10)
	PORT MAP(
		enable => clk_pixel,
		clk => clk,
		reset => reset,
		Q => Qx,
		resets => resets1O);
		
contadorv: contador
	GENERIC MAP (Nbit => 10)
	PORT MAP(
		enable => enable2,
		clk => clk,
		reset => reset,
		Q => Qy,
		resets => resets2O);
		
comph: comparador
	Generic MAP (
		Nbit => 10,
		End_Of_Screen => 639,
		Start_Of_Pulse => 655,
		End_Of_Pulse => 751,
		End_Of_Line => 799)
	Port MAP (clk => clk,
		reset => reset,
		data => Qx,
		O1 => Blank_H,
		O2 => HS,
		O3 => resets1O);
			
compv: comparador
	Generic MAP (
		Nbit => 10,
		End_Of_Screen => 479,
		Start_Of_Pulse => 489,
		End_Of_Pulse => 491,
		End_Of_Line => 520)
	Port MAP (clk => clk,
			reset => reset,
			data => Qy,
			O1 => Blank_V,
			O2 => VS,
			O3 => resets2O);
	

ejex <= Qx;
ejey <= Qy;
refresh <= resets2O;

enable2 <= resets1O AND clk_pixel;

-- Bloque frec_pixel, directamente diseñado en el nivel de jerarquia superior
pclk_pixel <= not clk_pixel;

-- Proceso síncrono contador para dividir la frecuencia de reloj a una frecuencia apreciable por el ojo humano.
div_frec: process(clk, reset)
begin
	if(reset='1') then
		clk_pixel <= '0';
	elsif (rising_edge(clk)) then
		clk_pixel <= pclk_pixel;
	end if;
end process;

-- Proceso combinacional encargado de no mostrar ningún color cuando se está volviendo a otra línea de la imagen
gen_color: process(Blank_H, Blank_V, RGBin)
begin
	if (Blank_H ='1' or Blank_V = '1') then
		RGBout <= (others => '0');
	else
		RGBout <= RGBin;
	end if;
end process;
		
end Behavioral;
