library IEEE;
use IEEE.STD_LOGIC_1164.all;

package cell_math_pack is

constant IDX_TOP    : natural := 0;
constant IDX_LEFT   : natural := 1;
constant IDX_RIGHT  : natural := 2;
constant IDX_BOTTOM : natural := 3;
constant IDX_ENTER  : natural := 4;

type mask_t is
  record
    top     : std_logic;
    bottom  : std_logic;
    right   : std_logic;
    left    : std_logic;
  end record;

function getmask (x, y : natural; COLUMNS, ROWS : natural)
  return mask_t;

function linker (x, y, index : natural)
  return natural;

end cell_math_pack;

package body cell_math_pack is

function getmask (x, y : natural; COLUMNS, ROWS : natural) return mask_t is

  variable neighbours : mask_t;

begin
  if (x = 0) then
    neighbours.left := '0';
  else
    neighbours.left := '1';
  end if;
  
  if (y = 0) then
    neighbours.top := '0';
  else
    neighbours.top := '1';
  end if;
  
  if (x < COLUMNS - 1) then
    neighbours.right := '1';
  else
    neighbours.right := '0';
  end if;
  
  if (y < ROWS - 1) then
    neighbours.bottom := '1';
  else
    neighbours.bottom := '0';
  end if;
  
  return neighbours;

end getmask;

function linker (x, y, index : natural) return natural is

  variable ret : natural;

begin
  
  if (x < 0) then
    ret := (x * 4) + (y * 20) + index + 20;
  elsif (x > 4) then
    ret := (x * 4) + (y * 20) + index - 20;
  elsif(y < 0) then
    ret := (x * 4) + (y * 20) + index + 100;
  elsif(y > 4) then
    ret := (x * 4) + (y * 20) + index - 100;
  else
    ret := (x * 4) + (y * 20) + index;
  end if;

  return ret;

end linker;

end cell_math_pack;