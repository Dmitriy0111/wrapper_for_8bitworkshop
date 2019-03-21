
module racing_game_cpu_top
(
    input   wire    [0 : 0]     clk, 
    input   wire    [0 : 0]     reset, 
    input   wire    [0 : 0]     hpaddle, 
    input   wire    [0 : 0]     vpaddle,
    output  wire    [2 : 0]     rgb, 
    output  wire    [0 : 0]     hsync, 
    output  wire    [0 : 0]     vsync
);

    localparam  PADDLE_X = 0;       // paddle X coordinate
    localparam  PADDLE_Y = 1;       // paddle Y coordinate
    localparam  PLAYER_X = 2;       // player X coordinate
    localparam  PLAYER_Y = 3;       // player Y coordinate
    localparam  ENEMY_X = 4;        // enemy X coordinate
    localparam  ENEMY_Y = 5;        // enemy Y coordinate
    localparam  ENEMY_DIR = 6;      // enemy direction (1, -1)
    localparam  SPEED = 7;	        // player speed
    localparam  TRACKPOS_LO = 8;	// track position (lo byte)
    localparam  TRACKPOS_HI = 9;	// track position (hi byte)

    localparam  IN_HPOS = 8'h40;	// CRT horizontal position
    localparam  IN_VPOS = 8'h41;	// CRT vertical position
    // flags: [0, 0, collision, vsync, hsync, vpaddle, hpaddle, display_on]
    localparam  IN_FLAGS = 8'h42;
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    //
    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    //
    reg     [7  : 0]    ram [0 :  15];  // 16 bytes of RAM
    reg     [7  : 0]    rom [0 : 127];  // 128 bytes of ROM
    //
    wire    [7  : 0]    address_bus;	// CPU address bus
    reg     [7  : 0]    to_cpu;		// data bus to CPU
    wire    [7  : 0]    from_cpu;		// data bus from CPU
    wire    [0  : 0]    write_enable;		// write enable bit from CPU
    //
    wire    [0  : 0]    track_offside;
    wire    [0  : 0]    track_shoulder;
    wire    [0  : 0]    track_gfx;
    // collision detection logic
    reg     [0  : 0]    frame_collision;
    // flags for player sprite renderer module
    wire    [0  : 0]    player_vstart;
    wire    [0  : 0]    player_hstart;
    wire    [0  : 0]    player_gfx;
    wire    [0  : 0]    player_is_drawing;
    // flags for enemy sprite renderer module
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
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign player_vstart   = {1'b0,ram[PLAYER_Y]} == vpos;
    assign player_hstart   = {1'b0,ram[PLAYER_X]} == hpos;
    // flags for enemy sprite renderer module
    assign enemy_vstart    = {1'b0,ram[ENEMY_Y]} == vpos;
    assign enemy_hstart    = {1'b0,ram[ENEMY_X]} == hpos;
    // select player or enemy access to ROM
    assign player_load     = ( hpos >= 700-4 ) && ( hpos < 700 );
    assign enemy_load      = ( hpos >= 700 );
    // wire up car sprite ROM
    // multiplex between player and enemy ROM address
    assign car_sprite_yofs = player_load ? player_sprite_yofs : enemy_sprite_yofs;  
    // track graphics
    assign track_offside   = ( hpos < 20 ) || ( hpos > 620 );
    assign track_shoulder  = ( hpos < 40 ) || ( hpos > 600 );
    assign track_gfx       = (vpos[5:1]!=ram[TRACKPOS_LO][5:1]) && track_offside;
    // RGB output
    assign rgb =    {
                        display_on && ( player_gfx || enemy_gfx || track_shoulder ),
                        display_on && ( player_gfx || track_gfx ),
                        display_on && ( enemy_gfx  || track_shoulder )
                    };
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
    always @(posedge clk, posedge reset)
        if( reset )
            frame_collision <= 0;
        else if( player_gfx && ( enemy_gfx || track_gfx ) )
            frame_collision <= 1;
        else if( vpos == 0 )
            frame_collision <= 0;
    // RAM write from CPU
    always @(posedge clk)
        if( write_enable )
            ram[address_bus[5:0]] <= from_cpu;
    // RAM read from CPU
    always @(*)
        casez (address_bus)
            // RAM
            8'b00?????? :   to_cpu = ram[address_bus[5 : 0]];
            // special read registers
            IN_HPOS     :   to_cpu = hpos[7 : 0];
            IN_VPOS     :   to_cpu = vpos[7 : 0];
            IN_FLAGS    :   to_cpu =    {  
                                            2'b0, 
                                            frame_collision,
                                            vsync, 
                                            hsync, 
                                            vpaddle, 
                                            hpaddle, 
                                            display_on
                                        };
            // ROM
            8'b1??????? :   to_cpu = rom[address_bus[6 : 0]];
            default:        to_cpu = 8'b00000000;
        endcase
    /*******************************************************
    *                   MODULE INSTANCES                   *
    *******************************************************/
    // 8-bit CPU module
    CPU 
    cpu
    (   .clk            ( clk                   ),
        .reset          ( reset                 ),
        .address        ( address_bus           ),
        .data_in        ( to_cpu                ),
        .data_out       ( from_cpu              ),
        .write          ( write_enable          )
    );
    // video sync generator
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
    // car bitmap
    car_bitmap 
    car
    (
        .yofs           ( car_sprite_yofs       ), 
        .bits           ( car_sprite_bits       )
    );
    // player sprite renderer
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
    // enemy sprite renderer
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
    
    //////////// CPU program code
    initial
    begin
        $readmemh("racing.hex", rom);
        ram[00] = 0;
        ram[01] = 0;
        ram[02] = 0;
        ram[03] = 0;
        ram[04] = 0;
        ram[05] = 0;
        ram[06] = 0;
        ram[07] = 0;
        ram[08] = 0;
        ram[09] = 0;
        ram[10] = 0;
        ram[11] = 0;
        ram[12] = 0;
        ram[13] = 0;
        ram[14] = 0;
        ram[15] = 0;
    end
  
endmodule
