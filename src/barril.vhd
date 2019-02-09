----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:41:07 12/19/2018 
-- Design Name: 
-- Module Name:    barril - Behavioral 
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

entity barril is
    Port ( clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  ejex : in  STD_LOGIC_VECTOR(9 downto 0);
           ejey : in  STD_LOGIC_VECTOR(9 downto 0);
           sobrePlatB : in  STD_LOGIC;
           aparece : in  STD_LOGIC;
			  refresh : in STD_LOGIC;
           RGBb : out  STD_LOGIC_VECTOR(7 downto 0);
			  resets : in STD_LOGIC);
end barril;

architecture Behavioral of barril is
signal p_posx, p_posy, posx, posy, ejex_aux, ejey_aux : unsigned(9 downto 0);
constant VELX : unsigned(4 downto 0):= to_unsigned(5,5);
constant ACEL : unsigned(4 downto 0):= to_unsigned(1,5);
constant suelo : unsigned (9 downto 0) := to_unsigned(431,10);
signal vely,p_vely: unsigned(4 downto 0);
signal p_sentido, sentido, restart,p_restart: STD_LOGIC; --Si 0, se mueve a la izq, si 1 a derecha

type estado is (WAITING, FALLING, POS_UPDATE, VEL_UPDATE);
signal state, p_state:estado;

--Señales para la memoria
signal s_addr : STD_LOGIC_VECTOR(8 downto 0);
--signal reverse : STD_LOGIC_VECTOR(9 downto 0);
signal s_data : STD_LOGIC_VECTOR(2 downto 0);

constant MAX_VELY:unsigned(4 downto 0):=to_unsigned(25,5);
COMPONENT barrilROM
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;


begin

mibarril : barrilROM
  PORT MAP (
    clka => clk,
    addra => s_addr,
    douta => s_data
  );

sinc: process(clk,reset)
begin
	if(reset = '1') then
		posx <= to_unsigned(1008,10);
		posy <= to_unsigned(0,10);
		vely <= (others => '0');
		state <= WAITING;
		sentido<='1';
		restart <= '0';
	elsif(rising_edge(clk)) then
		posx <= p_posx;
		posy <= p_posy;
		vely <= p_vely;
		state <= p_state;
		sentido <= p_sentido;
		restart <= p_restart;
	end if;
end process;

comb: process(ejex,ejey, posx, posy, vely, ejey_aux, ejex_aux, s_data,resets, refresh)
begin
	--if (vely = to_unsigned(0,5)) then
	 -- Sprite del barril 1 (rodando)
	-- else
	--	s_addr(10) <= '1'; -- Sprite del barril 2 (cayendo)
	--end if;
	if (vely > 2) then
		s_addr(8) <= '1';
		s_addr(7 downto 4) <= std_logic_vector(ejey_aux(3 downto 0));
		s_addr(3 downto 0) <= std_logic_vector(ejex_aux(3 downto 0));
	else
		s_addr(8) <='0';
		s_addr(7 downto 4) <= std_logic_vector(ejey_aux(3 downto 0));
		s_addr(3 downto 0) <= std_logic_vector(ejex_aux(3 downto 0));
	end if;
	ejex_aux <= unsigned(ejex)-posx;
	ejey_aux <= unsigned(ejey)-posy;
	
	if((unsigned(ejex) >= posx) AND (unsigned(ejex) < (posx + 16)) AND (unsigned(ejey) >= posy) AND (unsigned(ejey) < posy + 16)) then
		RGBb<= s_data(2) & s_data(2) & s_data(2) & s_data(1) & s_data(1) & s_data(1) & s_data(0) & s_data(0);
	else
		RGBb<="00000000"; --Pinta de negro
	end if;
	
	if((unsigned(ejex) = posx +8) AND (unsigned(ejey) = (posy + 16))) then
		RGBb<="10001000"; --Pintamos un único punto amarillo en el medio del cuadrado
	end if;
end process;


maquina_estado: process(restart,refresh,posx, posy, vely, state, sentido, aparece, sobrePlatB, resets)
begin
	if (resets = '1' OR restart = '1') then
		p_posx <= to_unsigned(1008,10);
		p_posy <= to_unsigned(0,10);
		p_vely <= (others => '0');
		p_state <= WAITING;
		p_sentido<='1';
		p_restart <= '0';
	else
		p_state<=state;
		p_posx<=posx;
		p_posy<=posy;
		p_vely<= vely;
		p_sentido<=sentido;
		p_restart <= restart;
		case state is
			when WAITING =>
				if aparece='1' then
					p_state <= FALLING;
					p_posx <= to_unsigned(0,10);
					p_posy <= to_unsigned(0,10);
					p_sentido  <= '1';
				else
					p_state <= WAITING;
				end if;
			when FALLING =>
				if (refresh ='1') then
					p_state<=POS_UPDATE;
				elsif ((posy + 15 = suelo) AND (posx < VELX)) then
					p_restart <= '1';
					p_state <= WAITING;
				else
					p_state<=FALLING;
				end if;
				
			when POS_UPDATE =>
				p_state<=VEL_UPDATE;
				if (sentido ='0') then
					if (posx < VELX) then
						p_posx<=posx+VELX;
						p_sentido <= '1';
					else
						p_posx<=posx-VELX;
					end if;
				else
					if (posx + 16 > to_unsigned(639,10)) then
						p_posx <= posx-VELX;
						p_sentido <= '0';
					else
						p_posx <= posx+VELX;
					end if;
				end if;			
				
				if(sobrePlatB ='0') then
					p_posy <= posy + vely;
				else
					p_posy <= posy-1; -- Me salgo de la plataforma
				end if;
				
			when VEL_UPDATE =>
				p_state <= FALLING;
				if sobrePlatB = '0' then
					if (vely<MAX_VELY) then
						p_vely<=vely+ACEL;
					else
						p_vely<=vely;
					end if;
				else 
					p_vely <= (others => '0');
				end if;
		end case;
	end if;
end process;

end Behavioral;
