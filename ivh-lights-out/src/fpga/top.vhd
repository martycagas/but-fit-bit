----------------------------------------------------------------------------------
-- Course: VUT FIT - IVH - Summer Semester 2016
-- Student: Martin Cagaš - xcagas01
-- 
-- Create Date:    15:21:27 04-05-2016 
-- Design Name:    Top Level FPGA configuration
-- Module Name:    top.vhd
-- Project Name:   Lights Out for FITkit FPGA
--
-- Revision:
-- Revision 0.1
-- Additional Comments: --
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.vga_controller_cfg.all;
use work.cell_math_pack.all;

architecture main of tlv_pc_ifc is

  signal vga_mode : std_logic_vector(60 downto 0);
  
  signal irgb : std_logic_vector(8 downto 0);
  signal color_selected_inactive, color_selected_active, color_unselected_inactive, color_unselected_active : std_logic_vector(8 downto 0);

  signal row : std_logic_vector(11 downto 0);
  signal col : std_logic_vector(11 downto 0);

  signal kbrd_data_out : std_logic_vector(15 downto 0);
  signal kbrd_data_vld : std_logic;

  signal char_symbol : std_logic_vector(3 downto 0) := "1010";
  signal char_data : std_logic;

  signal in_cell : std_logic_vector(9 downto 0) := "0000000000";

  signal bcd_clk : std_logic;
  signal bcd_num1 : std_logic_vector(3 downto 0);
  signal bcd_num2 : std_logic_vector(3 downto 0);
  signal bcd_num3 : std_logic_vector(3 downto 0);

  signal active : std_logic_vector(24 downto 0);
  signal selected : std_logic_vector(24 downto 0);

  signal select_request : std_logic_vector(99 downto 0);
  signal invert_request : std_logic_vector(99 downto 0);

  signal keys_to_cell : std_logic_vector(4 downto 0) := "00000";

  signal ad_reset : std_logic := '1';

  signal init_sel : std_logic_vector(24 downto 0) := "0000000000001000000000000";
  signal init_act : std_logic_vector(24 downto 0) := "0000000000000000000000000";

begin

  setmode(r640x480x60, vga_mode);

  -- VGA controller, delay 1 tact
  vga: entity work.vga_controller(arch_vga_controller)
  generic map (REQ_DELAY => 2)
  port map (
    CLK    => CLK,
    RST    => RESET,
    ENABLE => '1',
    MODE   => vga_mode,

    DATA_RED    => irgb(8 downto 6),
    DATA_GREEN  => irgb(5 downto 3),
    DATA_BLUE   => irgb(2 downto 0),
    ADDR_COLUMN => col,
    ADDR_ROW    => row,

    VGA_RED   => RED_V,
    VGA_BLUE  => BLUE_V,
    VGA_GREEN => GREEN_V,
    VGA_HSYNC => HSYNC_V,
    VGA_VSYNC => VSYNC_V
  );

  
  -- Keyboard controller
  kbrd_ctrl: entity work.keyboard_controller(arch_keyboard)
  port map (
    CLK => CLK,
    RST => RESET,

    DATA_OUT => kbrd_data_out(15 downto 0),
    DATA_VLD => kbrd_data_vld,
     
    KB_KIN   => KIN,
    KB_KOUT  => KOUT
  );
  
  bcd : entity work.bcd
  port map (
    CLK => bcd_clk,
    RESET => ad_reset,
    NUMBER1 => bcd_num1,
    NUMBER2 => bcd_num2,
    NUMBER3 => bcd_num3
  );

  chardec : entity work.char_rom
    port map (
      ADDRESS => char_symbol,
      ROW => row(3 downto 0),
      COLUMN => col(2 downto 0),
      DATA => char_data
    );

  cellsy : for y in 4 downto 0 generate
    cellsx : for x in 4 downto 0 generate
      gamecell : entity work.cell
      generic map (
        mask => getmask(x, y, 5, 5)
      )
      port map (
        INVERT_REQ_IN(IDX_TOP) => invert_request(linker(x, y - 1, IDX_BOTTOM)),
        INVERT_REQ_IN(IDX_LEFT) => invert_request(linker(x - 1, y, IDX_RIGHT)),
        INVERT_REQ_IN(IDX_RIGHT) => invert_request(linker(x + 1, y, IDX_LEFT)),
        INVERT_REQ_IN(IDX_BOTTOM) => invert_request(linker(x, y + 1, IDX_TOP)),
        
        INVERT_REQ_OUT => invert_request(linker(x, y, IDX_BOTTOM) downto linker(x, y, IDX_TOP)),

        KEYS => keys_to_cell,

        SELECT_REQ_IN(IDX_TOP) => select_request( linker(x, y - 1, IDX_BOTTOM)),
        SELECT_REQ_IN(IDX_LEFT) => select_request( linker(x - 1, y, IDX_RIGHT)),
        SELECT_REQ_IN(IDX_RIGHT) => select_request( linker(x + 1, y, IDX_LEFT)),
        SELECT_REQ_IN(IDX_BOTTOM) => select_request( linker(x, y + 1, IDX_TOP)),
        
        SELECT_REQ_OUT => select_request(linker(x, y, IDX_BOTTOM) downto linker(x, y, IDX_TOP)),

        INIT_ACTIVE => init_act((y * 5) + x),
        ACTIVE => active((y * 5) + x),

        INIT_SELECTED => init_sel((y * 5) + x),
        SELECTED => selected((y * 5) + x),

        CLK => CLK,
        RESET => ad_reset
      );
    end generate cellsx;
  end generate cellsy;

  controls: process(CLK)
    variable in_access : std_logic := '0';

  begin
    if CLK'event and CLK= '1' then
      bcd_clk <= '0';
      ad_reset <= '0';
      keys_to_cell <= (others => '0');

      if (in_access = '0') then
        if (kbrd_data_out /= 0) then
          in_access := '1';
          
          keys_to_cell <= kbrd_data_out(5) & kbrd_data_out(6) & kbrd_data_out(9) & kbrd_data_out(1) & kbrd_data_out(4);

          if (kbrd_data_out(5) = '1') then
            bcd_clk <= '1';
          end if;

          if (kbrd_data_out(12) = '1') then
            init_act <= "1010101010101010101010101";
            ad_reset <= '1';
          end if;

          if (kbrd_data_out(13) = '1') then
            init_act <= "1011010100101011010100101";
            ad_reset <= '1';
          end if;

          if (kbrd_data_out(14) = '1') then
            init_act <= "1001010101101101010010110";
            ad_reset <= '1';
          end if;

          if (kbrd_data_out(15) = '1') then
            init_act <= "0111010111001010101110011";
            ad_reset <= '1';
          end if;
        end if;
      else
        if (kbrd_data_out = 0) and (kbrd_data_vld = '0') then 
          in_access := '0';
        end if;
      end if;
    end if;
  end process;

  color_selected_inactive <= "001000000";
  color_selected_active <= "111000000";
  color_unselected_inactive <= "000001000";
  color_unselected_active <= "000111000";

  
  vga_output: process (row, col)
    variable in_nmr_row, in_sym_1, in_sym_2, in_sym_3 : std_logic;
    variable col_buff, row_buff : integer;
    
  begin
    if CLK'event and CLK='1' then
      irgb <= "000000000";

      if col=0 or col=624 then
        in_sym_1 := '0';
        in_sym_2 := '0';
        in_sym_3 := '0';
      elsif col=600 then
        in_sym_1 := '1';
      elsif col=608 then
        in_sym_1 := '0';
        in_sym_2 := '1';
      elsif col=616 then
        in_sym_1 := '0';
        in_sym_2 := '0';
        in_sym_3 := '1';
      end if;

      if row=0 or row=416 then
        in_nmr_row  :=  '0';
      elsif row=400 then
        in_nmr_row  :=  '1';
      end if;

      if (in_sym_1 = '1') then
        char_symbol <= bcd_num3;
      elsif (in_sym_2 = '1') then
        char_symbol <= bcd_num2;
      elsif (in_sym_3 = '1') then
        char_symbol <= bcd_num1;
      end if;

      if in_nmr_row='1' and (in_sym_1 = '1' or in_sym_2 = '1' or in_sym_3 = '1') then
        if char_data = '1' then
          irgb <= "111111111";
        end if;
      end if;

      case (row) is
        when "000000000101" => -- 5
          in_cell(0) <= '1';
        when "000001100100" => -- 100
          in_cell(1) <= '1';
        when "000011000011" => -- 195
          in_cell(2) <= '1';
        when "000100100010" => -- 290
          in_cell(3) <= '1';
        when "000110000001" => -- 385
          in_cell(4) <= '1';
        when others => null;
      end case;

      case (col) is
        when "000001011111" => -- 85
          in_cell(5) <= '1';
        when "000010111110" => -- 180
          in_cell(6) <= '1';
        when "000100011101" => -- 275
          in_cell(7) <= '1';
        when "000101111100" => -- 370
          in_cell(8) <= '1';
        when "000111011011" => -- 465
          in_cell(9) <= '1';
        when others => null;
      end case;

      if row=95 or row=190 or row=285 or row=380 or row=475 then
        in_cell(4 downto 0) <= (others => '0');
      end if;

      if col=185 or col=280 or col=375 or col=470 or col=565 then
        in_cell(9 downto 5) <= (others => '0');
      end if;

      case (in_cell) is
        when "0000100001" =>
          if (active(0) = '1') then
            if (selected(0) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(0) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0001000001" =>
          if (active(1) = '1') then
            if (selected(1) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(1) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0010000001" =>
          if (active(2) = '1') then
            if (selected(2) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(2) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0100000001" =>
          if (active(3) = '1') then
            if (selected(3) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(3) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "1000000001" =>
          if (active(4) = '1') then
            if (selected(4) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(4) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0000100010" =>
          if (active(5) = '1') then
            if (selected(5) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(5) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0001000010" =>
          if (active(6) = '1') then
            if (selected(6) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(6) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0010000010" =>
          if (active(7) = '1') then
            if (selected(7) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(7) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0100000010" =>
          if (active(8) = '1') then
            if (selected(8) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(8) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "1000000010" =>
          if (active(9) = '1') then
            if (selected(9) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(9) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0000100100" =>
          if (active(10) = '1') then
            if (selected(10) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(10) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0001000100" =>
          if (active(11) = '1') then
            if (selected(11) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(11) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0010000100" =>
          if (active(12) = '1') then
              if (selected(12) = '1') then
                irgb <= color_selected_active;
              else
                irgb <= color_unselected_active;
              end if;
            else
              if (selected(12) = '1') then
                irgb <= color_selected_inactive;
              else
                irgb <= color_unselected_inactive;
              end if;
            end if;
        when "0100000100" =>
          if (active(13) = '1') then
            if (selected(13) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(13) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "1000000100" =>
          if (active(14) = '1') then
            if (selected(14) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(14) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0000101000" =>
          if (active(15) = '1') then
            if (selected(15) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(15) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0001001000" =>
          if (active(16) = '1') then
            if (selected(16) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(16) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0010001000" =>
          if (active(17) = '1') then
            if (selected(17) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(17) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0100001000" =>
          if (active(18) = '1') then
            if (selected(18) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(18) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "1000001000" =>
          if (active(19) = '1') then
            if (selected(19) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(19) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0000110000" =>
          if (active(20) = '1') then
            if (selected(20) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(20) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0001010000" =>
          if (active(21) = '1') then
            if (selected(21) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(21) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0010010000" =>
          if (active(22) = '1') then
            if (selected(22) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(22) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "0100010000" =>
        if (active(23) = '1') then
            if (selected(23) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(23) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when "1000010000" =>
          if (active(24) = '1') then
            if (selected(24) = '1') then
              irgb <= color_selected_active;
            else
              irgb <= color_unselected_active;
            end if;
          else
            if (selected(24) = '1') then
              irgb <= color_selected_inactive;
            else
              irgb <= color_unselected_inactive;
            end if;
          end if;
        when others => null;
      end case;

    end if;
  end process;

end main;