module wrapper_sprite_rotation
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
   
    reg     [0 : 0]     clk_div;
    wire    [0 : 0]     switch_left;
    wire    [0 : 0]     switch_right;
    wire    [0 : 0]     switch_up;

    assign switch_left  = keys[0];
    assign switch_right = keys[1];
    assign switch_up    = keys[2];

    always @(posedge clk, posedge reset)
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;

    tank_top
    tank_top_0
    (
        .clk            ( clk_div       ), 
        .reset          ( reset         ), 
        .switch_left    ( switch_left   ),
        .switch_right   ( switch_right  ),
        .switch_up      ( switch_up     ),
        .hsync          ( hsync         ), 
        .vsync          ( vsync         ), 
        .rgb            ( rgb           )
    );

endmodule // wrapper_sprite_rotation
