`define log_en 1

module spritetest_tb ();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        rst_delay = 7;

    logic   [0 : 0]     clk;
    logic   [0 : 0]     reset; 
    logic   [0 : 0]     hsync;
    logic   [0 : 0]     vsync; 
    logic   [2 : 0]     rgb;
    logic   [0 : 0]     left;
    logic   [0 : 0]     right;
    logic   [0 : 0]     up;
    logic   [0 : 0]     down;
    logic   [3 : 0]     keys;

    assign keys = '0 | { down , up , right , left };

    wrapper_spritetest
    wrapper_spritetest_0
    (
        .clk        ( clk       ), 
        .reset      ( reset     ), 
        .keys       ( keys      ),
        .hsync      ( hsync     ), 
        .vsync      ( vsync     ), 
        .rgb        ( rgb       )
    );

    initial
    begin
        clk = '0;
        forever
            #(T / 2) clk = ~ clk;
    end
    initial
    begin
        reset = '1;
        repeat(rst_delay) @(posedge clk);
        reset = '0;
    end
    initial
    begin
        left    = 1'b0;
        right   = 1'b0;
        up      = 1'b0;
        down    = 1'b0;
    end
    initial
        $readmemb("../fpga-examples/car.hex",wrapper_spritetest_0.spritetest_0.car.bitarray);

    `ifdef log_en

    integer file;
    integer frame_c;
    parameter repeat_cycles = 200;

    string color = "";

    initial
    begin
        frame_c = 0;
        file = $fopen("../.log","w");
        fork
            forever
            begin
                if( ( hsync == '1 ) && ( vsync == '1 ) )
                begin
                    color = ( rgb == 0 ) && ( color == "" ) ? " " : color;
                    color = ( rgb == 1 ) && ( color == "" ) ? "1" : color;
                    color = ( rgb == 2 ) && ( color == "" ) ? "$" : color;
                    color = ( rgb == 3 ) && ( color == "" ) ? "T" : color;
                    color = ( rgb == 4 ) && ( color == "" ) ? "#" : color;
                    color = ( rgb == 5 ) && ( color == "" ) ? "H" : color;
                    color = ( rgb == 6 ) && ( color == "" ) ? "6" : color;
                    color = ( rgb == 7 ) && ( color == "" ) ? "*" : color;
                    
                    $fwrite(file, "%s", color);

                    color = "";
                end
                else if( ( hsync == '1 ) && ( vsync == '0 ) )
                begin
                    $fwrite(file, "-");
                end
                    @(negedge clk);
                    @(negedge clk);
            end
            forever
            begin
                @(negedge hsync);
                $fwrite(file, "|\n");
            end
            forever
            begin
                @(posedge vsync);
                frame_c++;
                $fwrite(file, "number of frame = %d", frame_c);
                $display("number of frame = %d %tns", frame_c, $time);
                if( frame_c == repeat_cycles + 1 )
                    $stop;
            end
        join
    end

    `endif

endmodule : spritetest_tb
