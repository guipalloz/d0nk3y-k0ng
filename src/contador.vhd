----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:51:02 10/30/2018 
-- Design Name: 
-- Module Name:    contador - Behavioral 
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

-- Proceso sincrono, almacena el valor de la cuenta
-- in: p_cuenta
-- out: cuenta

sinc: process(clk,reset)
begin
-- OJO, queremos una memoria de forma controlada, quiero generar un biestable aposta y por tanto no me generará un LATCH indeseado. 
-- Generará un biestable para conservar su valor.
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

