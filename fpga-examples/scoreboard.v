
module player_stats
(
    input   wire    [0 : 0]     reset, 
    output  reg     [3 : 0]     score0, 
    output  reg     [3 : 0]     score1, 
    output  reg     [3 : 0]     lives, 
    input   wire    [0 : 0]     incscore, 
    input   wire    [0 : 0]     declives
);

    always @(posedge incscore, posedge reset)
            if( reset ) 
            begin
                score0 <= 0;
                score1 <= 0;
            end 
            else if( score0 == 9 ) 
            begin
                score0 <= 0;
                score1 <= score1 + 1;
            end else 
                score0 <= score0 + 1;

    always @(posedge declives, posedge reset)
        begin
            if( reset )
                lives <= 3;
            else if( lives != 0 )
                lives <= lives - 1;
        end

endmodule

module scoreboard_generator
    (
        input   wire    [3  : 0]    score0, 
        input   wire    [3  : 0]    score1, 
        input   wire    [3  : 0]    lives, 
        input   wire    [15 : 0]    vpos, 
        input   wire    [15 : 0]    hpos, 
        output  wire    [0  : 0]    board_gfx
    );

    reg     [3 : 0]     score_digit;
    wire    [4 : 0]     score_bits;

    assign board_gfx = (hpos[4 -: 3] ^ 3'b111) < 8 ? score_bits[ hpos[4 -: 3] ^ 3'b111 ] : 0;

    always @(*)
        case( hpos[7 : 5] )
            1       : score_digit = score1;
            2       : score_digit = score0;
            6       : score_digit = lives;
            default : score_digit = 15; // no digit
        endcase

    digits10_array 
    digits
    (
        .digit      ( score_digit   ),
        .yofs       ( vpos[3 -: 3]  ),
        .bits       ( score_bits    )
    );

endmodule

module scoreboard_top
(
    input   wire    [0 : 0]     clk, 
    input   wire    [0 : 0]     reset, 
    output  wire    [0 : 0]     hsync, 
    output  wire    [0 : 0]     vsync, 
    output  wire    [2 : 0]     rgb
);

    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;    
    wire    [0  : 0]    board_gfx;

    assign rgb = { 3 { display_on && board_gfx } };

    hvsync_generator 
    hvsync_gen
    (
        .clk        ( clk           ),
        .reset      ( reset         ),
        .hsync      ( hsync         ),
        .vsync      ( vsync         ),
        .display_on ( display_on    ),
        .hpos       ( hpos          ),
        .vpos       ( vpos          )
    );
    
    scoreboard_generator 
    scoreboard_gen
    (
        .score0     ( 0             ),
        .score1     ( 1             ),
        .lives      ( 3             ),
        .vpos       ( vpos          ),
        .hpos       ( hpos          ),
        .board_gfx  ( board_gfx     )
    );

endmodule
