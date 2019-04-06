# Wrapper for 8bitworkshop

This project is based on fpga-examples (FPGA examples for 8bitworkshop.com).
GitHub link : https://github.com/sehugg/fpga-examples.

For working with examples edit in verilog board file (board/[board name]) value of constant in string:
```verilog
`define FPGA_EXAMPLE wrapper_racing_game
```
choosing one of the following:

## Work:
*   wrapper_racing_game
*   wrapper_racing_game_v2
*   wrapper_racing_game_v3
*   wrapper_spritetest
*   wrapper_sprite_rotation
*   wrapper_test_hvsync
*   wrapper_crttest

## Doesn't work (or works with bugs):
*   wrapper_racing_game_cpu
*   wrapper_digit10
*   wrapper_ball_paddle
*   wrapper_sprite_scanline_renderer
*   wrapper_starfield
*   wrapper_tiletest

## Simulation:
*   **make sim_dir** is used for creating simulation folder;
*   **make sim_clean** is used for cleaning simulation results folder;
*   **make sim_cmd** is used for starting simulation in command line (CMD) mode;
*   **make sim_gui** is used for starting simulation in graphical user interface (GUI) mode.

If log_en set as '1 (tb/"testbench name") then you can see simulation results (VGA screen in text mode) in .log file.

## Synthesis:
*   **make synth_create** is used for creating synthesis folder for default board;
*   **make synth_clean** is used for cleaning synthesis folder;
*   **make synth_build_q** is used for building project;
*   **make synth_gui_q** is used for open project in Quartus;
*   **make synth_load_q** is used for loading bitstream in CPLD/FPGA.

## Boards support:
This project currently works on these FPGA boards:
<ol>
<li>rz_easyFPGA_A2_1 ( Altera Cyclone IV FPGA )</li>
<li>Storm_IV_E6_V2 ( Altera Cyclone IV FPGA )</li>
<li><a href="https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=234&No=1021">Terasic DE10-Lite ( Altera MAX10 FPGA )</a></li>
</ol>
