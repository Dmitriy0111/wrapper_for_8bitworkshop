module wrapper_racing_game_cpu
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);

    wire    [0 : 0]     left;
    wire    [0 : 0]     right;

    assign left  = keys[0];
    assign right = keys[1];

    sm_top 
    sm_top_0
    (
        .clkIn          ( clk       ),
        .rst_n          ( reset     ),
        .clkDevide      ( 0         ),
        .clkEnable      ( 1'b1      ),
        .clk            (           ),
        .regAddr        ( 0         ),
        .regData        (           ),

        .gpioInput      ( 0         ),  // GPIO output pins
        .gpioOutput     (           ),  // GPIO intput pins
        .pwmOutput      (           ),  // PWM output pin
        .alsCS          (           ),  // Ligth Sensor chip select
        .alsSCK         (           ),  // Light Sensor SPI clock
        .alsSDO         ( 0         ),  // Light Sensor SPI data
        // game side
        .left           ( left      ),  // left key
        .right          ( right     ),  // right key
        .hsync          ( hsync     ),  // horizontal sync
        .vsync          ( vsync     ),  // vertical sync
        .rgb            ( rgb       )   // RGB 
    );

endmodule // wrapper_racing_game_cpu
