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

-- Elemento encargado de la generaci�n de los barriles permitiendo que los barriles salgan con diferentes distancias entre s�.

-- Puertos de inter�s:

-- aparece. Se�al de salida de 3 bits que habilita la generaci�n de un barril. Cada bit habilita la generaci�n de un barril diferente
entity contador_barriles is
    Port ( clk : in  STD_LOGIC;
	   reset : in  STD_LOGIC;
	   resets : in STD_LOGIC;
	   aparece : out  STD_LOGIC_VECTOR (2 downto 0));
end contador_barriles;

architecture Behavioral of contador_barriles is
	
-- Declaraci�n de las constantes utilizadas en este bloque

-- N�mero entero que marcar� la saturaci�n del contador
CONSTANT nsat : integer := 50000000;

-- Se�ales para garantizar el funcionamiento correcto del proceso s�ncrono

-- Q. Unsigned de 3 bits donde cada bit se asociar� a cada uno de los barriles. El funcionamiento es el siguiente:

--	Bit a '1' en la posici�n i: Habilita la aparici�n del barril i.
--	Bit a '0' en la posici�n i: No habilita la aparici�n del barril i.

signal cuenta, p_cuenta: unsigned (25 downto 0);
signal Q, p_Q : unsigned (2 downto 0);


 
begin
	
-- Proceso encargado de garantizar la sincron�a. Bajo la estructura seguida durante toda la asignatura.
sinc: process(clk,reset)
begin
-- OJO, queremos una memoria de forma controlada, quiero generar un biestable aposta y por tanto no me generar� un LATCH indeseado. 
-- Generar� un biestable para conservar su valor.
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
		-- Si hay reset s�ncrono fijo valores iniciales
		p_cuenta <= (others => '0');
		p_Q <= (others => '0');
	else
		if(cuenta = nsat) then
			-- Cuando la cuenta llega al nivel de saturaci�n.
			p_cuenta <= (others =>'0'); -- Reiniciamos la cuenta
			p_Q <= Q+1; -- Aumentamos en 1 unidad el valor de Q
		else
			-- Si no he llegado al nivel de saturaci�n
			p_cuenta <= cuenta + 1; -- Aumento el valor de cuenta
			p_Q <= Q; -- No modifico el valor de Q
		end if;
	end if;
end process;

aparece <= std_logic_vector(Q); -- Conversi�n a std_logic_vector

end Behavioral;

