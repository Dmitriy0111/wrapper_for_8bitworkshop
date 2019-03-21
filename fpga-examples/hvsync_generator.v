
module hvsync_generator
#(
    parameter                   H_DISPLAY = 256,    // horizontal display width
                                H_BACK    =  23,    // horizontal left border (back porch)
                                H_FRONT   =   7,    // horizontal right border (front porch)
                                H_SYNC    =  23,    // horizontal sync width
                                V_DISPLAY = 240,    // vertical display height
                                V_TOP     =   5,    // vertical top border
                                V_BOTTOM  =  14,    // vertical bottom border
                                V_SYNC    =   3     // vertical sync # lines
)(
    input   wire    [0  : 0]    clk,                // clock
    input   wire    [0  : 0]    reset,              // reset
    output  reg     [0  : 0]    hsync,              // horizontal sync
    output  reg     [0  : 0]    vsync,              // vertical sync
    output  wire    [0  : 0]    display_on,         // visible area
    output  reg     [15 : 0]    hpos,               // horizontal pixel position
    output  reg     [15 : 0]    vpos                // vertical pixel position
);

    // derived constants
    localparam  H_SYNC_START = H_DISPLAY + H_FRONT,
                H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC - 1,
                H_MAX        = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1,
                V_SYNC_START = V_DISPLAY + V_BOTTOM,
                V_SYNC_END   = V_DISPLAY + V_BOTTOM + V_SYNC - 1,
                V_MAX        = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    wire    [0 : 0]     hmaxxed;
    wire    [0 : 0]     vmaxxed;
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign  hmaxxed = hpos == H_MAX;    // set when hpos is maximum
    assign  vmaxxed = vpos == V_MAX;    // set when vpos is maximum
    assign display_on = ( hpos < H_DISPLAY ) && ( vpos < V_DISPLAY );   // display_on is set when beam is in "safe" visible frame
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
    // horizontal position counter
    always @(posedge clk, posedge reset)
    if( reset )
    begin
        hsync <= 1'b0;
        hpos  <= 16'b0;
    end
    else
    begin
        hsync <= ~ ( ( hpos >= H_SYNC_START ) && ( hpos <= H_SYNC_END ) );
        if( hmaxxed )
            hpos <= 16'b0;
        else
            hpos <= hpos + 1'b1;
    end
    // vertical position counter
    always @(posedge clk, posedge reset)
    if( reset )
    begin
        vsync <= 1'b0;
        vpos  <= 16'b0;
    end
    else
    begin
        vsync <= ~ ( ( vpos >= V_SYNC_START ) && ( vpos <= V_SYNC_END ) );
        if( hmaxxed )
        begin
            if ( vmaxxed )
                vpos <= 16'b0;
            else
                vpos <= vpos + 1'b1;
        end
    end
  
endmodule // hvsync_generator
