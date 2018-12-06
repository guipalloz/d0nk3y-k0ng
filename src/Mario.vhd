----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:30:52 12/05/2018 
-- Design Name: 
-- Module Name:    Mario - Behavioral 
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

entity Mario is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           refresh : in  STD_LOGIC;
           RGBm : out  STD_LOGIC_VECTOR(7 downto 0);
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           left : in STD_LOGIC;
           right : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC);
end Mario;

architecture Behavioral of Mario is
signal p_posx, p_posy, posx, posy : unsigned(9 downto 0);

begin

sinc: process(clk,reset)
begin
	if(reset = '1') then
		posx <= to_unsigned(150,10);
		posy <= to_unsigned(320,10);
	elsif(rising_edge(clk)) then
		posx <= p_posx;
		posy <= p_posy;
	end if;
end process;
		p_posx <= posx; -- cambiara en un futuro
		p_posy <= posy; -- cambiara en un futuro
repr: process(ejex,ejey, posx, posy)
	begin

	if(posx>=unsigned(ejex) AND posx<unsigned(ejex)+32 AND posy>=unsigned(ejey) AND posy < unsigned(ejey)+32) then
		RGBm<="11100000"; --Pinta de rojo

	else
		RGBm<="00000000"; --Pinta de negro
	end if;
end process;

end Behavioral;

