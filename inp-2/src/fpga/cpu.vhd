-- cpu.vhd: Simple 8-bit CPU (BrainLove interpreter)
-- Copyright (C) 2016 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): Martin Cagas <xcagas01 AT stud.fit.vutbr.cz>
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
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
   CLK   : in std_logic;  -- hodinovy signal
   RESET : in std_logic;  -- asynchronni reset procesoru
   EN    : in std_logic;  -- povoleni cinnosti procesoru

   -- synchronni pamet ROM
   CODE_ADDR : out std_logic_vector( 11 downto 0 ); -- adresa do pameti
   CODE_DATA : in std_logic_vector( 7 downto 0 );   -- CODE_DATA <- rom[CODE_ADDR] pokud CODE_EN='1'
   CODE_EN   : out std_logic;                       -- povoleni cinnosti

   -- synchronni pamet RAM
   DATA_ADDR  : out std_logic_vector( 9 downto 0 ); -- adresa do pameti
   DATA_WDATA : out std_logic_vector( 7 downto 0 ); -- mem[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
   DATA_RDATA : in std_logic_vector( 7 downto 0 );  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
   DATA_RDWR  : out std_logic;                      -- cteni (1) / zapis (0)
   DATA_EN    : out std_logic;                      -- povoleni cinnosti

   -- vstupni port
   IN_DATA   : in std_logic_vector( 7 downto 0 );   -- IN_DATA <- stav klavesnice pokud IN_VLD='1' a IN_REQ='1'
   IN_VLD    : in std_logic;                        -- data platna
   IN_REQ    : out std_logic;                       -- pozadavek na vstup data

   -- vystupni port
   OUT_DATA : out  std_logic_vector( 7 downto 0 );  -- zapisovana data
   OUT_BUSY : in std_logic;                         -- LCD je zaneprazdnen (1), nelze zapisovat
   OUT_WE   : out std_logic                         -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'
 );
end cpu;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is
-- ----------------------------------------------------------------------------
--                      SIGNAL AND DATA TYPE DECLARATIONS
-- ----------------------------------------------------------------------------

-- DATA TYPES
type tInstr is (
  CELL_INC,
  CELL_DEC,
  VAL_INC,
  VAL_DEC,
  WHL_BEG,
  WHL_END,
  DATA_READ,
  DATA_WRITE,
  TMP_STORE,
  TMP_LOAD,
  PROG_END,
  UNKNOWN
);

type tFSMState is (
  SINIT,--
  SPREP_NEXT,--
  SFETCH,--
  SDECODE,--
  SCELL_INC,--
  SCELL_DEC,--
  SVAL_INC,--
  SVAL_INC_S,--
  SVAL_DEC,--
  SVAL_DEC_S,--
  SWHL_BEG1,
    SWHL_BEG2, SWHL_BEG3, SWHL_BEG4, SWHL_BEG5,
  SWHL_END1,
    SWHL_END2, SWHL_END3, SWHL_END4, SWHL_END5,
  SREAD,--
  SWRITE,--
  SLOAD,--
  SSTORE,--
  SHALT--
);

-- SIGNALS

signal ram_address    : std_logic_vector( 9 downto 0 );
signal ram_increment  : std_logic;
signal ram_decrement  : std_logic;

signal rom_address    : std_logic_vector( 11 downto 0 );
signal rom_increment  : std_logic;
signal rom_decrement  : std_logic;

signal counter        : std_logic_vector( 7 downto 0 );
signal cnt_increment  : std_logic;
signal cnt_decrement  : std_logic;


signal tmp_signal    : std_logic_vector( 7 downto 0 );
signal tmp_en        : std_logic;

signal wdata_selector  : std_logic_vector( 1 downto 0 );

signal present_state  : tFSMState;
signal next_state     : tFSMState;

signal instr          : tInstr;


begin

-- ----------------------------------------------------------------------------
--                      HARDWIRED SIGNALS
-- ----------------------------------------------------------------------------
DATA_ADDR <= ram_address;
CODE_ADDR <= rom_address;
OUT_DATA <= DATA_RDATA;

-- ----------------------------------------------------------------------------
--                      PROCESS DECLARATIONS
-- ----------------------------------------------------------------------------
instr_decoder: process( CODE_DATA )
begin
  case ( CODE_DATA ) is
    when X"3E"  =>
      instr <= CELL_INC;
    when X"3C"  =>
      instr <= CELL_DEC;
    when X"2B"  =>
      instr <= VAL_INC;
    when X"2D"  =>
      instr <= VAL_DEC;
    when X"5B"  =>
      instr <= WHL_BEG;
    when X"5D"  =>
      instr <= WHL_END;
    when X"2E"  =>
      instr <= DATA_WRITE;
    when X"2C"  =>
      instr <= DATA_READ;
    when X"24"  =>
      instr <= TMP_STORE;
    when X"21"  =>
      instr <= TMP_LOAD;
    when X"00"  =>
      instr <= PROG_END;
    when others =>
      instr <= UNKNOWN;
  end case;
end process instr_decoder;

ram_register: process( RESET, CLK )
begin
  if ( RESET = '1' ) then
    ram_address <= ( others => '0' );
  elsif rising_edge( CLK ) then
    if ( ram_increment = '1' ) then
      ram_address <= ram_address + 1;
    elsif ( ram_decrement = '1' ) then
      ram_address <= ram_address - 1;
    end if;
  end if;
end process ram_register;

rom_register: process( RESET, CLK )
begin
  if ( RESET = '1' ) then
    rom_address <= ( others => '0' );
  elsif rising_edge( CLK ) then
    if ( rom_increment = '1' ) then
      rom_address <= rom_address + 1;
    elsif ( rom_decrement = '1' ) then
      rom_address <= rom_address - 1;
    end if;
  end if;
end process rom_register;

tmp_register: process( RESET, CLK )
begin
  if ( RESET = '1' ) then
    tmp_signal <= ( others => '0' );
  elsif rising_edge( CLK ) then
    if ( tmp_en = '1' ) then
      tmp_signal <= DATA_RDATA;
    end if;
  end if;
end process tmp_register;

cnt_register: process( RESET, CLK )
begin
	if ( RESET = '1' ) then
		counter <= ( others => '0' );
	elsif rising_edge( CLK ) then
		if ( cnt_increment = '1' ) then
			counter <= counter + 1;
		elsif ( cnt_decrement = '1' ) then
			counter <= counter - 1;
		end if;
	end if;
end process;

ram_mux: process( wdata_selector )
begin
  case( wdata_selector ) is
    when "00" => DATA_WDATA <= IN_DATA;
    when "01" => DATA_WDATA <= tmp_signal;
    when "10" => DATA_WDATA <= DATA_RDATA + 1;
    when "11" => DATA_WDATA <= DATA_RDATA - 1;
    when others => null;
  end case;
end process ram_mux;

pstatereg : process( RESET, CLK )
begin
  if ( RESET = '1' ) then
    present_state <= SINIT;
  elsif rising_edge( CLK ) then
    present_state <= next_state;
  end if;
end process pstatereg;

nstate_logic : process( present_state, CODE_DATA, DATA_RDATA, IN_DATA, IN_VLD, OUT_BUSY, instr, counter, wdata_selector )
begin
  next_state <= SINIT;

  DATA_EN <= '0';
  CODE_EN <= '0';
  IN_REQ <= '0';
  OUT_WE <= '0';

  ram_increment <= '0';
  ram_decrement <= '0';
  rom_increment <= '0';
  rom_decrement <= '0';
  cnt_increment <= '0';
  cnt_decrement <= '0';
  tmp_en <='0';

  case ( present_state ) is

  -- processor initialisation
  when SINIT =>
    DATA_RDWR <= '1';
    next_state <= SFETCH;

  -- preparation for fetch
  when SPREP_NEXT =>
    rom_increment <= '1';
    next_state <= SFETCH;

  -- fetching new instruction
  when SFETCH =>
    CODE_EN <= '1';
    next_state <= SDECODE;

  -- decoding new instruction
  when SDECODE =>
    case instr is
      when CELL_INC =>
        next_state <= SCELL_INC;
      when CELL_DEC =>
        next_state <= SCELL_DEC;
      when VAL_INC =>
        next_state <= SVAL_INC;
      when VAL_DEC =>
        next_state <= SVAL_DEC;
      when WHL_BEG =>
        next_state <= SWHL_BEG1;
      when WHL_END =>
        next_state <= SWHL_END1;
      when DATA_READ =>
        next_state <= SREAD;
      when DATA_WRITE =>
        next_state <= SWRITE;
      when TMP_STORE =>
        next_state <= SSTORE;
      when TMP_LOAD =>
        next_state <= SLOAD;
      when PROG_END =>
        next_state <= SHALT;
      when UNKNOWN =>
        next_state <= SPREP_NEXT;
  end case;

  -- incrementing RAM pointer
  when SCELL_INC =>
    ram_increment <= '1';
    next_state <= SPREP_NEXT;

  -- decrementing RAM pointer
  when SCELL_DEC =>
    ram_decrement <= '1';
    next_state <= SPREP_NEXT;

  -- loading RAM value
  when SVAL_INC =>
    DATA_RDWR <= '1';
    DATA_EN <= '1';
    next_state <= SVAL_INC_S;

  -- storing incremented value
  when SVAL_INC_S =>
    DATA_RDWR <= '0';
    DATA_EN <= '1';
    wdata_selector <= "10";
    next_state <= SPREP_NEXT;

  -- loading RAM value
  when SVAL_DEC =>
    DATA_RDWR <= '1';
    DATA_EN <= '1';
    next_state <= SVAL_DEC_S;

  -- storing decremented value
  when SVAL_DEC_S =>
    DATA_RDWR <= '0';
    DATA_EN <= '1';
    wdata_selector <= "11";
    next_state <= SPREP_NEXT;

  -- the beginning of the left while statement
  when SWHL_BEG1 =>
    DATA_RDWR <= '1';
    DATA_EN <= '1';
    next_state <= SWHL_BEG2;

  when SWHL_BEG2 =>
    if ( DATA_RDATA = "00000000" ) then
      rom_increment <= '1';
      cnt_increment <= '1';
      next_state <= SWHL_BEG3;
    else
      next_state <= SPREP_NEXT;
    end if;

  when SWHL_BEG3 =>
    CODE_EN <= '1';
    next_state <= SWHL_BEG4;

  when SWHL_BEG4 =>
    if ( instr = WHL_BEG ) then
      cnt_increment <= '1';
      rom_increment <= '1';
      next_state <= SWHL_BEG3;
    elsif ( instr = WHL_END ) then
      cnt_decrement <= '1';
      next_state <= SWHL_BEG5;
    else
      rom_increment <= '1';
      next_state <= SWHL_BEG3;
    end if;

  when SWHL_BEG5 =>
    if ( counter = "00000000" ) then
      next_state <= SPREP_NEXT;
    else
      rom_increment <= '1';
      next_state <= SWHL_BEG3;
    end if;

  -- the beginning of the right while statement
  when SWHL_END1 =>
    DATA_RDWR <= '1';
    DATA_EN <= '1';
    next_state <= SWHL_END2;

  when SWHL_END2 =>
    if ( DATA_RDATA = "00000000" ) then
      next_state <= SPREP_NEXT;
    else
      rom_decrement <= '1';
      cnt_increment <= '1';
      next_state <= SWHL_END3;
    end if;

  when SWHL_END3 =>
    CODE_EN <= '1';
    next_state <= SWHL_END4;

  when SWHL_END4 =>
    if ( instr = WHL_END ) then
      cnt_increment <= '1';
      rom_decrement <= '1';
      next_state <= SWHL_END3;
    elsif ( instr = WHL_BEG ) then
      cnt_decrement <= '1';
      next_state <= SWHL_END5;
    else
      rom_decrement <= '1';
      next_state <= SWHL_END3;
    end if;

  when SWHL_END5 =>
    if ( counter = "00000000" ) then
      next_state <= SPREP_NEXT;
    else
      rom_decrement <= '1';
      next_state <= SWHL_END3;
    end if;

  -- initiate read request
  when SREAD =>
    if ( IN_VLD = '1' ) then
      DATA_RDWR <= '0';
      DATA_EN <= '1';
      wdata_selector <= "00";
      next_state <= SPREP_NEXT;
    else
      IN_REQ <= '1';
      next_state <= SREAD;
    end if;

  -- wait until LCD is ready, then send data
  when SWRITE =>
    if ( OUT_BUSY = '1' ) then
      next_state <= SWRITE;
    else
      DATA_RDWR <= '1';
      DATA_EN <= '1';
      OUT_WE <= '1';
      next_state <= SPREP_NEXT;
    end if;

  -- loading current value to TMP
  when SLOAD =>
    DATA_RDWR <= '1';
    DATA_EN <= '1';
    tmp_en <= '1';
    next_state <= SPREP_NEXT;

  -- storing TMP to current cell
  when SSTORE =>
    DATA_RDWR <= '0';
    DATA_EN <= '1';
    wdata_selector <= "01";
    next_state <= SPREP_NEXT;

  -- ending state
  when SHALT =>
    next_state <= SHALT;

  -- critical error - resets processor
  -- should occur only on error that would cause incorrect signal value of the current state
  when others =>
    next_state <= SINIT;

  end case;
end process nstate_logic;


end behavioral;
