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

entity comparador is
	Generic (Nbit: integer :=8;
	End_Of_Screen: integer :=10;
	Start_Of_Pulse: integer :=20;
	End_Of_Pulse: integer :=30;
	End_Of_Line: integer :=40);
	Port (clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			data : in STD_LOGIC_VECTOR (Nbit-1 downto 0);
			
			O1 : out STD_LOGIC;
			O2 : out STD_LOGIC;
			O3 : out STD_LOGIC);
end comparador;

architecture Behavioral of comparador is
signal pO1,pO2,pO3 : std_logic;
signal data_in : unsigned(Nbit-1 downto 0);

begin
data_in <= unsigned(data);

-- Proceso sí­ncrono
sinc: process(clk, reset)
begin
	if (reset = '1') then
		O1 <= '0';
		O2	<= '1';
		O3	<= '0';
	elsif (rising_edge(clk)) then
		O1 <= pO1;
		O2 <= pO2;
		O3 <= pO3;
	end if;
end process;

-- Proceso combinacional		
comb : process(data_in)
begin
	if (data_in > End_Of_Screen) then
		pO1 <= '1';
	else
		pO1 <= '0';
	end if;
		
	if (data_in > Start_Of_Pulse AND data_in < End_Of_Pulse) then
		pO2 <= '0';
	else
		pO2 <= '1';
	end if;
		
	if (data_in = End_Of_Line) then
		pO3 <= '1';
	else
		pO3 <= '0';
	end if;
end process;

end Behavioral;

