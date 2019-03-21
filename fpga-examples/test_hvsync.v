
module test_hvsync_top
(
    input   wire    [0 : 0]     clk, 
    input   wire    [0 : 0]     reset, 
    output  wire    [0 : 0]     hsync, 
    output  wire    [0 : 0]     vsync, 
    output  wire    [2 : 0]     rgb
);

    wire  [0  : 0]    display_on;
    wire  [15 : 0]    hpos;
    wire  [15 : 0]    vpos;

    assign  rgb =   {  
                        display_on && ( ( ( hpos & 7 ) == 0 ) || ( ( vpos & 7 ) == 0 ) ),
                        display_on && vpos[4], 
                        display_on && hpos[4]
                    };

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

endmodule // test_hvsync_top
