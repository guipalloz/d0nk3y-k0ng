--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:36:01 12/06/2018
-- Design Name:   
-- Module Name:   D:/US/Master/1/Complementos de Electronica/DonkeyKong/tb_main.vhd
-- Project Name:  DonkeyKong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY tb_main IS
END tb_main;
 
ARCHITECTURE behavior OF tb_main IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         RGBout : OUT  std_logic_vector(7 downto 0);
         HS : OUT  std_logic;
         VS : OUT  std_logic;
         reset : IN  std_logic;
         clk : IN  std_logic;
         left : IN  std_logic;
         right : IN  std_logic;
         up : IN  std_logic;
         down : IN  std_logic;
         jump : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';
   signal left : std_logic := '0';
   signal right : std_logic := '0';
   signal up : std_logic := '0';
   signal down : std_logic := '0';
   signal jump : std_logic := '0';

 	--Outputs
   signal RGBout : std_logic_vector(7 downto 0);
   signal HS : std_logic;
   signal VS : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          RGBout => RGBout,
          HS => HS,
          VS => VS,
          reset => reset,
          clk => clk,
          left => left,
          right => right,
          up => up,
          down => down,
          jump => jump
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';


      -- insert stimulus here 

      wait;
   end process;
	
	VGA: process (clk)
    file file_pointer: text is out "AAwrite.txt";
    variable line_el: line;
	begin

    if rising_edge(clk) then

        -- Write the time
        write(line_el, now); -- write the line.
        write(line_el, ":"); -- write the line.

        -- Write the hsync
        write(line_el, " ");
        write(line_el, HS); -- write the line.

        -- Write the vsync
        write(line_el, " ");
        write(line_el, VS); -- write the line.

        -- Write the red
        write(line_el, " ");
        write(line_el, RGBout(7 downto 5)); -- write the line.

        -- Write the green
        write(line_el, " ");
        write(line_el, RGBout(4 downto 2)); -- write the line.

        -- Write the blue
        write(line_el, " ");
        write(line_el, RGBout(1 downto 0)); -- write the line.

        writeline(file_pointer, line_el); -- write the contents into the file.

    end if;
	end process;


END;
