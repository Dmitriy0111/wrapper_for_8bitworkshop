module wrapper_spritetest
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
    
    // redefine parameters horizontal sync
    defparam spritetest_0.hvsync_gen.H_DISPLAY = 640;
    defparam spritetest_0.hvsync_gen.H_BACK    = 48;
    defparam spritetest_0.hvsync_gen.H_FRONT   = 16;
    defparam spritetest_0.hvsync_gen.H_SYNC    = 96;
    // redefine parameters vertical sync
    defparam spritetest_0.hvsync_gen.V_DISPLAY = 480;
    defparam spritetest_0.hvsync_gen.V_TOP     = 10;
    defparam spritetest_0.hvsync_gen.V_BOTTOM  = 33;
    defparam spritetest_0.hvsync_gen.V_SYNC    = 2;

    reg     [0 : 0]     clk_div;
    wire    [0 : 0]     left;
    wire    [0 : 0]     right;
    wire    [0 : 0]     up;
    wire    [0 : 0]     down;

    assign left  = keys[0];
    assign right = keys[1];
    assign up    = keys[2];
    assign down  = keys[3];

    always @(posedge clk, posedge reset)
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;

    spritetest
    spritetest_0
    (
        .clk        ( clk_div   ), 
        .reset      ( reset     ), 
        .left       ( left      ),
        .right      ( right     ),
        .up         ( up        ),
        .down       ( down      ),
        .hsync      ( hsync     ), 
        .vsync      ( vsync     ), 
        .rgb        ( rgb       )
    );

endmodule // wrapper_spritetest
