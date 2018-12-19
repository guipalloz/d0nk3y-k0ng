----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:56:43 12/05/2018 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
    Port ( RGBout : out  STD_LOGIC_VECTOR(7 downto 0);
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           left : in  STD_LOGIC;
           right : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           jump : in  STD_LOGIC;
			  aparece : in STD_LOGIC);
end main;

architecture Behavioral of main is

signal s_ejex, s_ejey: STD_LOGIC_VECTOR(9 downto 0);
signal s_RGBm, s_RGBs, s_RGBb, s_RGB: STD_LOGIC_VECTOR(7 downto 0);
signal s_refresh, s_sobrePlatM, s_sobrePlatB: STD_LOGIC;

component DriverVGA is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  RGBin : in  STD_LOGIC_VECTOR(7 downto 0);
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
			  refresh : out STD_LOGIC;
			  ejex, ejey : out STD_LOGIC_VECTOR(9 downto 0 );
           RGBout : out  STD_LOGIC_VECTOR(7 downto 0));
end component;

component Mario is
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
           jump : in  STD_LOGIC;
			  sobrePlat : in STD_LOGIC);
end component;

component barril is
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           sobrePlat_barril : in  STD_LOGIC;
           aparece : in  STD_LOGIC;
			  refresh : in STD_LOGIC;
           RGBb : out  STD_LOGIC_VECTOR(7 downto 0));
end component;

component stage is
    Port ( ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           RGBs : out  STD_LOGIC_VECTOR(7 downto 0));
end component;

component control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           RGBm : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBs : in  STD_LOGIC_VECTOR(7 downto 0);
			  RGBb : in  STD_LOGIC_VECTOR(7 downto 0);
           RGBin : out  STD_LOGIC_VECTOR(7 downto 0);
			  sobrePlat_mario : out  STD_LOGIC;
			  sobrePlat_barril : out  STD_LOGIC);
end component;
begin

MiBarril : barril
	Port MAP( clk => clk,
				 reset => reset,
				 ejex => s_ejex,
				 ejey => s_ejey,
				 sobrePlat_barril => s_sobrePlatB,
				 refresh => s_refresh,
				 aparece => aparece,
				 RGBb=> s_RGBb);
				 
MiMario: Mario
	Port MAP( ejex => s_ejex,
				 ejey => s_ejey,
				 refresh => s_refresh,
				 RGBm=> s_RGBm,
				 reset => reset,
				 clk => clk,
				 left => left,
				 right => right,
				 up => up,
				 down => down,
				 jump => jump,
				 sobrePlat => s_sobrePlatM);
VGA: DriverVGA
    Port MAP( clk => clk,
           reset => reset,
			  RGBin => s_RGB,
			  HS => HS,
			  VS => VS,
			  refresh => s_refresh,
			  ejex => s_ejex,
			  ejey=>	s_ejey,
			  RGBout => RGBout);
MiStage: stage
	Port MAP( ejex => s_ejex,
				 ejey => s_ejey,
				 RGBs => s_RGBs);
MiControl: control
	Port MAP(clk => clk,
				reset => reset,
				RGBm => s_RGBm,
				RGBb => s_RGBb,
				RGBs => s_RGBs,
				RGBin => s_RGB,
				sobrePlat_mario => s_sobrePlatM,
				sobrePlat_barril => s_sobrePlatB);
end Behavioral;

