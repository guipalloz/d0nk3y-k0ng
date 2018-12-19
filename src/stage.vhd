----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:39:07 12/10/2018 
-- Design Name: 
-- Module Name:    stage - Behavioral 
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

entity stage is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           RGBs : out  STD_LOGIC_VECTOR(7 downto 0));
end stage;
architecture Behavioral of stage is

begin

repr: process(ejex,ejey)
	begin
-- Pintamos el suelo
	RGBs<="00000000"; --Pinta suelo
	if(unsigned(ejey) > to_unsigned(430,10)) then
		RGBs<="11100010"; --Pinta suelo

	elsif(unsigned(ejey) > to_unsigned(315,10) AND unsigned(ejey) < to_unsigned(340,10) AND unsigned(ejex) < to_unsigned(480,10)) then
		RGBs<="11100010"; --Pinta 1� plataforma
	elsif(unsigned(ejey) > to_unsigned(200,10) AND unsigned(ejey) < to_unsigned(225,10) AND unsigned(ejex) > to_unsigned(160,10)) then
		RGBs<="11100010"; --Pinta 2� plataforma
	elsif(unsigned(ejey) > to_unsigned(85,10) AND unsigned(ejey) < to_unsigned(110,10) AND unsigned(ejex) < to_unsigned(480,10)) then
		RGBs<="11100010"; --Pinta 3� plataforma
	end if;
end process;



end Behavioral;

