
module sprite_renderer
(
    input   wire    [0 : 0]     clk,        // clock
    input   wire    [0 : 0]     reset,      // reset
    input   wire    [0 : 0]     hstart,     // start drawing scanline (left border)
    input   wire    [0 : 0]     vstart,     // start drawing (top border)
    input   wire    [0 : 0]     load,       // ok to load sprite data?
    output  reg     [3 : 0]     rom_addr,   // select ROM address
    input   wire    [7 : 0]     rom_bits,   // input bits from ROM
    output  reg     [0 : 0]     gfx,        // output pixel
    output  wire    [0 : 0]     in_progress // 0 if waiting for vstart
);
    // states for state machine
    localparam      WAIT_FOR_VSTART = 0,
                    WAIT_FOR_LOAD   = 1,
                    LOAD1_SETUP     = 2,
                    LOAD1_FETCH     = 3,
                    WAIT_FOR_HSTART = 4,
                    DRAW            = 5;
    
    reg     [2 : 0]     state;	    // current state #
    reg     [3 : 0]     ycount;	    // number of scanlines drawn so far
    reg     [3 : 0]     xcount;	    // number of horiz. pixels in this line
    reg     [7 : 0]     outbits;	// register to store bits from ROM
    
    // assign in_progress output bit
    assign in_progress = state != WAIT_FOR_VSTART;

    always @(posedge clk, posedge reset)
        if( reset ) 
        begin
            gfx      <= 0;
            state    <= WAIT_FOR_VSTART;
            ycount   <= 0;
            xcount   <= 0;
            outbits  <= 0;
            rom_addr <= 0;
        end 
        else 
        begin
            case( state )
                WAIT_FOR_VSTART: 
                begin
                    gfx     <= 0; // default pixel value (off)
                    ycount  <= 0; // initialize vertical count
                    // wait for vstart, then next state
                    if( vstart )
                        state <= WAIT_FOR_LOAD;
                end
                WAIT_FOR_LOAD: 
                begin
                    gfx     <= 0;
                    xcount  <= 0; // initialize horiz. count
                    // wait for load, then next state
                    if( load )
                        state <= LOAD1_SETUP;
                end
                LOAD1_SETUP: 
                begin
                    rom_addr <= ycount; // load ROM address
                    state    <= LOAD1_FETCH;
                end
                LOAD1_FETCH: 
                begin
                    outbits <= rom_bits; // latch bits from ROM
                    state   <= WAIT_FOR_HSTART;
                end
                WAIT_FOR_HSTART: 
                begin
                    // wait for hstart, then start drawing
                    if( hstart )
                        state <= DRAW;
                end
                DRAW: begin
                    // get pixel, mirroring graphics left/right
                    gfx     <= outbits[ xcount < 8 ? xcount[2 : 0] : ~ xcount[2 : 0] ];
                    xcount  <= xcount + 1;
                    // finished drawing horizontal slice?
                    if( xcount == 15 ) 
                    begin // pre-increment value
                        ycount <= ycount + 1'b1;
                        // finished drawing sprite?
                        if( ycount == 15 ) // pre-increment value
                            state <= WAIT_FOR_VSTART; // done drawing sprite
                        else
                            state <= WAIT_FOR_LOAD; // done drawing this scanline
                    end
                end
                // unknown state -- reset
                default: state <= WAIT_FOR_VSTART; 
            endcase
        end
  
endmodule // sprite_renderer
