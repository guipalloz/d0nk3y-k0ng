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
           RGBb1 : in  STD_LOGIC_VECTOR(7 downto 0);
			  RGBb2 : in  STD_LOGIC_VECTOR(7 downto 0);
			  RGBb3 : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBe : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR(7 downto 0);
			  sobrePlatM : out  STD_LOGIC;
			  sobrePlatB1 : out  STD_LOGIC;
			  sobrePlatB2 : out  STD_LOGIC;
			  sobrePlatB3 : out  STD_LOGIC;
			  sobreEsc : out STD_LOGIC;
			  gameover : out STD_LOGIC);
end control;

architecture Behavioral of control is
signal sobrePlataforma_mario, p_sobrePlataforma_mario: std_logic;
signal sobreEscalera, p_sobreEscalera: std_logic;
signal sobrePlataforma_barril1, p_sobrePlataforma_barril1: std_logic;
signal sobrePlataforma_barril2, p_sobrePlataforma_barril2: std_logic;
signal sobrePlataforma_barril3, p_sobrePlataforma_barril3: std_logic;
constant color_plataforma: STD_LOGIC_VECTOR(7 downto 0):= "11000011"; 
constant color_aviso_mario: STD_LOGIC_VECTOR(7 downto 0):= "11100001";
constant color_mario: STD_LOGIC_VECTOR(7 downto 0):= "11100000";
constant color_barril: STD_LOGIC_VECTOR(7 downto 0):= "11100000";
constant color_escalera: STD_LOGIC_VECTOR(7 downto 0):= "00011011";


begin
sobrePlatM<=sobrePlataforma_mario;
sobrePlatB1<=sobrePlataforma_barril1;
sobrePlatB2<=sobrePlataforma_barril2;
sobrePlatB3<=sobrePlataforma_barril3;
sobreEsc<= sobreEscalera;

comb: process(RGBm, RGBb1, RGBb2, RGBb3, RGBe, sobrePlataforma_barril1, sobrePlataforma_barril2, sobrePlataforma_barril3, RGBs,sobrePlataforma_mario, sobreEscalera)
begin
	-- Control de Mario sobre plataforma
	if (RGBm=color_aviso_mario and RGBs=color_plataforma)then
		p_sobrePlataforma_mario<='1';
	elsif(RGBm=color_aviso_mario and RGBs="00000000")then
		p_sobrePlataforma_mario<='0';
	else
		p_sobrePlataforma_mario <= sobrePlataforma_mario;
	end if;


	-- Control de barril sobre plataforma
	if (RGBb1=color_barril and RGBs=color_plataforma)then
		p_sobrePlataforma_barril1<='1';
	elsif(RGBb1=color_barril and RGBs="00000000")then
		p_sobrePlataforma_barril1<='0';
	else
		p_sobrePlataforma_barril1 <= sobrePlataforma_barril1;
	end if;
	
	if (RGBb2=color_barril and RGBs=color_plataforma)then
		p_sobrePlataforma_barril2<='1';
	elsif(RGBb2=color_barril and RGBs="00000000")then
		p_sobrePlataforma_barril2<='0';
	else
		p_sobrePlataforma_barril2 <= sobrePlataforma_barril2;
	end if;
	
	if (RGBb3=color_barril and RGBs=color_plataforma)then
		p_sobrePlataforma_barril3<='1';
	elsif(RGBb3=color_barril and RGBs="00000000")then
		p_sobrePlataforma_barril3<='0';
	else
		p_sobrePlataforma_barril3 <= sobrePlataforma_barril3;
	end if;
	
	-- Control de muerte
	if ((RGBb1=color_barril OR RGBb2=color_barril OR RGBb3=color_barril) and RGBm=color_mario)then
		gameover <= '1';
	else
		gameover <= '0';
	end if;
	
	-- Control de Mario sobre escalera
	if (RGBm=color_aviso_mario and RGBe=color_escalera)then
		p_sobreEscalera<='1';
	elsif(RGBm=color_aviso_mario and (RGBe="00000000" or RGBs=color_plataforma))then
		p_sobreEscalera<='0';
	else
		p_sobreEscalera <= sobreEscalera;
	end if;
	
	-- Determinamos el color que finalmente sale a la pantalla, priorizando algunas señales frente a otras
	
	if (RGBm /= "00000000") then
		RGBin <= RGBm;
	elsif ((RGBb1 /= "00000000") OR (RGBb2 /= "00000000") OR (RGBb3 /= "00000000")) then
		RGBin <= RGBb1 OR RGBb2 OR RGBb3;
	elsif (RGBs /= "00000000") then
		RGBin <= RGBs;
	elsif (RGBe /= "00000000") then
		RGBin <= RGBe;
	else
		RGBin <= "00000000";
	end if;
-- Preferencias: Mario > Barriles > plataforma > Escaleras
	
--		RGBin <= RGBs OR RGBm OR RGBb1 OR RGBb2 OR RGBb3 OR RGBe;
--	if ((RGBm /= "00000000" and RGBe=color_escalera) or (RGBm /= "00000000" and RGBs = color_plataforma)) then
--		RGBin<=color_mario;
--	elsif ((RGBb1=color_barril OR RGBb2=color_barril OR RGBb3=color_barril) and RGBe=color_escalera) then
--		RGBin <= color_barril;
--	elsif (RGBs=color_plataforma and RGBe=color_escalera) then
--		RGBin <= color_plataforma;
--	end if;
	
end process;

sinc: process(clk,reset)
begin
	if(reset = '1') then
		sobrePlataforma_mario <= '0';
		sobrePlataforma_barril1 <= '0';
		sobrePlataforma_barril2 <= '0';
		sobrePlataforma_barril3 <= '0';
		sobreEscalera <= '0';
	elsif (rising_edge(clk)) then
		sobrePlataforma_mario <= p_sobrePlataforma_mario;
		sobrePlataforma_barril1 <= p_sobrePlataforma_barril1;
		sobrePlataforma_barril2 <= p_sobrePlataforma_barril2;
		sobrePlataforma_barril3 <= p_sobrePlataforma_barril3;
		sobreEscalera <= p_sobreEscalera;
	end if;
end process;


end Behavioral;

