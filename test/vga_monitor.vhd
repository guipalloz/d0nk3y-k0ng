----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Fernando Muñoz Chavero
-- 
-- Create Date:    13:35:57 12/11/2018 
-- Design Name: vga_monitor
-- Module Name:    vga_monitor - Behavioral 
-- Description: Block for simulation of a 640x480 VGA driver. It will save into a file called "vga_output.csv" the ouputs of an VGA driver in order to be processed by python (3) script "show_screen.py"
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use ieee.std_logic_textio.all;
use std.textio.all;


entity vga_monitor is
	generic (
		NR: integer := 3; -- Number of bits of red bus
		NG: integer := 3; -- Number of bits of green bus
		NB: integer := 2 ); -- Number of bits of blue bus
    Port (
    	clk : in  STD_LOGIC; -- Clock
  		hs : in  STD_LOGIC; -- Horizontal Sync. Active low. 
        vs : in  STD_LOGIC; -- Vertical Sync. Active low.
        R : in  STD_LOGIC_VECTOR (NR-1 downto 0); -- red
        G : in  STD_LOGIC_VECTOR (NG-1 downto 0); -- green
        B : in  STD_LOGIC_VECTOR (NB-1 downto 0)); -- blue
end vga_monitor;

architecture sim_behavior of vga_monitor is

begin

process (clk)
	file f: text is out "vga_output.csv";
	variable line_var: line;
	variable color: integer;
begin
	if (rising_edge(clk)) then		
        write(line_var, hs); -- Writing HS
       	write(line_var, "; ");
        write(line_var, vs);  -- Writing VS
        write(line_var, "; ");
        color := to_integer(unsigned(R)) * 255/(2**NR - 1); -- Converting Red into an 0-255 value
        write(line_var, color); -- Red
        write(line_var, "; ");
        color := to_integer(unsigned(G)) * 255/(2**NG - 1);
        write(line_var, color); -- Green
        write(line_var, "; ");
        color := to_integer(unsigned(B)) * 255/(2**NB - 1);
        write(line_var, color); -- Blue
        writeline(f,(line_var));
    end if;
end process;

end sim_behavior;

