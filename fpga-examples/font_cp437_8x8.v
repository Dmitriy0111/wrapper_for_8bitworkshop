
module font_cp437_8x8
(
    input   wire    [10 : 0]    addr, 
    output  wire    [7  : 0]    data
);

    reg [7 : 0] bitarray [0 : 2047];

    assign data = bitarray[addr];

    initial
        $readmemh("cp437.hex", bitarray);

endmodule
