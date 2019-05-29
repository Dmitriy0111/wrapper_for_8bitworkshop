module rz_easyFPGA_A2_1
(
    input   wire    [0 : 0]     clk50mhz,
    input   wire    [0 : 0]     rst_key,
	input   wire    [3 : 0]     key,
    output  wire    [3 : 0]     led,
    output  wire    [7 : 0]     hex0,
    output  wire    [3 : 0]     dig,
    output  wire    [0 : 0]     r,
    output  wire    [0 : 0]     g,
    output  wire    [0 : 0]     b,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync
);

    wire    [0 : 0]     clk;
    wire    [3 : 0]     keys;
    wire    [2 : 0]     rgb;
    
    assign clk = clk50mhz;
    assign reset  = ~ rst_key;
    assign keys   = key;
    assign {r,g,b} = { rgb[2] , rgb[1] , rgb[0] };
    assign led = '0;
    assign dig = '1;
    assign hex0 = '1;

`define FPGA_EXAMPLE wrapper_racing_game_cpu

    `FPGA_EXAMPLE
    `FPGA_EXAMPLE
    (
        .clk    ( clk   ), 
        .reset  ( reset ), 
        .keys   ( keys  ),
        .hsync  ( hsync ), 
        .vsync  ( vsync ), 
        .rgb    ( rgb   )
    );

endmodule : rz_easyFPGA_A2_1
