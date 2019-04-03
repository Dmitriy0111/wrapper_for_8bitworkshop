
module tank_bitmap
(
    input   wire    [7 : 0]     addr, 
    output  wire    [7 : 0]     bits
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    reg     [15 : 0]    bitarray [0 : 255];
    
    assign bits = (addr[0]) ? bitarray[addr>>1][15:8] : bitarray[addr>>1][7:0];
    
    initial
        $readmemb("../../fpga-examples/tank.hex", bitarray);

endmodule // tank_bitmap

module sprite_renderer2
(
    input   wire    [0 : 0]     clk, 
    input   wire    [0 : 0]     reset,
    input   wire    [0 : 0]     vstart, 
    input   wire    [0 : 0]     load, 
    input   wire    [0 : 0]     hstart, 
    output  reg     [4 : 0]     rom_addr, 
    input   wire    [7 : 0]     rom_bits, 
    input   wire    [0 : 0]     hmirror, 
    input   wire    [0 : 0]     vmirror,
    output  reg     [0 : 0]     gfx, 
    output  wire    [0 : 0]     busy
);

    localparam  WAIT_FOR_VSTART = 0,
                WAIT_FOR_LOAD   = 1,
                LOAD1_SETUP     = 2,
                LOAD1_FETCH     = 3,
                LOAD2_SETUP     = 4,
                LOAD2_FETCH     = 5,
                WAIT_FOR_HSTART = 6,
                DRAW            = 7;
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    reg     [2  : 0]    state;
    reg     [3  : 0]    ycount;
    reg     [3  : 0]    xcount;
    reg     [15 : 0]    outbits;
    
    assign busy = state != WAIT_FOR_VSTART;
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
    always @(posedge clk, posedge reset)
        if( reset )
        begin
            gfx <= 0;
            state <= WAIT_FOR_VSTART;
            ycount <= 0;
            xcount <= 0;
            outbits <= 0;
            rom_addr <= 0;
        end
        else
        begin
            case( state )
                WAIT_FOR_VSTART: 
                begin
                    ycount <= 0;
                    // set a default value (blank) for pixel output
                    // note: multiple non-blocking assignments are vendor-specific
                    gfx <= 0;
                    if( vstart ) 
                        state <= WAIT_FOR_LOAD;
                end
                WAIT_FOR_LOAD: 
                begin
                    xcount <= 0;
                    gfx <= 0;
                    if( load ) 
                        state <= LOAD1_SETUP;
                end
                LOAD1_SETUP: 
                begin
                    rom_addr <= { vmirror ? ~ ycount : ycount , 1'b0 };
                    state <= LOAD1_FETCH;
                end
                LOAD1_FETCH: 
                begin
                    outbits[0 +: 8] <= rom_bits;
                    state <= LOAD2_SETUP;
                end
                LOAD2_SETUP: 
                begin
                    rom_addr <= { ( vmirror ? ~ ycount : ycount ) , 1'b1 };
                    state <= LOAD2_FETCH;
                end
                LOAD2_FETCH: 
                begin
                    outbits[15 : 8] <= rom_bits;
                    state <= WAIT_FOR_HSTART;
                end
                WAIT_FOR_HSTART: 
                begin
                    if (hstart) state <= DRAW;
                end
                DRAW: 
                begin
                    // mirror graphics left/right
                    gfx <= outbits[ hmirror ? ~ xcount[3 : 0] : xcount[3 : 0] ];
                    xcount <= xcount + 1;
                    if( xcount == 15 ) 
                    begin // pre-increment value
                        ycount <= ycount + 1;
                        if( ycount == 15 ) // pre-increment value
                            state <= WAIT_FOR_VSTART; // done drawing sprite
                        else
                            state <= WAIT_FOR_LOAD; // done drawing this scanline
                    end
                end
            endcase
        end
  
endmodule // sprite_renderer2

// converts 0..15 rotation value to bitmap index / mirror bits
module rotation_selector
(
    input   wire    [3 : 0]     rotation, 
    output  reg     [2 : 0]     bitmap_num, 
    output  reg     [0 : 0]     hmirror, 
    output  reg     [0 : 0]     vmirror
);
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
    always @(*)
        case( rotation[3 : 2] ) // 4 quadrants
            0: 
            begin               // 0..3 -> 0..3
                bitmap_num = { 1'b0 , rotation[1 : 0] };
                hmirror = 0;
                vmirror = 0;
            end
            1: 
            begin               // 4..7 -> 4..1
                bitmap_num = - rotation[2 : 0];
                hmirror = 0;
                vmirror = 1;
            end
            2: 
            begin               // 8-11 -> 0..3
                bitmap_num = { 1'b0 , rotation[1 : 0] };
                hmirror = 1;
                vmirror = 1;
            end
            3: 
            begin               // 12-15 -> 4..1
                bitmap_num = - rotation[2 : 0];
                hmirror = 1;
                vmirror = 0;
            end
            default:
            begin
                bitmap_num = 0;
                hmirror    = 0;
                vmirror    = 0;
            end
        endcase

endmodule // rotation_selector

// tank controller module -- handles rendering and movement
module tank_controller
(
    input   wire    [0  : 0]    clk, 
    input   wire    [0  : 0]    reset, 
    input   wire    [15 : 0]    hpos, 
    input   wire    [15 : 0]    vpos, 
    input   wire    [0  : 0]    hsync, 
    input   wire    [0  : 0]    vsync, 
    output  wire    [7  : 0]    sprite_addr, 
    input   wire    [7  : 0]    sprite_bits, 
    output  wire    [0  : 0]    gfx,
    input   wire    [0  : 0]    playfield,
    input   wire    [0  : 0]    switch_left, 
    input   wire    [0  : 0]    switch_right, 
    input   wire    [0  : 0]    switch_up
);
    /*******************************************************
    *                 PARAMS & LOCALPARAMS                 *
    *******************************************************/
    localparam  initial_x   = 320,
                initial_y   = 240,
                initial_rot = 0;
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    wire    [0  : 0]    hmirror;
    wire    [0  : 0]    vmirror;
    wire    [0  : 0]    busy;
    wire    [0  : 0]    collision_gfx;

    reg     [15 : 0]    player_x;
    reg     [15 : 0]    player_y;
    reg     [3  : 0]    player_rot;
    reg     [3  : 0]    player_speed;
    reg     [3  : 0]    frame;
    
    wire    [0  : 0]    vstart;
    wire    [0  : 0]    hstart;

    // set if collision; cleared at vsync
    reg     [0  : 0]    collision_detected; 
    reg     [0  : 0]    frame_update;
    reg     [0  : 0]    frame_update_last;
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign vstart = player_y == vpos;
    assign hstart = player_x == hpos;
    assign collision_gfx = gfx && playfield;
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
    // speed and frame
    always @(posedge clk, posedge reset)
        if( reset ) 
            player_rot <= initial_rot;
        else if( frame_update && frame[0] )
            player_rot <= player_rot + ( switch_left ? -1'b1 : 1'b0 ) + ( switch_right ? 1'b1 : 1'b0 );
    // speed and frame
    always @(posedge clk, posedge reset)
        if( reset ) 
            frame <= 0;
        else if( frame_update )
            frame <= frame + 1; // increment frame counter
    // speed and frame
    always @(posedge clk, posedge reset)
        if( reset ) 
            player_speed <= 0;
        else if( frame_update && frame[0] )
            player_speed <= switch_up ? ( player_speed <= 15 ? player_speed + 1 : player_speed ) : 0;
    // collision detection
    always @(posedge clk, posedge reset)
        if( reset )
            collision_detected <= 0;
        else if( vstart )
            collision_detected <= 0;
        else if( collision_gfx )
            collision_detected <= 1;
    // player position update
    always @(posedge clk, posedge reset)
        if( reset ) 
        begin
            // set initial position
            player_x <= initial_x;
            player_y <= initial_y;
        end 
        else if( frame_update )
        begin
            // collision detected? move backwards
            if( collision_detected && vpos[3 : 1] == 0) 
            begin
                if( vpos[0] )
                    player_x <= player_x + sin_16x4( player_rot + 8  );
                else
                    player_y <= player_y - sin_16x4( player_rot + 12 );
            end else
            // forward movement
            if( vpos < player_speed ) 
            begin
                if( vpos[0] )
                    player_x <= player_x + sin_16x4( player_rot + 0  );
                else
                    player_y <= player_y - sin_16x4( player_rot + 4  );
            end
        end

    // sine lookup (4 bits input, 4 signed bits output)  
    function signed [3 : 0] sin_16x4( input [3 : 0] in);
        integer y;
        begin
            case( in[1 : 0] )	// 4 values per quadrant
                0       : y = 0;
                1       : y = 3;
                2       : y = 5;
                3       : y = 6;
                default : y = 0;
            endcase
            case( in[3 : 2] )	// 4 quadrants
                0       : sin_16x4 = y;
                1       : sin_16x4 = 7-y;
                2       : sin_16x4 = -y;
                3       : sin_16x4 = y-7;
                default : sin_16x4 = y;
            endcase
        end
    endfunction
    /*******************************************************
    *                   MODULE INSTANCES                   *
    *******************************************************/
    // creating one sprite renderer
    sprite_renderer2 
    renderer
    (
        .clk        ( clk                   ),
        .reset      ( reset                 ),
        .vstart     ( vstart                ),
        .load       ( hsync                 ),
        .hstart     ( hstart                ),
        .hmirror    ( hmirror               ),
        .vmirror    ( vmirror               ),
        .rom_addr   ( sprite_addr[4 : 0]    ),
        .rom_bits   ( sprite_bits           ),
        .gfx        ( gfx                   ),
        .busy       ( busy                  )
    );
    // creating one rotation selector
    rotation_selector 
    rotsel
    (
        .rotation   ( player_rot            ),
        .bitmap_num ( sprite_addr[7 : 5]    ),
        .hmirror    ( hmirror               ),
        .vmirror    ( vmirror               )
    );

endmodule // tank_controller

module tank_top
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [0 : 0]     switch_left,
    input   wire    [0 : 0]     switch_right,
    input   wire    [0 : 0]     switch_up,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    // for working with vhsync generator
    wire    [0  : 0]    display_on;         // active area
    wire    [15 : 0]    hpos;               // horizontal position from hvsync generator
    wire    [15 : 0]    vpos;               // vertical position from hvsync generator
    // tank bitmap module
    wire    [7  : 0]    tank_addr;
    wire    [7  : 0]    tank_bits;
    // tank graphic
    wire    [0  : 0]    tank_gfx;
    // walls
    wire    [0  : 0]    top_wall;
    wire    [0  : 0]    bottom_wall;
    wire    [0  : 0]    right_wall;
    wire    [0  : 0]    left_wall;
    wire    [0  : 0]    wall_gfx;
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    // walls
    assign top_wall     = vpos < 5;
    assign bottom_wall  = vpos > 475;
    assign right_wall   = hpos < 5;
    assign left_wall    = hpos > 635;
    assign wall_gfx     = top_wall || bottom_wall || right_wall || left_wall;
    // VGA rgb
    assign rgb  =   {   
                        1'b0,
                        display_on && tank_gfx,
                        display_on && wall_gfx
                    };
    /*******************************************************
    *                   MODULE INSTANCES                   *
    *******************************************************/
    // creating one tank bitmap
    tank_bitmap
    tank_0
    (
        .addr           ( tank_addr     ), 
        .bits           ( tank_bits     )
    );
    // creating one tank controller
    tank_controller
    tank_controller_0
    (
        .clk            ( clk           ), 
        .reset          ( reset         ), 
        .hpos           ( hpos          ), 
        .vpos           ( vpos          ), 
        .hsync          ( hsync         ), 
        .vsync          ( vsync         ), 
        .sprite_addr    ( tank_addr     ), 
        .sprite_bits    ( tank_bits     ), 
        .gfx            ( tank_gfx      ),
        .playfield      ( wall_gfx      ),
        .switch_left    ( switch_left   ), 
        .switch_right   ( switch_right  ), 
        .switch_up      ( switch_up     )
    );
    // creating one hvsync generator
    hvsync_generator 
    hvsync_gen
    (
        .clk            ( clk           ),
        .reset          ( reset         ),
        .hsync          ( hsync         ),
        .vsync          ( vsync         ),
        .display_on     ( display_on    ),
        .hpos           ( hpos          ),
        .vpos           ( vpos          )
    );

endmodule // tank_top
