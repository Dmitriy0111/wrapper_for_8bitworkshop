module font_cp437_8x8
(
    input   wire    [10 : 0]    addr, 
    output  wire    [7  : 0]    data
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    reg     [7 : 0]     bitarray [0 : 2047];
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign data = bitarray[addr];

    initial
        $readmemh("../../fpga-examples/cp437.hex", bitarray);

endmodule
