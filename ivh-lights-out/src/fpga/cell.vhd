----------------------------------------------------------------------------------
-- Course: VUT FIT - IVH - Summer Semester 2016
-- Student: Martin Cagaš - xcagas01
-- 
-- Create Date:    16:09:20 17-04-2016 
-- Design Name:    Lights Out Cell
-- Module Name:    cell - Behavioral 
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
use work.cell_math_pack.ALL;

entity cell is
   GENERIC (
      MASK : mask_t := (others => '1')
   );
   Port ( 
    INVERT_REQ_IN     : in   std_logic_vector (3 downto 0) := "0000";
    INVERT_REQ_OUT    : out  std_logic_vector (3 downto 0) := "0000";
      
    KEYS              : in   std_logic_vector (4 downto 0);
      
    SELECT_REQ_IN     : in   std_logic_vector (3 downto 0) := "0000";
    SELECT_REQ_OUT    : out  std_logic_vector (3 downto 0) := "0000";
      
    INIT_ACTIVE       : in   std_logic;
    ACTIVE            : out  std_logic;
      
    INIT_SELECTED     : in   std_logic;
    SELECTED          : out  std_logic;

    CLK               : in   std_logic;
    RESET             : in   std_logic
   );
end cell;

architecture Behavioral of cell is
  
begin

process(CLK, RESET)

variable SEL : std_logic;
variable ACT : std_logic;

begin
  if (RESET = '1') then
    SEL := INIT_SELECTED;
    ACT := INIT_ACTIVE;
    INVERT_REQ_OUT <= (others => '0');
    SELECT_REQ_OUT <= (others => '0');

  elsif (CLK'event) and (CLK = '1') then
    INVERT_REQ_OUT <= (others => '0');
    SELECT_REQ_OUT <= (others => '0');
     
    if (SEL = '1') then
      if (MASK.top = '1') and (KEYS(IDX_TOP) = '1') then
        SELECT_REQ_OUT(IDX_TOP) <= '1';
        SEL := '0';
      end if;

      if (MASK.left = '1') and (KEYS(IDX_LEFT) = '1') then
        SELECT_REQ_OUT(IDX_LEFT) <= '1';
        SEL := '0';
      end if;

      if (MASK.right = '1') and(KEYS(IDX_RIGHT) = '1') then
        SELECT_REQ_OUT(IDX_RIGHT) <= '1';
        SEL := '0';
      end if;

      if (MASK.bottom = '1') and(KEYS(IDX_BOTTOM) = '1') then
        SELECT_REQ_OUT(IDX_BOTTOM) <= '1';
        SEL := '0';
      end if;

      if (KEYS(IDX_ENTER) = '1') then
        if (MASK.top = '1') then
          INVERT_REQ_OUT(IDX_TOP) <= '1';
        end if;
          
        if (MASK.left = '1') then
          INVERT_REQ_OUT(IDX_LEFT) <= '1';
        end if;
          
        if (MASK.right = '1') then
          INVERT_REQ_OUT(IDX_RIGHT) <= '1';
        end if;
          
        if (MASK.bottom = '1') then
          INVERT_REQ_OUT(IDX_BOTTOM) <= '1';
        end if;

        if (ACT = '1') then
          ACT := '0';
        else
          ACT := '1';
        end if;
      end if;
    else
      if (SELECT_REQ_IN /= "0000") then
        SEL := '1';
      end if;

      if (INVERT_REQ_IN /= "0000") then
        if (ACT = '1') then
          ACT := '0';
        else
          ACT := '1';
        end if;
      end if;
    end if;
  end if;

  SELECTED <= SEL;
  ACTIVE <= ACT;
end process;

end Behavioral;