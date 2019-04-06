
module car_bitmap
(
    input   wire    [3 : 0]     yofs,
    output  wire    [7 : 0]     bits
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    reg     [7 : 0]     bitarray [0 : 15];
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign bits = bitarray[yofs];

    initial 
        $readmemb("../../fpga-examples/car.hex",bitarray);

endmodule // car_bitmap
