
module crttest
(
    input   wire    [0 : 0]     clk,    // clock
    input   wire    [0 : 0]     reset,  // reset
    output  wire    [0 : 0]     hsync,  // horizontal sync
    output  wire    [0 : 0]     vsync,  // vertical sync
    output  wire    [2 : 0]     rgb     // RGB VGA
);

    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    reg     [5  : 0]    frame;

    reg     [0  : 0]    frame_update;
    reg     [0  : 0]    last_frame_update;

    assign  rgb =   {
                        display_on && ( ( ( hpos & 7 ) == 0 ) || ( ( ( vpos + frame ) & 7 ) == 0 ) ),
                        display_on && vpos[4],
                        display_on && hpos[4]
                    };

    always @(posedge clk, posedge reset)
        if( reset )
        begin
            frame_update <= 1'b0;
            last_frame_update <= 1'b0;
        end
        else
        begin
            frame_update <= 1'b0;
            if( ! vsync )
                last_frame_update <= 1'b1;
            else
                last_frame_update <= 1'b0;
            if( ( ! vsync ) && ( ! last_frame_update ) )
                frame_update <= 1'b1;
        end

    always @(posedge clk, posedge reset) 
        if( reset )
            frame <= 6'b0;
        else if( frame_update )
            frame <= frame + 1'b1;

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

endmodule // crttest
