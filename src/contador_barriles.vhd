----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:54 12/20/2018 
-- Design Name: 
-- Module Name:    contador_barriles - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity contador_barriles is
    Port ( clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
			  resets : in STD_LOGIC;
			  aparece : out  STD_LOGIC_VECTOR (2 downto 0));
end contador_barriles;

architecture Behavioral of contador_barriles is

signal cuenta, p_cuenta: unsigned (25 downto 0);
signal Q, p_Q : unsigned (2 downto 0);
CONSTANT nsat : integer := 50000000;

 
begin
sinc: process(clk,reset)
begin
-- OJO, queremos una memoria de forma controlada, quiero generar un biestable aposta y por tanto no me generará un LATCH indeseado. 
-- Generará un biestable para conservar su valor.
	if(reset = '1') then
		cuenta <= (others => '0');
		Q <= (others => '0');
	elsif (rising_edge(clk)) then
		cuenta <= p_cuenta;
		Q <= p_Q;
	end if;
	
end process;

-- Proceso combinacional, actualiza el valor de cuenta.
-- in: p_cuenta
-- out: cuenta
comb: process(cuenta, Q, resets)
begin
	if resets = '1' then
		p_cuenta <= (others => '0');
		p_Q <= (others => '0');
	else
		if(cuenta = nsat) then
			p_cuenta <= (others =>'0');
			p_Q <= Q+1;
		else
			p_cuenta <= cuenta + 1;
			p_Q <= Q;
		end if;
	end if;
end process;

aparece <= std_logic_vector(Q);

end Behavioral;

