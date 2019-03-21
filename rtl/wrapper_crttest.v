module wrapper_crttest
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
    
    // redefine parameters horizontal sync
    defparam crttest_0.hvsync_gen.H_DISPLAY = 640;
    defparam crttest_0.hvsync_gen.H_BACK    = 48;
    defparam crttest_0.hvsync_gen.H_FRONT   = 16;
    defparam crttest_0.hvsync_gen.H_SYNC    = 96;
    // redefine parameters vertical sync
    defparam crttest_0.hvsync_gen.V_DISPLAY = 480;
    defparam crttest_0.hvsync_gen.V_TOP     = 10;
    defparam crttest_0.hvsync_gen.V_BOTTOM  = 33;
    defparam crttest_0.hvsync_gen.V_SYNC    = 2;

    reg     [0 : 0]     clk_div;

    always @(posedge clk, posedge reset)
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;

    crttest
    crttest_0
    (
        .clk        ( clk_div   ), 
        .reset      ( reset     ), 
        .hsync      ( hsync     ), 
        .vsync      ( vsync     ), 
        .rgb        ( rgb       )
    );

endmodule // wrapper_crttest
