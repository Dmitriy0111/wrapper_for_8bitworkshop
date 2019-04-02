module wrapper_ball_paddle
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
    
    // redefine parameters horizontal sync
    defparam ball_paddle_top_0.hvsync_gen.H_DISPLAY = 640;
    defparam ball_paddle_top_0.hvsync_gen.H_BACK    = 48;
    defparam ball_paddle_top_0.hvsync_gen.H_FRONT   = 16;
    defparam ball_paddle_top_0.hvsync_gen.H_SYNC    = 96;
    // redefine parameters vertical sync
    defparam ball_paddle_top_0.hvsync_gen.V_DISPLAY = 480;
    defparam ball_paddle_top_0.hvsync_gen.V_TOP     = 10;
    defparam ball_paddle_top_0.hvsync_gen.V_BOTTOM  = 33;
    defparam ball_paddle_top_0.hvsync_gen.V_SYNC    = 2;

    reg     [0 : 0]     clk_div;

    always @(posedge clk, posedge reset)
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;

    ball_paddle_top ball_paddle_top_0
    (
        .clk        ( clk_div   ),
        .reset      ( reset     ),
        .hpaddle    ( 0         ),
        .hsync      ( hsync     ),
        .vsync      ( vsync     ),
        .rgb        ( rgb       )
    );

endmodule // wrapper_ball_paddle
