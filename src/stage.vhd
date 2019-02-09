--------------------------------------------------------------------
--	Trabajo Donkey Kong - Complementos de Electrónica	 				--
--	Máster Universitario en Ingenierí­a de Telecomunicación 		 	--
--	Universidad de Sevilla, Curso 2018/2019			 					--	
--								 														--	
--	Autores:						 													--
--																						--
--		- José Manuel Gata Romero  			 								--
--		- Ildefonso Jimánez Silva			 									--
--		- Guillermo Palomino Lozano			 								--
--								 														--
--------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Descripción de la entidad: Declaración de puertos del bloque Stage
-- ejex, ejey: Señales de entrada que indican la posición del píxel que se va a generar
-- RGBs: Señal de salida correspondiente con el color de la plataforma
-- RGBe: Señal de salida correspondiente con el color de la escalera
-- Se necesitan dos señales distintas para diferenciar a la hora de activar sobrePlat y sobreEsc a la vez,
---- es decir, distinguir cuando Mario está tanto en una plataforma como en una escalera
entity stage is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           RGBs : out  STD_LOGIC_VECTOR(7 downto 0);
			  RGBe : out  STD_LOGIC_VECTOR(7 downto 0));
end stage;
	
-- Descripción de la arquitectura
architecture Behavioral of stage is
-- Definición de las constantes correspondientes con los colores de las plataformas y las escaleras
constant color_plataforma: STD_LOGIC_VECTOR(7 downto 0):= "11000011";
constant color_escalera: STD_LOGIC_VECTOR(7 downto 0):= "00011011";
begin

-- Proceso combinacional encargado de indicar el color que se mostrará para las señales de las plataformas y escaleras
repr: process(ejex,ejey)
	begin

	RGBs<="00000000"; -- Se pinta el color del fondo negro en ambas señales
	RGBe<="00000000";
	
	-- Condiciones para pintar cada plataforma:
	-- Los valores de la posición de las plataformas se ha elegido para que estén aproximadamente equiespaciadas en el eje vertical.
	-- Respecto al eje x, se han definido de forma que el suelo ocupe todo el eje x, que la 1ª y 3ª plataforma empiecen desde la
	---- izquierda y la 2ª por la derecha, con un espacio sin que llegue a ocupar todo el eje x
	-- Respecto al eje y, el suelo se pinta a partir del píxel 430, por lo que tendrá 50 pixeles de grosor, mientras que las
	---- plataformas tendrán un grosor de 25 píxeles
	if(unsigned(ejey) > to_unsigned(430,10)) then
		RGBs<=color_plataforma; -- Pinta la plataforma más inferior correspondiente al suelo
	elsif(unsigned(ejey) > to_unsigned(315,10) AND unsigned(ejey) < to_unsigned(340,10) AND unsigned(ejex) < to_unsigned(480,10)) then
		RGBs<=color_plataforma; --Pinta 1º plataforma
	elsif(unsigned(ejey) > to_unsigned(200,10) AND unsigned(ejey) < to_unsigned(225,10) AND unsigned(ejex) > to_unsigned(160,10)) then
		RGBs<=color_plataforma; --Pinta 2º plataforma
	elsif(unsigned(ejey) > to_unsigned(85,10) AND unsigned(ejey) < to_unsigned(110,10) AND unsigned(ejex) < to_unsigned(480,10)) then
		RGBs<=color_plataforma; --Pinta 3º plataforma
	end if;
	
	--Condiciones para pintar cada escalera
	-- Se ha situado cada escalera en el borde de cada plataforma, con un grosor de 115 píxeles
	if(unsigned(ejey) > to_unsigned(315,10) AND unsigned(ejey) <= to_unsigned(430,10) AND unsigned(ejex) < to_unsigned(480,10)  AND unsigned(ejex) >= to_unsigned(432,10)) then
		RGBe<=color_escalera; --Pinta 1º escalera
	elsif(unsigned(ejey) > to_unsigned(200,10) AND unsigned(ejey) <= to_unsigned(315,10) AND unsigned(ejex) <= to_unsigned(208,10)  AND unsigned(ejex) > to_unsigned(160,10)) then
		RGBe<=color_escalera; --Pinta 2º escalera
	elsif(unsigned(ejey) > to_unsigned(85,10) AND unsigned(ejey) <= to_unsigned(200,10) AND unsigned(ejex) < to_unsigned(480,10)  AND unsigned(ejex) >= to_unsigned(432,10)) then
		RGBe<=color_escalera; --Pinta 3º escalera
	end if;
	
end process;

end Behavioral;

