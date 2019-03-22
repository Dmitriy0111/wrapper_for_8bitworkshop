
module digits10_case
(
    input   wire    [3 : 0]     digit,  // digit 0-9
    input   wire    [2 : 0]     yofs,   // vertical offset (0-4)
    output  reg     [4 : 0]     bits    // output (5 bits)
);

    // combine {digit,yofs} into single ROM address
    wire    [6 : 0]     caseexpr;

    assign caseexpr = { digit , yofs };
  
    always @(*)
        case( caseexpr )
            // 0
            7'o000: bits = 5'b11111;
            7'o001: bits = 5'b10001;
            7'o002: bits = 5'b10001;
            7'o003: bits = 5'b10001;
            7'o004: bits = 5'b11111;
            // 1
            7'o010: bits = 5'b01100;
            7'o011: bits = 5'b00100;
            7'o012: bits = 5'b00100;
            7'o013: bits = 5'b00100;
            7'o014: bits = 5'b11111;
            // 2
            7'o020: bits = 5'b11111;
            7'o021: bits = 5'b00001;
            7'o022: bits = 5'b11111;
            7'o023: bits = 5'b10000;
            7'o024: bits = 5'b11111;
            // 3
            7'o030: bits = 5'b11111;
            7'o031: bits = 5'b00001;
            7'o032: bits = 5'b11111;
            7'o033: bits = 5'b00001;
            7'o034: bits = 5'b11111;
            // 4
            7'o040: bits = 5'b10001;
            7'o041: bits = 5'b10001;
            7'o042: bits = 5'b11111;
            7'o043: bits = 5'b00001;
            7'o044: bits = 5'b00001;
            // 5
            7'o050: bits = 5'b11111;
            7'o051: bits = 5'b10000;
            7'o052: bits = 5'b11111;
            7'o053: bits = 5'b00001;
            7'o054: bits = 5'b11111;
            // 6
            7'o060: bits = 5'b11111;
            7'o061: bits = 5'b10000;
            7'o062: bits = 5'b11111;
            7'o063: bits = 5'b10001;
            7'o064: bits = 5'b11111;
            // 7
            7'o070: bits = 5'b11111;
            7'o071: bits = 5'b00001;
            7'o072: bits = 5'b00001;
            7'o073: bits = 5'b00001;
            7'o074: bits = 5'b00001;
            // 8
            7'o100: bits = 5'b11111;
            7'o101: bits = 5'b10001;
            7'o102: bits = 5'b11111;
            7'o103: bits = 5'b10001;
            7'o104: bits = 5'b11111;
            // 9
            7'o110: bits = 5'b11111;
            7'o111: bits = 5'b10001;
            7'o112: bits = 5'b11111;
            7'o113: bits = 5'b00001;
            7'o114: bits = 5'b11111;
            // default
            default: bits = 0;
        endcase

endmodule // digits10_case

module digits10_array
(
    input   wire    [3 : 0]     digit,  // digit 0-9
    input   wire    [2 : 0]     yofs,   // vertical offset (0-4)
    output  reg     [4 : 0]     bits    // output (5 bits)
);

    wire    [24 : 0]    help_bits;

    reg     [24 : 0]    bitarray [9 : 0];   // ROM array (16 x 5 x 5 bits)

    assign help_bits = bitarray[ digit ];

    always @(*)
    begin
        bits = 5'b0;
        case( yofs )
            5'd0:   bits = help_bits[20 +: 5];
            5'd1:   bits = help_bits[15 +: 5];
            5'd2:   bits = help_bits[10 +: 5];
            5'd3:   bits = help_bits[5  +: 5];
            5'd4:   bits = help_bits[0  +: 5];
        endcase
    end
    
    initial
        $readmemb("digits10.hex",bitarray);

endmodule // digits10_array

module test_numbers_top
(
    input   wire    [0 : 0]     clk,    // clock
    input   wire    [0 : 0]     reset,  // reset
    output  wire    [0 : 0]     hsync,  // horizontal sync
    output  wire    [0 : 0]     vsync,  // vertical sync
    output  wire    [2 : 0]     rgb     // RGB
);
    // wires from hvsync generator
    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    // 
    wire    [3  : 0]    digit;
    wire    [2  : 0]    xofs;
    wire    [2  : 0]    yofs;
    wire    [4  : 0]    bits;
    
    assign digit = hpos[9 -: 4];
    assign xofs  = hpos[5 -: 3];
    assign yofs  = vpos[3 -: 3];
    assign rgb  =   {  
                        display_on && 0,
                        display_on && bits[xofs ^ 3'b111],
                        display_on && 0
                    };
    // creating one hvsync generator
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
    // creating one digits10_array
    digits10_array 
    numbers
    (
        .digit      ( digit         ),
        .yofs       ( yofs          ),
        .bits       ( bits          )
    );

endmodule // test_numbers_top
