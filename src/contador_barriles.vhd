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

-- Elemento encargado de la generación de los barriles permitiendo que los barriles salgan con diferentes distancias entre sí.

-- Puertos de interés:

-- aparece. Señal de salida de 3 bits que habilita la generación de un barril. Cada bit habilita la generación de un barril diferente
entity contador_barriles is
    Port ( clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
			  resets : in STD_LOGIC;
			  aparece : out  STD_LOGIC_VECTOR (2 downto 0));
end contador_barriles;

architecture Behavioral of contador_barriles is
	
-- Declaración de las constantes utilizadas en este bloque

-- Número entero que marcará la saturación del contador
CONSTANT nsat : integer := 50000000;

-- Señales para garantizar el funcionamiento correcto del proceso síncrono

-- Q. Unsigned de 3 bits donde cada bit se asociará a cada uno de los barriles. El funcionamiento es el siguiente:

--	Bit a '1' en la posición i: Habilita la aparición del barril i.
--	Bit a '0' en la posición i: No habilita la aparición del barril i.

signal cuenta, p_cuenta: unsigned (25 downto 0);
signal Q, p_Q : unsigned (2 downto 0);


 
begin
	
-- Proceso encargado de garantizar la sincronía. Bajo la estructura seguida durante toda la asignatura.
sinc: process(clk,reset)
begin
-- OJO, queremos una memoria de forma controlada, quiero generar un biestable aposta y por tanto no me generará un LATCH indeseado. 
-- Generará un biestable para conservar su valor.
	if(reset = '1') then
		-- Valores iniciales tras reset
		cuenta <= (others => '0');
		Q <= (others => '0');
	elsif (rising_edge(clk)) then
		-- Actualizamos valores tras flanco de subida del reloj
		cuenta <= p_cuenta;
		Q <= p_Q;
	end if;
	
end process;

-- Proceso combinacional, actualiza el valor de cuenta.
comb: process(cuenta, Q, resets)
begin
	if resets = '1' then
		-- Si hay reset síncrono fijo valores iniciales
		p_cuenta <= (others => '0');
		p_Q <= (others => '0');
	else
		if(cuenta = nsat) then
			-- Cuando la cuenta llega al nivel de saturación.
			p_cuenta <= (others =>'0'); -- Reiniciamos la cuenta
			p_Q <= Q+1; -- Aumentamos en 1 unidad el valor de Q
		else
			-- Si no he llegado al nivel de saturación
			p_cuenta <= cuenta + 1; -- Aumento el valor de cuenta
			p_Q <= Q; -- No modifico el valor de Q
		end if;
	end if;
end process;

aparece <= std_logic_vector(Q); -- Conversión a std_logic_vector

end Behavioral;

