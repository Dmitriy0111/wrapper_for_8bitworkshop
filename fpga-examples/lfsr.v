
module LFSR
#(  
    parameter                       NBITS  = 8,         // bit width
                                    TAPS   = 8'b11101,  // bitmask for taps
                                    INVERT = 0          // invert feedback bit?
)(
    input   wire    [0       : 0]   clk,                // clock
    input   wire    [0       : 0]   reset,              // reset
    input   wire    [0       : 0]   enable,             // enable
    output  reg     [NBITS-1 : 0]   lfsr                // lfsr
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    wire    [0 : 0]     feedback;
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign feedback = lfsr[NBITS-1] ^ INVERT;
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
    always @(posedge clk, posedge reset)
    begin
        if( reset )
            lfsr <= { NBITS-1 {1'b1} }; // reset loads with all 1s
        else if( enable )
            lfsr <= { lfsr[NBITS-2:0], 1'b0 } ^ ( feedback ? TAPS : 0 );
    end

endmodule // LFSR
