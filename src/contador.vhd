--------------------------------------------------------------------
--	Trabajo Donkey Kong - Complementos de Electr�nica	 				--
--	M�ster Universitario en Ingenier��a de Telecomunicaci�n 		 	--
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

entity contador is
    Generic (Nbit: INTEGER := 8);
	 Port ( enable : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  resets : in STD_LOGIC;
			  Q : out STD_LOGIC_VECTOR (Nbit-1 downto 0));
			  
end contador;

architecture Behavioral of contador is
SIGNAL pcuenta, cuenta : unsigned (Nbit-1 downto 0);
 
begin

-- Proceso s��ncrono, almacena el valor de la cuenta
-- in: p_cuenta
-- out: cuenta

sinc: process(clk,reset)
begin
	if(reset = '1') then
		cuenta <= (others => '0');
	elsif (rising_edge(clk)) then
		cuenta <= pcuenta;
	end if;
	
end process;

-- Proceso combinacional, actualiza el valor de cuenta.
-- in: p_cuenta
-- out: cuenta

comb: process(cuenta,enable,resets)
begin
	if(resets = '1') then
		pcuenta <= (others => '0');
	elsif(enable = '1' ) then
		pcuenta <= cuenta + 1;
	else
		pcuenta <= cuenta;
	end if;
end process;

Q <= std_logic_vector(cuenta);

end Behavioral;

