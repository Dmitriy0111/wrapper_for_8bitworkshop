module test_hvsync_tb ();

    timeprecision   1ns;
    timeunit        1ns;

    parameter   T = 10,
                rst_delay = 7;
    
    // redefine parameters horizontal sync
    defparam test_hvsync_top_0.hvsync_gen.H_DISPLAY = 640;
    defparam test_hvsync_top_0.hvsync_gen.H_BACK    = 48;
    defparam test_hvsync_top_0.hvsync_gen.H_FRONT   = 16;
    defparam test_hvsync_top_0.hvsync_gen.H_SYNC    = 96;
    // redefine parameters vertical sync
    defparam test_hvsync_top_0.hvsync_gen.V_DISPLAY = 480;
    defparam test_hvsync_top_0.hvsync_gen.V_TOP     = 10;
    defparam test_hvsync_top_0.hvsync_gen.V_BOTTOM  = 33;
    defparam test_hvsync_top_0.hvsync_gen.V_SYNC    = 2;

    logic   [0 : 0]     clk;
    logic   [0 : 0]     reset; 
    logic   [0 : 0]     hsync;
    logic   [0 : 0]     vsync; 
    logic   [2 : 0]     rgb;

    test_hvsync_top
    test_hvsync_top_0
    (
        .clk    ( clk   ), 
        .reset  ( reset ), 
        .hsync  ( hsync ), 
        .vsync  ( vsync ), 
        .rgb    ( rgb   )
    );

    initial
    begin
        clk = '0;
        forever
            #(T / 2) clk = ~ clk;
    end
    initial
    begin
        reset = '1;
        repeat(rst_delay) @(posedge clk);
        reset = '0;
    end

endmodule : test_hvsync_tb