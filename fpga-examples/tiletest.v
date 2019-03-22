
module test_tilerender_top
(
    input   wire    [0 : 0]     clk, 
    input   wire    [0 : 0]     reset, 
    output  wire    [0 : 0]     hsync, 
    output  wire    [0 : 0]     vsync, 
    output  wire    [2 : 0]     rgb
);

    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    wire    [15 : 0]    ram_addr;
    wire    [15 : 0]    ram_read;
    wire    [15 : 0]    ram_write;          // not connected ?
    wire    [0  : 0]    ram_writeenable;    // not connected ?
    wire    [10 : 0]    rom_addr;
    wire    [7  : 0]    rom_data;
    wire    [0  : 0]    ram_busy;
    // creating one hvsync_generator
    hvsync_generator
    hvsync_gen
    (
        .clk        ( clk               ),
        .reset      ( reset             ),
        .hsync      ( hsync             ),
        .vsync      ( vsync             ),
        .display_on ( display_on        ),
        .hpos       ( hpos              ),
        .vpos       ( vpos              )
    );
    // creating one ram 
    RAM_sync
    ram
    (
        .clk        ( clk               ),
        .dout       ( ram_read          ),
        .din        ( ram_write         ),
        .addr       ( ram_addr          ),
        .we         ( ram_writeenable   )
    );
    // creating one tile_renderer
    tile_renderer 
    tile_gen
    (
        .clk        ( clk               ),
        .reset      ( reset             ),
        .hpos       ( hpos              ),
        .vpos       ( vpos              ),
        .ram_addr   ( ram_addr          ),
        .ram_read   ( ram_read          ),
        .ram_busy   ( ram_busy          ),
        .rom_addr   ( rom_addr          ),
        .rom_data   ( rom_data          ),
        .rgb        ( rgb               )
    );
    // creating one tile_rom
    font_cp437_8x8 
    tile_rom
    (
        .addr       ( rom_addr          ),
        .data       ( rom_data          )
    );
  
endmodule
