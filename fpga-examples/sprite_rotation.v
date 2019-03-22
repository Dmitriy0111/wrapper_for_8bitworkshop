
module tank_bitmap
(
    input   wire    [7 : 0]     addr, 
    output  wire    [7 : 0]     bits
);
  
  reg [15:0] bitarray[0:255];
  
  assign bits = (addr[0]) ? bitarray[addr>>1][15:8] : bitarray[addr>>1][7:0];
  
  initial
    $readmemb("tank.hex", bitarray)

endmodule // tank_bitmap

module sprite_renderer2
(
    input   wire    [0 : 0]     clk, 
    input   wire    [0 : 0]     vstart, 
    input   wire    [0 : 0]     load, 
    input   wire    [0 : 0]     hstart, 
    output  wire    [4 : 0]     rom_addr, 
    input   wire    [7 : 0]     rom_bits, 
    input   wire    [0 : 0]     hmirror, 
    input   wire    [0 : 0]     vmirror,
    output  wire    [0 : 0]     gfx, 
    output  wire    [0 : 0]     busy
);

  localparam WAIT_FOR_VSTART = 0;
  localparam WAIT_FOR_LOAD   = 1;
  localparam LOAD1_SETUP     = 2;
  localparam LOAD1_FETCH     = 3;
  localparam LOAD2_SETUP     = 4;
  localparam LOAD2_FETCH     = 5;
  localparam WAIT_FOR_HSTART = 6;
  localparam DRAW            = 7;
  

    reg     [2  : 0]    state;
    reg     [3  : 0]    ycount;
    reg     [3  : 0]    xcount;
    reg     [15 : 0]    outbits;
    
    assign busy = state != WAIT_FOR_VSTART;
    
    always @(posedge clk)
        begin
            case (state)
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
                    rom_addr <= {vmirror?~ycount:ycount, 1'b0};
                    state <= LOAD1_FETCH;
                end
                LOAD1_FETCH: 
                begin
                    outbits[7:0] <= rom_bits;
                    state <= LOAD2_SETUP;
                end
                LOAD2_SETUP: 
                begin
                    rom_addr <= {vmirror?~ycount:ycount, 1'b1};
                    state <= LOAD2_FETCH;
                end
                LOAD2_FETCH: 
                begin
                    outbits[15:8] <= rom_bits;
                    state <= WAIT_FOR_HSTART;
                end
                WAIT_FOR_HSTART: 
                begin
                    if (hstart) state <= DRAW;
                end
                DRAW: 
                begin
                    // mirror graphics left/right
                    gfx <= outbits[hmirror ? ~xcount[3:0] : xcount[3:0]];
                    xcount <= xcount + 1;
                    if (xcount == 15) 
                    begin // pre-increment value
                        ycount <= ycount + 1;
                        if (ycount == 15) // pre-increment value
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
    output  wire    [2 : 0]     bitmap_num, 
    output  wire    [0 : 0]     hmirror, 
    output  wire    [0 : 0]     vmirror
);
  
    always @(*)
        case( rotation[3 : 2] ) // 4 quadrants
            0: 
            begin               // 0..3 -> 0..3
                bitmap_num = {1'b0, rotation[1 : 0]};
                hmirror = 0;
                vmirror = 0;
            end
            1: 
            begin               // 4..7 -> 4..1
                bitmap_num = -rotation[2 : 0];
                hmirror = 0;
                vmirror = 1;
            end
            2: 
            begin               // 8-11 -> 0..3
                bitmap_num = {1'b0, rotation[1 : 0]};
                hmirror = 1;
                vmirror = 1;
            end
            3: 
            begin               // 12-15 -> 4..1
                bitmap_num = -rotation[2 : 0];
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
  
    parameter initial_x   = 128;
    parameter initial_y   = 120;
    parameter initial_rot = 0;
    
    wire    [0  : 0]    hmirror;
    wire    [0  : 0]    vmirror;
    wire    [0  : 0]    busy;
    wire    [0  : 0]    collision_gfx = gfx && playfield;

    reg     [11 : 0]    player_x_fixed;
    wire    [7  : 0]    player_x = player_x_fixed[11:4];
    wire    [3  : 0]    player_x_frac = player_x_fixed[3:0];
    
    reg     [11 : 0]    player_y_fixed;
    wire    [7  : 0]    player_y = player_y_fixed[11:4];
    wire    [3  : 0]    player_y_frac = player_y_fixed[3:0];
    
    reg     [3  : 0]    player_rot;
    reg     [3  : 0]    player_speed;
    reg     [3  : 0]    frame = 0;
    
    wire    [0  : 0]    vstart = {1'b0,player_y} == vpos;
    wire    [0  : 0]    hstart = {1'b0,player_x} == hpos;

    sprite_renderer2 
    renderer
    (
        .clk        ( clk                   ),
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
    
    rotation_selector 
    rotsel
    (
        .rotation   (player_rot         ),
        .bitmap_num (sprite_addr[7 : 5] ),
        .hmirror    (hmirror            ),
        .vmirror    (vmirror            )
    );

    always @(posedge vsync, posedge reset)
    begin
        if( reset ) 
        begin
            player_rot <= initial_rot;
            player_speed <= 0;
        end 
        else 
        begin
            frame <= frame + 1; // increment frame counter
            if( frame[0] ) 
            begin // only update every other frame
                if( switch_left )
                    player_rot <= player_rot - 1; // turn left
                else if( switch_right )
                    player_rot <= player_rot + 1; // turn right
                if( switch_up ) 
                begin
                    if( player_speed != 15 ) // max accel
                    player_speed <= player_speed + 1;
                end 
                else
                    player_speed <= 0; // stop
            end
        end
    end
    
    // set if collision; cleared at vsync
    reg collision_detected; 
    
    always @(posedge clk)
        if( vstart )
            collision_detected <= 0;
        else if( collision_gfx )
            collision_detected <= 1;
    
    // sine lookup (4 bits input, 4 signed bits output)  
    function signed [3:0] sin_16x4;
        input [3:0] in;	// input angle 0..15
        integer y;
        case (in[1:0])	// 4 values per quadrant
            0: y = 0;
            1: y = 3;
            2: y = 5;
            3: y = 6;
        endcase
        case (in[3:2])	// 4 quadrants
            0: sin_16x4 = 4'(y);
            1: sin_16x4 = 4'(7-y);
            2: sin_16x4 = 4'(-y);
            3: sin_16x4 = 4'(y-7);
        endcase
    endfunction
    
    always @(posedge hsync or posedge reset)
        if( reset ) 
        begin
            // set initial position
            player_x_fixed <= initial_x << 4;
            player_y_fixed <= initial_y << 4;
        end else begin
            // collision detected? move backwards
            if( collision_detected && vpos[3:1] == 0) 
            begin
                if( vpos[0] )
                    player_x_fixed <= player_x_fixed + 12'(sin_16x4(player_rot+8));
                else
                    player_y_fixed <= player_y_fixed - 12'(sin_16x4(player_rot+12));
            end else
            // forward movement
            if( vpos < 9'(player_speed) ) 
            begin
                if( vpos[0] )
                    player_x_fixed <= player_x_fixed + 12'(sin_16x4(player_rot));
                else
                    player_y_fixed <= player_y_fixed - 12'(sin_16x4(player_rot+4));
            end
        end

endmodule // tank_controller
