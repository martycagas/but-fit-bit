----------------------------------------------------------------------------------
-- Course: VUT FIT - INP - Winter Semester 2016
-- Student: Martin Cagaš - xcagas01
--
-- Create Date:    25-10-2016
-- Design Name:    Top Level FPGA configuration of LED matrix display controller
-- Module Name:    ledc8x8.vhd
-- Project Name:   Controlling matrix display using FPGA
--
-- Revision:
--  Revision 0.1
-- Additional Comments: the cake is a lie
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port (
      SMCLK : in std_logic;
      RESET : in std_logic;
      ROW   : out std_logic_vector(7 downto 0);
      LED   : out std_logic_vector(7 downto 0)
);
end ledc8x8;

architecture main of ledc8x8 is

    signal row_clock    : std_logic;
    signal letter_clock : std_logic;
    signal counter      : std_logic_vector(23 downto 0);
    signal row_buffer   : std_logic_vector(7 downto 0);

begin
    -- division of the SMCLK clock signal
    -- the row_clock signal is assigned 256 times delayed clock frequency (2^8)
    -- the letter_clock signal is assigned a 8 388 608 times delayed clock frequency (2^23)
  clock_control : process (SMCLK, RESET)
  begin
    if (RESET = '1') then
      counter <= (others => '0');
    elsif (SMCLK'event) and (SMCLK = '1') then
        counter <= counter + 1;
    end if;
  end process;

  row_control : process (row_clock, RESET)
  begin
    if (RESET = '1') then
      row_buffer <= "00000001";
    elsif (row_clock'event) and (row_clock = '1') then
      row_buffer <= row_buffer(6 downto 0) & row_buffer(7);
    end if;
  end process;

  letter_control : process (letter_clock, row_buffer)
  begin
    if (letter_clock = '0') then
      case (row_buffer) is
        -- the letter capital M
        when "00000001" => LED <= "00111001";
        when "00000010" => LED <= "00010001";
        when "00000100" => LED <= "00000001";
        when "00001000" => LED <= "00000001";
        when "00010000" => LED <= "00101001";
        when "00100000" => LED <= "00111001";
        when "01000000" => LED <= "00111001";
        when "10000000" => LED <= "00111001";

        when others     => LED <= "00000000";
      end case;
    else
      case (row_buffer) is
        -- the letter capital C
        when "00000001" => LED <= "10000011";
        when "00000010" => LED <= "00000001";
        when "00000100" => LED <= "00111001";
        when "00001000" => LED <= "11111001";
        when "00010000" => LED <= "11111001";
        when "00100000" => LED <= "00111001";
        when "01000000" => LED <= "00000001";
        when "10000000" => LED <= "10000011";

        when others     => LED <= "00000000";
      end case;
    end if;
  end process;

  row_clock <= counter(8);
  letter_clock <= counter(23);
  ROW <= row_buffer;

end main;
