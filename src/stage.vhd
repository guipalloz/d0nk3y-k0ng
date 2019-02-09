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

-- Descripci�n de la entidad: Declaraci�n de puertos del bloque Stage
-- ejex, ejey: Se�ales de entrada que indican la posici�n del p�xel que se va a generar
-- RGBs: Se�al de salida correspondiente con el color de la plataforma
-- RGBe: Se�al de salida correspondiente con el color de la escalera
-- Se necesitan dos se�ales distintas para diferenciar a la hora de activar sobrePlat y sobreEsc a la vez,
---- es decir, distinguir cuando Mario est� tanto en una plataforma como en una escalera
entity stage is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           RGBs : out  STD_LOGIC_VECTOR(7 downto 0);
			  RGBe : out  STD_LOGIC_VECTOR(7 downto 0));
end stage;
	
-- Descripci�n de la arquitectura
architecture Behavioral of stage is
-- Definici�n de las constantes correspondientes con los colores de las plataformas y las escaleras
constant color_plataforma: STD_LOGIC_VECTOR(7 downto 0):= "11000011";
constant color_escalera: STD_LOGIC_VECTOR(7 downto 0):= "00011011";
begin

-- Proceso combinacional encargado de indicar el color que se mostrar� para las se�ales de las plataformas y escaleras
repr: process(ejex,ejey)
	begin

	RGBs<="00000000"; -- Se pinta el color del fondo negro en ambas se�ales
	RGBe<="00000000";
	
	-- Condiciones para pintar cada plataforma:
	-- Los valores de la posici�n de las plataformas se ha elegido para que est�n aproximadamente equiespaciadas en el eje vertical.
	-- Respecto al eje x, se han definido de forma que el suelo ocupe todo el eje x, que la 1� y 3� plataforma empiecen desde la
	---- izquierda y la 2� por la derecha, con un espacio sin que llegue a ocupar todo el eje x
	-- Respecto al eje y, el suelo se pinta a partir del p�xel 430, por lo que tendr� 50 pixeles de grosor, mientras que las
	---- plataformas tendr�n un grosor de 25 p�xeles
	if(unsigned(ejey) > to_unsigned(430,10)) then
		RGBs<=color_plataforma; -- Pinta la plataforma m�s inferior correspondiente al suelo
	elsif(unsigned(ejey) > to_unsigned(315,10) AND unsigned(ejey) < to_unsigned(340,10) AND unsigned(ejex) < to_unsigned(480,10)) then
		RGBs<=color_plataforma; --Pinta 1� plataforma
	elsif(unsigned(ejey) > to_unsigned(200,10) AND unsigned(ejey) < to_unsigned(225,10) AND unsigned(ejex) > to_unsigned(160,10)) then
		RGBs<=color_plataforma; --Pinta 2� plataforma
	elsif(unsigned(ejey) > to_unsigned(85,10) AND unsigned(ejey) < to_unsigned(110,10) AND unsigned(ejex) < to_unsigned(480,10)) then
		RGBs<=color_plataforma; --Pinta 3� plataforma
	end if;
	
	--Condiciones para pintar cada escalera
	-- Se ha situado cada escalera en el borde de cada plataforma, con un grosor de 115 p�xeles
	if(unsigned(ejey) > to_unsigned(315,10) AND unsigned(ejey) <= to_unsigned(430,10) AND unsigned(ejex) < to_unsigned(480,10)  AND unsigned(ejex) >= to_unsigned(432,10)) then
		RGBe<=color_escalera; --Pinta 1� escalera
	elsif(unsigned(ejey) > to_unsigned(200,10) AND unsigned(ejey) <= to_unsigned(315,10) AND unsigned(ejex) <= to_unsigned(208,10)  AND unsigned(ejex) > to_unsigned(160,10)) then
		RGBe<=color_escalera; --Pinta 2� escalera
	elsif(unsigned(ejey) > to_unsigned(85,10) AND unsigned(ejey) <= to_unsigned(200,10) AND unsigned(ejex) < to_unsigned(480,10)  AND unsigned(ejex) >= to_unsigned(432,10)) then
		RGBe<=color_escalera; --Pinta 3� escalera
	end if;
	
end process;

end Behavioral;

