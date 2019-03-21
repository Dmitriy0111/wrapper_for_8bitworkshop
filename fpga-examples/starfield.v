
module starfield_top
(
    input   wire    [0 : 0]     clk,    // clock
    input   wire    [0 : 0]     reset,  // reset
    output  wire    [0 : 0]     hsync,  // horizontal sync
    output  wire    [0 : 0]     vsync,  // vertical sync
    output  wire    [2 : 0]     rgb     // RGB VGA
);

    wire    [0  : 0]    display_on;
    wire    [0  : 0]    star_on;
    wire    [0  : 0]    star_enable;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    wire    [15 : 0]    lfsr;
    
    assign  star_enable = ( ! hpos[15] ) && ( ! vpos[15] );
    assign  star_on     = & lfsr[15:9]; // all 7 bits must be set
    assign  rgb         = display_on && star_on ? lfsr[2:0] : 0;
    
    // creating one hvsync generator
    hvsync_generator
    hvsync_gen
    (
        .clk        ( clk           ),
        .reset      ( reset         ),
        .hsync      ( hsync         ),
        .vsync      ( vsync         ),
        .display_on ( display_on    ),
        .hpos       ( hpos          ),
        .vpos       ( vpos          )
    );
    // creating one lfsr_gen
    LFSR
    #(
      .NBITS        ( 32            ),
      .TAPS         ( 8'b11101      ),
      .INVERT       ( 0             )
    )
    lfsr_gen
    (
      .clk          ( clk           ),
      .reset        ( reset         ),
      .enable       ( star_enable   ),
      .lfsr         ( lfsr          )
    );

endmodule // starfield_top
