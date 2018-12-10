----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:42:15 12/10/2018 
-- Design Name: 
-- Module Name:    control - Behavioral 
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

entity control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RGBm : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR(7 downto 0);
			  sobrePlat : out  STD_LOGIC);
end control;

architecture Behavioral of control is
signal sobrePlataforma, p_sobrePlataforma: std_logic;
constant color_plataforma: STD_LOGIC_VECTOR(7 downto 0):= "11100001"; 
constant color_aviso: STD_LOGIC_VECTOR(7 downto 0):= "11111100"; --Amarillo

begin
sobrePlat<=sobrePlataforma;

comb: process(RGBm, RGBs,sobrePlataforma)
begin
	if (RGBm=color_aviso and RGBs=color_plataforma)then
		p_sobrePlataforma<='1';
		
	elsif(RGBm=color_aviso and RGBs="00000000")then
		p_sobrePlataforma<='0';
	else
		p_sobrePlataforma <= sobrePlataforma;
	end if;
	
	RGBin <= RGBs OR RGBm;
end process;

sinc: process(clk,reset)
begin
	if(reset = '1') then
		sobrePlataforma <= '0';
	elsif (rising_edge(clk)) then
		sobrePlataforma <= p_sobrePlataforma;
	end if;
end process;


end Behavioral;

