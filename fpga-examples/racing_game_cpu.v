
module racing_game_cpu_top
(
    // clock and reset
    input   wire    [0  : 0]    clk,        // clock
    input   wire    [0  : 0]    reset,      // reset
    // cpu side
    input   wire    [0  : 0]    bSel,       // select
    input   wire    [31 : 0]    bAddr,      // address
    input   wire    [0  : 0]    bWrite,     // write enable
    input   wire    [31 : 0]    bWData,     // write data
    output  reg     [31 : 0]    bRData,     // read data
    // game side
    input   wire    [0  : 0]    left,       // left key
    input   wire    [0  : 0]    right,      // right key
    output  wire    [0  : 0]    hsync,      // horizontal sync
    output  wire    [0  : 0]    vsync,      // vertical sync
    output  wire    [2  : 0]    rgb         // RGB   
);

    /*******************************************************
    *                 PARAMS & LOCALPARAMS                 *
    *******************************************************/
    localparam  PLAYER_X_A      = 6'h00,    // player X coordinate
                PLAYER_Y_A      = 6'h04,    // player Y coordinate
                ENEMY_X_A       = 6'h08,    // enemy X coordinate
                ENEMY_Y_A       = 6'h0c,    // enemy Y coordinate
                ENEMY_DIR_A     = 6'h10,    // enemy direction (1, -1)
                SPEED_A         = 6'h14,    // player speed
                TRACKPOS_LO_A   = 6'h18,    // track position (lo byte)
                TRACKPOS_HI_A   = 6'h1c,    // track position (hi byte)
                IN_FLAGS_A      = 6'h20;    // flags: [0, 0, collision, vsync, hsync, vpaddle, hpaddle, display_on]
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    // vga variables
    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    reg     [0  : 0]    frame_update;
    reg     [0  : 0]    frame_update_last;
    // track variables
    reg     [7  : 0]    track_pos_lo;
    reg     [7  : 0]    track_pos_hi;
    wire    [0  : 0]    track_offside;
    wire    [0  : 0]    track_shoulder;
    wire    [0  : 0]    track_gfx;
    // collision detection logic
    reg     [0  : 0]    frame_collision;
    // player variables
    reg     [15 : 0]    player_x;
    wire    [15 : 0]    player_y;
    wire    [0  : 0]    player_vstart;
    wire    [0  : 0]    player_hstart;
    wire    [0  : 0]    player_gfx;
    wire    [0  : 0]    player_is_drawing;
    // enemy variables
    reg     [15 : 0]    enemy_x;
    reg     [15 : 0]    enemy_y;
    reg     [7  : 0]    enemy_dir;
    wire    [0  : 0]    enemy_vstart;
    wire    [0  : 0]    enemy_hstart;
    wire    [0  : 0]    enemy_gfx;
    wire    [0  : 0]    enemy_is_drawing;
    // select player or enemy access to ROM
    wire    [0  : 0]    player_load;
    wire    [0  : 0]    enemy_load;
    // wire up car sprite ROM
    // multiplex between player and enemy ROM address
    wire    [3  : 0]    player_sprite_yofs;
    wire    [3  : 0]    enemy_sprite_yofs;
    wire    [3  : 0]    car_sprite_yofs;  
    wire    [7  : 0]    car_sprite_bits;
    // enemy car speed
    reg     [7  : 0]    speed;
    // flags register
    wire    [7  : 0]    flags_reg;
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    // player
    assign player_y         = 16'd454;
    assign player_vstart    = player_y == vpos;
    assign player_hstart    = player_x == hpos;
    // enemy
    assign enemy_vstart     = enemy_y == vpos;
    assign enemy_hstart     = enemy_x == hpos;
    // select player or enemy access to ROM
    assign player_load      = ( hpos >= 700-4 ) && ( hpos < 700 );
    assign enemy_load       = ( hpos >= 700 );
    // wire up car sprite ROM
    // multiplex between player and enemy ROM address
    assign car_sprite_yofs  = player_load ? player_sprite_yofs : enemy_sprite_yofs;  
    // track graphics
    assign track_offside    = ( hpos < 20 ) || ( hpos > 620 );
    assign track_shoulder   = ( hpos < 40 ) || ( hpos > 600 );
    assign track_gfx        = ( vpos [5 : 1] != track_pos_lo[5 : 1] ) && track_offside;
    //flags register
    assign flags_reg        =   {  
                                    2'b0, 
                                    frame_collision,
                                    vsync, 
                                    hsync, 
                                    1'b0,
                                    1'b0,
                                    display_on
                                };
    // RGB output
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
    // search frame collision
    always @(posedge clk, posedge reset)
        if( reset )
            frame_collision <= 0;
        else if( player_gfx && ( enemy_gfx || track_gfx ) )
            frame_collision <= 1;
        else if( vpos == 0 )
            frame_collision <= 0;
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
    // enemy_x write
    always @(posedge clk, posedge reset)
        if( reset )
            enemy_x <= 0;
        else if( bWrite && ( bAddr[5 : 0] == ENEMY_X_A ) && bSel )
            enemy_x <= bWData;
    // enemy_y write
    always @(posedge clk, posedge reset)
        if( reset )
            enemy_y <= 0;
        else if( bWrite && ( bAddr[5 : 0] == ENEMY_Y_A ) && bSel )
            enemy_y <= bWData;
    // speed write
    always @(posedge clk, posedge reset)
        if( reset )
            speed <= 8'hf;
        else if( bWrite && ( bAddr[5 : 0] == SPEED_A ) && bSel )
            speed <= bWData;
    // enemy_dir write
    always @(posedge clk, posedge reset)
        if( reset )
            enemy_dir <= 0;
        else if( bWrite && ( bAddr[5 : 0] == ENEMY_DIR_A ) && bSel )
            enemy_dir <= bWData;
    // track_pos_lo write
    always @(posedge clk, posedge reset)
        if( reset )
            track_pos_lo <= 0;
        else if( bWrite && ( bAddr[5 : 0] == TRACKPOS_LO_A ) && bSel )
            track_pos_lo <= bWData;
    // track_pos_hi write
    always @(posedge clk, posedge reset)
        if( reset )
            track_pos_hi <= 0;
        else if( bWrite && ( bAddr[5 : 0] == TRACKPOS_HI_A ) && bSel )
            track_pos_hi <= bWData;
    // reading data(player, enemy, track, flags, program)
    always @(*)
    begin
        bRData = 32'h0000_0000;
        casex( bAddr[5 : 0] )
            PLAYER_X_A      :   bRData = player_x;
            PLAYER_Y_A      :   bRData = player_y;
            ENEMY_X_A       :   bRData = enemy_x;
            ENEMY_Y_A       :   bRData = enemy_y;
            ENEMY_DIR_A     :   bRData = enemy_dir;
            SPEED_A         :   bRData = speed;
            TRACKPOS_LO_A   :   bRData = track_pos_lo;
            TRACKPOS_HI_A   :   bRData = track_pos_hi;
            // special read registers
            IN_FLAGS_A      :   bRData = flags_reg;
            default         :   bRData = 8'b00000000;
        endcase
    end
    /*******************************************************
    *                   MODULE INSTANCES                   *
    *******************************************************/
    // creating one video sync generator
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
    // creating one car bitmap
    car_bitmap 
    car
    (
        .yofs           ( car_sprite_yofs       ), 
        .bits           ( car_sprite_bits       )
    );
    // creating one player sprite renderer
    sprite_renderer 
    player_renderer
    (
        .clk            ( clk                   ),
        .reset          ( reset                 ),
        .vstart         ( player_vstart         ),
        .hstart         ( player_hstart         ),
        .load           ( player_load           ),
        .rom_addr       ( player_sprite_yofs    ),
        .rom_bits       ( car_sprite_bits       ),
        .gfx            ( player_gfx            ),
        .in_progress    ( player_is_drawing     )
    );
    // creating one enemy sprite renderer
    sprite_renderer 
    enemy_renderer
    (
        .clk            ( clk                   ),
        .reset          ( reset                 ),
        .vstart         ( enemy_vstart          ),
        .hstart         ( enemy_hstart          ),
        .load           ( enemy_load            ),
        .rom_addr       ( enemy_sprite_yofs     ),
        .rom_bits       ( car_sprite_bits       ),
        .gfx            ( enemy_gfx             ),
        .in_progress    ( enemy_is_drawing      )
    );
  
endmodule // racing_game_cpu_top
