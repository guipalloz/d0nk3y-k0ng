----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:30:26 11/13/2018 
-- Design Name: 
-- Module Name:    DriverVGA - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DriverVGA is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGBin : in  STD_LOGIC_VECTOR(7 downto 0);
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
			  refresh : out STD_LOGIC;
			  ejex, ejey : out STD_LOGIC_VECTOR(9 downto 0 );
           RGBout : out  STD_LOGIC_VECTOR(7 downto 0));
end DriverVGA;

architecture Behavioral of DriverVGA is

component contador is
    Generic (Nbit: INTEGER := 8);
	 Port ( enable : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  resets : in STD_LOGIC;
			  Q : out STD_LOGIC_VECTOR (Nbit-1 downto 0));
			  
end component;

component comparador is
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
end component;

signal clk_pixel, pclk_pixel, resets1O, resets2O, Blank_h, Blank_v, enable2 : STD_LOGIC;
signal Qx, Qy : STD_LOGIC_VECTOR (9 downto 0);
--signal RGB : STD_LOGIC_VECTOR (7 downto 0);
begin

ejex <= Qx;
ejey <= Qy;
refresh <= resets1O;

enable2 <= resets1O AND clk_pixel;
-- Bloque frec_pixel, directamente disenado en el nivel de jerarquia superior

pclk_pixel <= not clk_pixel;

div_frec: process(clk, reset)
begin
	if(reset='1') then
		clk_pixel <= '0';
	elsif (rising_edge(clk)) then
		clk_pixel <= pclk_pixel;
	end if;
end process;

-- Bloque frec_pixel, directamente disenado en el nivel de jerarquia superior

gen_color: process(Blank_H, Blank_V, RGBin)
begin
	if (Blank_H ='1' or Blank_V = '1') then
		RGBout <= (others => '0');
	else
		RGBout <= RGBin;
	end if;
end process;

-- Ahora instanciamos los componentes de jerarquia superior
			  
contadorh: contador
	GENERIC MAP (Nbit => 10)
	PORT MAP(
		enable => clk_pixel,
		clk => clk,
		reset => reset,
		Q => Qx,
		resets => resets1O);
		
contadorv: contador
	GENERIC MAP (Nbit => 10)
	PORT MAP(
		enable => enable2,
		clk => clk,
		reset => reset,
		Q => Qy,
		resets => resets2O);
		
comph: comparador
	Generic MAP (
		Nbit => 10,
		End_Of_Screen => 639,
		Start_Of_Pulse => 655,
		End_Of_Pulse => 751,
		End_Of_Line => 799)
	Port MAP (clk => clk,
			reset => reset,
			data => Qx,
			O1 => Blank_H,
			O2 => HS,
			O3 => resets1O);
			
compv: comparador
	Generic MAP (
		Nbit => 10,
		End_Of_Screen => 479,
		Start_Of_Pulse => 489,
		End_Of_Pulse => 491,
		End_Of_Line => 520)
	Port MAP (clk => clk,
			reset => reset,
			data => Qy,
			O1 => Blank_V,
			O2 => VS,
			O3 => resets2O);


		
end Behavioral;

