
module spritetest
(
    input   wire    [0 : 0]     clk, 
    input   wire    [0 : 0]     reset, 
    input   wire    [0 : 0]     hsync, 
    input   wire    [0 : 0]     vsync, 
    input   wire    [0 : 0]     right,
    input   wire    [0 : 0]     left,
    input   wire    [0 : 0]     up,
    input   wire    [0 : 0]     down,
    output  wire    [2 : 0]     rgb
);

    //
    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    // player car position (set at VSYNC)
    reg     [15 : 0]    player_x;
    reg     [15 : 0]    player_y; 
    wire    [0  : 0]    player_load;
    // wire up car sprite ROM
    wire    [3  : 0]    car_sprite_yofs;
    wire    [7  : 0]    car_sprite_bits;
    // signals for player sprite generator
    wire    [0  : 0]    player_vstart;
    wire    [0  : 0]    player_hstart;
    wire    [0  : 0]    player_gfx;
    wire    [0  : 0]    player_is_drawing; 
    // for updating frame with negedge vsync
    reg     [0  : 0]    frame_update;       //
    reg     [0  : 0]    frame_update_last;  //

    // select player or enemy access to ROM
    assign  player_load   = ( hpos >= 256 );
    assign  player_vstart = player_y == vpos;
    assign  player_hstart = player_x == hpos;
    assign  rgb = { 3 { (hsync||vsync) ? 0 : display_on ? (1+player_gfx+(player_vstart|player_hstart|player_is_drawing)) : 1 } };
    // video sync generator
    hvsync_generator 
    hvsync_gen
    (
        .clk            ( clk               ),
        .reset          ( reset             ),
        .hsync          ( hsync             ),
        .vsync          ( vsync             ),
        .display_on     ( display_on        ),
        .hpos           ( hpos              ),
        .vpos           ( vpos              )
    );
    // creating one car bitmap
    car_bitmap 
    car
    (
        .yofs           ( car_sprite_yofs   ), 
        .bits           ( car_sprite_bits   )
    );
    // player sprite generator
    sprite_renderer 
    player_renderer
    (
        .clk            ( clk               ),
        .reset          ( reset             ),
        .vstart         ( player_vstart     ),
        .load           ( player_load       ),
        .hstart         ( player_hstart     ),
        .rom_addr       ( car_sprite_yofs   ),
        .rom_bits       ( car_sprite_bits   ),
        .gfx            ( player_gfx        ),
        .in_progress    ( player_is_drawing )
    );
    // setting frame update
    always @(posedge clk, posedge reset)
        if( reset )
        begin
            frame_update <= 1'b0;
            frame_update_last <= 1'b0;
        end
        else
        begin
            frame_update <= 1'b0;
            if( ! vsync )
                frame_update_last <= 1'b1;
            else
                frame_update_last <= 1'b0;
            if( ( ! vsync ) && ( ! frame_update_last ) )
                frame_update <= 1'b1;
        end
    // runs once per frame
    always @(posedge clk, posedge reset)
        if( reset )
        begin
            player_x <= 16'd320;
            player_y <= 16'd320;
        end
        else if( frame_update )
        begin
            player_x <= player_x + ( left ? - 1'b1 : 1'b0 ) + ( right ? + 1'b1 : 1'b0 );
            player_y <= player_y + ( down ? - 1'b1 : 1'b0 ) + ( up    ? + 1'b1 : 1'b0 );
        end

endmodule // spritetest