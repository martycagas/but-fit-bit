-- rom.vhd : ROM memory
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
use ieee.std_logic_arith.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity rom is
 generic (
   INIT  : string := ""
 );
 port (
   CLK   : in std_logic; -- clock

   EN    : in  std_logic;
   ADDR  : in std_logic_vector(11 downto 0); -- address
   DATA  : out std_logic_vector(7 downto 0) -- data
 );
end rom;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of rom is
   type t_ram is array (0 to 2**12-1) of std_logic_vector(7 downto 0);

   function str2vec(arg: string; size: integer) return t_ram is
      variable result: t_ram := (others => (others => '0'));
    begin
      for i in arg'range loop
          result(i-1) := conv_std_logic_vector(character'pos(arg(i)), 8);
      end loop;
      return result;
    end;

   constant mem: t_ram := str2vec(INIT, 2*2048);
   signal dout : std_logic_vector(7 downto 0) := (others => '0');
begin

   process (CLK)
   begin
      if (CLK'event) and (CLK = '1') then
         if (EN = '1') then
            dout <= mem(conv_integer(ADDR));
         end if;
      end if;
   end process;

   DATA <= dout;

end behavioral;
