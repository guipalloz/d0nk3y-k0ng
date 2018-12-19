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
           RGBb : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR(7 downto 0);
			  sobrePlat_mario : out  STD_LOGIC;
			  sobrePlat_barril : out  STD_LOGIC);
end control;

architecture Behavioral of control is
signal sobrePlataforma_mario, p_sobrePlataforma_mario: std_logic;
signal sobrePlataforma_barril, p_sobrePlataforma_barril: std_logic;
constant color_plataforma: STD_LOGIC_VECTOR(7 downto 0):= "11000011"; 
constant color_aviso_mario: STD_LOGIC_VECTOR(7 downto 0):= "11100001"; 
constant color_aviso_barril: STD_LOGIC_VECTOR(7 downto 0):= "10101101"; 


begin
sobrePlat_mario<=sobrePlataforma_mario;
sobrePlat_barril<=sobrePlataforma_barril;

comb: process(RGBm, RGBb, sobrePlataforma_barril, RGBs,sobrePlataforma_mario)
begin
	if (RGBm=color_aviso_mario and RGBs=color_plataforma)then
		p_sobrePlataforma_mario<='1';
	elsif(RGBm=color_aviso_mario and RGBs="00000000")then
		p_sobrePlataforma_mario<='0';
	else
		p_sobrePlataforma_mario <= sobrePlataforma_mario;
	end if;
	
	--RGBin <= RGBs OR RGBm;

	if (RGBb=color_aviso_barril and RGBs=color_plataforma)then
		p_sobrePlataforma_barril<='1';
	elsif(RGBb=color_aviso_barril and RGBs="00000000")then
		p_sobrePlataforma_barril<='0';
	else
		p_sobrePlataforma_barril <= sobrePlataforma_barril;
	end if;
	
	RGBin <= RGBs OR RGBm OR RGBb;		
end process;

sinc: process(clk,reset)
begin
	if(reset = '1') then
		sobrePlataforma_mario <= '0';
		sobrePlataforma_barril <= '0';
	elsif (rising_edge(clk)) then
		sobrePlataforma_mario <= p_sobrePlataforma_mario;
		sobrePlataforma_barril <= p_sobrePlataforma_barril;
	end if;
end process;


end Behavioral;

