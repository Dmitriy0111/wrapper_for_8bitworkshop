
module racing_game_top
(
    // clock and reset
    input   wire    [0 : 0] clk,    // clock
    input   wire    [0 : 0] reset,  // reset
    // player control
    input   wire    [0 : 0] left,   // player left signal
    input   wire    [0 : 0] right,  // player right signal
    // VGA output's
    output  wire    [0 : 0] hsync,  // horizontal synth VGA
    output  wire    [0 : 0] vsync,  // vertical synth VGA
    output  wire    [2 : 0] rgb     // RGB VGA
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    // for working with vhsync generator
    wire    [0  : 0]    display_on;         // active area
    wire    [15 : 0]    hpos;               // horizontal position from hvsync generator
    wire    [15 : 0]    vpos;               // vertical position from hvsync generator
    // player car position
    reg     [15 : 0]    player_x;           // player x position
    wire    [15 : 0]    player_y;           // player y position
    // enemy car position
    reg     [15 : 0]    enemy_x;            // enemy x position
    reg     [15 : 0]    enemy_y;            // enemy y position
    // enemy car direction, 1=right, 0=left
    reg     [0  : 0]    enemy_dir;          // enemy dir (right or left)
    // track pos and speed values
    reg     [15 : 0]    track_pos;          // player position along track (16 bits)
    reg     [7  : 0]    speed;              // player velocity along track (8 bits)
    // signals for player sprite generator
    wire    [0  : 0]    player_vstart;      // 
    wire    [0  : 0]    player_hstart;      // 
    wire    [0  : 0]    player_gfx;         // player paint
    wire    [0  : 0]    player_is_drawing;  // 1 if player drawing
    wire    [0  : 0]    player_load;        // 
    // signals for enemy sprite generator
    wire    [0  : 0]    enemy_vstart;       // 
    wire    [0  : 0]    enemy_hstart;       // 
    wire    [0  : 0]    enemy_gfx;          // enemy paint
    wire    [0  : 0]    enemy_is_drawing;   // 1 if enemy drawing
    wire    [0  : 0]    enemy_load;         // 
    // signals for enemy bouncing off left/right borders  
    wire    [0  : 0]    enemy_hit_left;     // 
    wire    [0  : 0]    enemy_hit_right;    // 
    wire    [0  : 0]    enemy_hit_edge;     // 
    // player collides with enemy or track 
    reg     [0  : 0]    frame_collision;    // 
    // track graphics signals
    wire    [0  : 0]    track_gfx;          //
    wire    [0  : 0]    track_offside;      //
    wire    [0  : 0]    track_shoulder;     //
    // for updating frame with negedge vsync
    reg     [0  : 0]    frame_update;       //
    reg     [0  : 0]    frame_update_last;  //
    // wire up car sprite ROM
    // multiplex between player and enemy ROM address
    wire    [3  : 0]    player_sprite_yofs; //
    wire    [3  : 0]    enemy_sprite_yofs;  //
    wire    [3  : 0]    car_sprite_yofs;    //
    wire    [7  : 0]    car_sprite_bits;    //
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    // car side
    assign car_sprite_yofs = player_load ? player_sprite_yofs : enemy_sprite_yofs; 
    // player side
    assign player_y        = 16'd454;
    assign player_load     = ( hpos >= 700-4 ) && ( hpos < 700 );
    assign player_vstart   = player_y == vpos;
    assign player_hstart   = player_x == hpos;
    // enemy side
    assign enemy_load      = ( hpos >= 700 );
    assign enemy_vstart    = enemy_y == vpos;
    assign enemy_hstart    = enemy_x == hpos;
    assign enemy_hit_left  = ( enemy_x == 52 ); 
    assign enemy_hit_right = ( enemy_x == 580 );
    assign enemy_hit_edge  = enemy_hit_left || enemy_hit_right;
    // creating track's
    assign track_offside   = ( hpos < 20 ) || ( hpos > 620 );
    assign track_shoulder  = ( hpos < 40 ) || ( hpos > 600 );
    assign track_gfx       = ( vpos [5 : 1] != track_pos[5 : 1] ) && track_offside;
    // form RGB signal
    assign  rgb =   {
                        display_on && ( enemy_gfx                    ),
                        display_on && ( player_gfx || track_gfx      ),
                        display_on && ( player_gfx || track_shoulder )
                    };
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
    // edit enemy position
    always @(posedge clk, posedge reset)
        if( reset )
        begin
            enemy_x   <= 320;
            enemy_y   <= 0;
            enemy_dir <= 0;
        end
        else if( frame_update )
        begin
            enemy_y <= enemy_y + {3'b0, speed[7:4]};
            if( enemy_y >= 480 )
                enemy_y <= 0;
            if( enemy_hit_edge )
                enemy_dir <= ~ enemy_dir;
            if( enemy_dir ^ enemy_hit_edge )
                enemy_x <= enemy_x + 4;
            else
                enemy_x <= enemy_x - 4;
        end
    // changed speed
    always @(posedge clk, posedge reset)
        if( reset )
            speed <= 31;
        else if( frame_update )
        begin
            if( frame_collision )
                speed <= 16;
            else if( speed < 250 )
                speed <= speed + 1;
            else if( speed > 250 )
                speed <= speed - 1;
        end
    // changed player position
    always @(posedge clk, posedge reset)
        if( reset )
            player_x <= 320;
        else if( frame_update )
        begin
            player_x <= player_x + ( left == 1'b1 ? - 4 : 0 ) + ( right == 1'b1 ? + 4 : 0 );
            if( ( player_x < 4 ) )
                player_x <= 4;
            if( ( player_x > 620 ) )
                player_x <= 620;
        end
    // changed track position
    always @(posedge clk, posedge reset)
        if( reset )
            track_pos <= 0;
        else if( frame_update )
            track_pos <= track_pos + speed[7 : 4];
    // collision if player collides with enemy or track
    always @(posedge clk, posedge reset)
        if( reset )
            frame_collision <= 0;
        else
        begin
            if( player_gfx && ( enemy_gfx || track_gfx ) )
                frame_collision <= 1;
            else if( frame_update )
                frame_collision <= 0;
        end
    /*******************************************************
    *                   MODULE INSTANCES                   *
    *******************************************************/
    // create one hvsync generator
    hvsync_generator 
    hvsync_gen
    (
        .clk            ( clk                   ),
        .reset          ( reset                 ),
        .hsync          ( hsync                 ),
        .vsync          ( vsync                 ),
        .display_on     ( display_on            ),
        .hpos           ( hpos                  ),
        .vpos           ( vpos                  )
    );
    // create one bitmap
    car_bitmap 
    car
    (
        .yofs           ( car_sprite_yofs       ), 
        .bits           ( car_sprite_bits       )
    );
    // creating one player sprite_renderer
    sprite_renderer 
    player_renderer
    (
        .clk            ( clk                   ),
        .reset          ( reset                 ),
        .vstart         ( player_vstart         ),
        .load           ( player_load           ),
        .hstart         ( player_hstart         ),
        .rom_addr       ( player_sprite_yofs    ),
        .rom_bits       ( car_sprite_bits       ),
        .gfx            ( player_gfx            ),
        .in_progress    ( player_is_drawing     )
    );
    // creating one enemy sprite_renderer
    sprite_renderer 
    enemy_renderer
    (
        .clk            ( clk                   ),
        .reset          ( reset                 ),
        .vstart         ( enemy_vstart          ),
        .load           ( enemy_load            ),
        .hstart         ( enemy_hstart          ),
        .rom_addr       ( enemy_sprite_yofs     ),
        .rom_bits       ( car_sprite_bits       ),
        .gfx            ( enemy_gfx             ),
        .in_progress    ( enemy_is_drawing      )
    );

endmodule // racing_game_top
