----------------------------------------------------------------------------------
-- Course: VUT FIT - IVH - Summer Semester 2016
-- Student: Martin Cagaš - xcagas01
-- 
-- Create Date:    13:13:43 01-04-2016 
-- Design Name:    3 digit BCD up-counter
-- Module Name:    bcd - Behavioral 
-- Project Name:   Lights Out for FITkit FPGA
--
-- Revision:
-- Revision 0.1
-- Additional Comments: --
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bcd is
    Port (CLK : in  std_logic;
          RESET : in  std_logic;
          NUMBER1 : buffer  std_logic_vector (3 downto 0);
          NUMBER2 : buffer  std_logic_vector (3 downto 0);
          NUMBER3 : buffer  std_logic_vector (3 downto 0)
         );
end bcd;

architecture Behavioral of bcd is

begin

process(CLK, RESET)
begin
 if (RESET = '1') then
     NUMBER1 <= (others => '0');
     NUMBER2 <= (others => '0');
     NUMBER3 <= (others => '0');
 elsif (CLK'event) and (CLK = '1') then
   NUMBER1 <= (NUMBER1 + 1);
   if (NUMBER1 = "1001") then
       NUMBER2 <= NUMBER2 + 1;
       NUMBER1 <= (others => '0');
   end if;
   if (NUMBER2 = "1001") and (NUMBER1 = "1001") then
       NUMBER3 <= (NUMBER3 + 1);
       NUMBER2 <= (others => '0');
   end if;
   if (NUMBER3 = "1001") and (NUMBER2 = "1001") and (NUMBER1 = "1001") then
       NUMBER3 <= (others => '0');
   end if;
 end if;
end process;

end Behavioral;