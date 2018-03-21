-- ram.vhd : RAM memory
-- Copyright (C) 2011/2012 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): Zdenek Vasicek <vasicek AT fit.vutbr.cz>
--
-- LICENSE TERMS
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in
--    the documentation and/or other materials provided with the
--    distribution.
-- 3. All advertising materials mentioning features or use of this software
--    or firmware must display the following acknowledgement:
--
--      This product includes software developed by the University of
--      Technology, Faculty of Information Technology, Brno and its
--      contributors.
--
-- 4. Neither the name of the Company nor the names of its contributors
--    may be used to endorse or promote products derived from this
--    software without specific prior written permission.
--
-- This software or firmware is provided ``as is'', and any express or implied
-- warranties, including, but not limited to, the implied warranties of
-- merchantability and fitness for a particular purpose are disclaimed.
-- In no event shall the company or contributors be liable for any
-- direct, indirect, incidental, special, exemplary, or consequential
-- damages (including, but not limited to, procurement of substitute
-- goods or services; loss of use, data, or profits; or business
-- interruption) however caused and on any theory of liability, whether
-- in contract, strict liability, or tort (including negligence or
-- otherwise) arising in any way out of the use of this software, even
-- if advised of the possibility of such damage.
--
-- $Id$
--
--

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_ARITH.ALL;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity ram is
 port (
   CLK   : in std_logic; -- hodiny

   ADDR  : in std_logic_vector(9 downto 0);  -- adresa bunky
   WDATA : in std_logic_vector(7 downto 0);  -- data pro zapis
   RDATA : out std_logic_vector(7 downto 0); -- nactena data (v dalsim taktu, pokud EN=1)
   RDWR  : in std_logic;                     -- 1 - cteni, 0 - zapis
   EN    : in std_logic                      -- 1 - povoleni prace s pameti
 );
end ram;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of ram is

   type t_ram is array (0 to 2**10-1) of std_logic_vector (7 downto 0);
   signal ram: t_ram := (others => X"00");
   signal rd : std_logic_vector (7 downto 0) := (others => '0');
begin
   RDATA <= rd;

   -- RAM rd / wr
   sram_mem: process (CLK)
   begin
      if (CLK'event) and (CLK = '1') then
         if (EN = '1') then
            if (RDWR = '0') then
               ram(conv_integer(ADDR)) <= WDATA;
               rd <= WDATA;
            else
               rd <= ram(conv_integer(ADDR));
            end if;
         end if;
      end if;
   end process;

end behavioral;
