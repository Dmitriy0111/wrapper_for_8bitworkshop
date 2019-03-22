
module spritetest
(
    input   wire    [0 : 0]     clk,    // clock
    input   wire    [0 : 0]     reset,  // reset
    output  wire    [0 : 0]     hsync,  // horizontal sync
    output  wire    [0 : 0]     vsync,  // vertical sync
    output  wire    [2 : 0]     rgb,    // RGB
    input   wire    [0 : 0]     right,  // right
    input   wire    [0 : 0]     left,   // left
    input   wire    [0 : 0]     up,     // up
    input   wire    [0 : 0]     down    // down
);
    /*******************************************************
    *                 PARAMS & LOCALPARAMS                 *
    *******************************************************/
    localparam          BACKGROUND  = 3'b000,   // black background
                        CAR_C       = 3'b010;   // green car
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    // vga wires
    wire    [0  : 0]    display_on;             // display visible area
    wire    [15 : 0]    hpos;                   // horisontal value
    wire    [15 : 0]    vpos;                   // vertical value
    // player car position (set at VSYNC)
    reg     [15 : 0]    player_x;               // player x position
    reg     [15 : 0]    player_y;               // player y position
    wire    [0  : 0]    player_load;            // player load
    // wire up car sprite ROM
    wire    [3  : 0]    car_sprite_yofs;        // car bitmap position
    wire    [7  : 0]    car_sprite_bits;        // car bitmap value
    // signals for player sprite generator
    wire    [0  : 0]    player_vstart;          // player vertical start
    wire    [0  : 0]    player_hstart;          // player horizontal start
    wire    [0  : 0]    player_gfx;             // player paint
    wire    [0  : 0]    player_is_drawing; 
    // for updating frame with negedge vsync
    reg     [0  : 0]    frame_update;
    reg     [0  : 0]    frame_update_last;
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    // select player or enemy access to ROM
    assign  player_load   = ( hpos >= 700 );
    assign  player_vstart = player_y == vpos;
    assign  player_hstart = player_x == hpos;
    assign  rgb = display_on && player_gfx ? CAR_C : BACKGROUND;
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
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
            player_y <= 16'd240;
        end
        else if( frame_update )
        begin
            // finding new player x position
            player_x <= player_x + ( left ? - 3'h4 : 1'b0 ) + ( right ? + 3'h4 : 1'b0 );
            if( player_x < 20 )
                player_x <= 20;
            if( player_x > 620 )
                player_x <= 620;
            // finding new player y position
            player_y <= player_y + ( down ? - 3'h4 : 1'b0 ) + ( up    ? + 3'h4 : 1'b0 );
            if( player_y < 20 )
                player_y <= 20;
            if( player_y > 460 )
                player_y <= 460;
        end
    /*******************************************************
    *                   MODULE INSTANCES                   *
    *******************************************************/
    // creating one hvsync generator
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
    // creating one player player_renderer
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

endmodule // spritetest
