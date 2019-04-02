module wrapper_racing_game_cpu
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
    
    // redefine parameters horizontal sync
    defparam racing_game_cpu_top_0.hvsync_gen.H_DISPLAY = 640;
    defparam racing_game_cpu_top_0.hvsync_gen.H_BACK    = 48;
    defparam racing_game_cpu_top_0.hvsync_gen.H_FRONT   = 16;
    defparam racing_game_cpu_top_0.hvsync_gen.H_SYNC    = 96;
    // redefine parameters vertical sync
    defparam racing_game_cpu_top_0.hvsync_gen.V_DISPLAY = 480;
    defparam racing_game_cpu_top_0.hvsync_gen.V_TOP     = 10;
    defparam racing_game_cpu_top_0.hvsync_gen.V_BOTTOM  = 33;
    defparam racing_game_cpu_top_0.hvsync_gen.V_SYNC    = 2;

    reg     [0 : 0]     clk_div;
    wire    [0 : 0]     left;
    wire    [0 : 0]     right;

    assign left  = keys[0];
    assign right = keys[1];

    always @(posedge clk, posedge reset)
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;

    racing_game_cpu_top
    racing_game_cpu_top_0
    (
        .clk        ( clk_div   ), 
        .reset      ( reset     ), 
        .left       ( left      ),
        .right      ( right     ),
        .hsync      ( hsync     ), 
        .vsync      ( vsync     ), 
        .rgb        ( rgb       )
    );

endmodule
