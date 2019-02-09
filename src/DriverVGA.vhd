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

-- Descripci�n de la entidad: Declaraci�n de puertos del DriverVGA
-- RGBin: Se�al de entrada que indica el color RGB generado por el bloque Control
-- HS: Se�al de salida que indica el pulso de sincronismo horizontal
-- HV: Se�al de salida que indica el pulso de sincronismo vertical
-- refresh: Se�al de salida que indica la terminaci�n de la representaci�n de una pantalla
-- ejex, ejey: Se�ales de salida correspondientes con las coordenadas horizontal y vertical, respectivamente
-- RGBout: Se�al de salida que representa el color en 8 bits que se corresponder� con el p�xel indicado
entity DriverVGA is
    Port (	clk : in  STD_LOGIC;
				reset : in  STD_LOGIC;
				RGBin : in  STD_LOGIC_VECTOR(7 downto 0);
				HS : out  STD_LOGIC;
				VS : out  STD_LOGIC;
				refresh : out STD_LOGIC;
				ejex, ejey : out STD_LOGIC_VECTOR(9 downto 0);
				RGBout : out  STD_LOGIC_VECTOR(7 downto 0));
end DriverVGA;

-- Descripci�n de la arquitectura
architecture Behavioral of DriverVGA is
	
-- Declaraci�n de se�ales internas utilizadas en procesos y para la interconexi�n de bloques
signal clk_pixel, pclk_pixel, resets1O, resets2O, Blank_h, Blank_v, enable2 : STD_LOGIC;
signal Qx, Qy : STD_LOGIC_VECTOR (9 downto 0);

-- Declaraci�n de componentes

-- Contador s�ncrono de Nbit con habilitaci�n y reset s�ncrono.
component contador is
    Generic (Nbit: INTEGER := 8);
	 Port ( 	enable : in  STD_LOGIC;
           	clk : in  STD_LOGIC;
				reset : in STD_LOGIC;
				resets : in STD_LOGIC;
				Q : out STD_LOGIC_VECTOR (Nbit-1 downto 0)); 
end component;

-- Comparador s�ncrono
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
	
-- Instanciaci�n de cada uno de los componentes ya mencionados arriba.			  
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

-- Bloque frec_pixel, directamente dise�ado en el nivel de jerarquia superior
pclk_pixel <= not clk_pixel;

-- Proceso s�ncrono contador para dividir la frecuencia de reloj a una frecuencia apreciable por el ojo humano.
div_frec: process(clk, reset)
begin
	if(reset='1') then
		clk_pixel <= '0';
	elsif (rising_edge(clk)) then
		clk_pixel <= pclk_pixel;
	end if;
end process;

-- Proceso combinacional encargado de no mostrar ning�n color cuando se est� volviendo a otra l�nea de la imagen
gen_color: process(Blank_H, Blank_V, RGBin)
begin
	if (Blank_H ='1' or Blank_V = '1') then
		RGBout <= (others => '0');
	else
		RGBout <= RGBin;
	end if;
end process;
		
end Behavioral;
