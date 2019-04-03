
module tile_renderer
(
    input   wire    [0  : 0]    clk, 
    input   wire    [0  : 0]    reset, 
    input   wire    [15 : 0]    hpos, 
    input   wire    [15 : 0]    vpos,                 
    output  wire    [2  : 0]    rgb,
    output  reg     [15 : 0]    ram_addr, 
    input   wire    [15 : 0]    ram_read, 
    output  reg     [0  : 0]    ram_busy,
    output  wire    [10 : 0]    rom_addr, 
    input   wire    [7  : 0]    rom_data
);
    /*******************************************************
    *                 PARAMS & LOCALPARAMS                 *
    *******************************************************/
    // start loading cells from RAM at this hpos value
    // first column read will be ((HLOAD-2) % 32)
    parameter HLOAD = 272;
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    wire    [7  : 0]    page_base;	// page table base (8 bits)
    reg     [15 : 0]    row_base;   // row table base (16 bits)
    reg     [4  : 0]    row;        // 5-bit row, vpos / 8
    wire    [4  : 0]    col;	    // 5-bit column, hpos / 8
    wire    [2  : 0]    yofs;       // scanline of cell (0-7)
    wire    [2  : 0]    xofs;       // which pixel to draw (0-7)
    
    reg     [15 : 0]    cur_cell;
    wire    [7  : 0]    cur_char;
    wire    [7  : 0]    cur_attr;

    reg     [15 : 0]    row_buffer [0 : 31];
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    // tile ROM address
    assign page_base = 8'h7e;
    assign col       = hpos[7 : 3];
    assign yofs      = vpos[2 : 0];
    assign xofs      = hpos[2 : 0];
    assign cur_char  = cur_cell[7  : 0];
    assign cur_attr  = cur_cell[15 : 8];
    assign rom_addr  = {cur_char, yofs};
    assign rgb       = rom_data[ ~ xofs ] ? cur_attr[0 +: 3] : cur_attr[4 +: 3];
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
    // lookup char and attr
    always @(posedge clk, posedge reset) 
        if( reset )
        begin
            row <= 0;
            ram_addr <= 0;
            row_base <= 0;
            ram_busy <= 0;
            cur_cell <= 0;
        end
        else
        begin
            // reset row to 0 when last row displayed
            if( vpos == 248 ) 
            begin
                row <= 0;
            end
            // time to read a row?
            if( vpos[2 : 0] == 7 ) 
            begin
                // read row_base from page table (2 bytes)
                case (hpos)
                    // assert busy 5 cycles before first RAM read
                    HLOAD-8     :   begin   ram_busy <= 1;                              end 
                    // read page base for row
                    HLOAD-3     :   begin   ram_addr <= { page_base , 3'b000 , row };   end 
                    HLOAD-1     :   begin   row_base <= ram_read;                       end 
                    // deassert BUSY and increment row counter
                    HLOAD+34    :   begin   ram_busy <= 0;  row <= row + 1;             end
                endcase
                // load row of tile data from RAM
                // (last two twice)
                if( ( hpos >= HLOAD ) && ( hpos < HLOAD+34 ) ) 
                begin
                    ram_addr <= row_base + hpos[4 : 0];
                    row_buffer[ hpos[4 : 0] - 5'd2 ] <= ram_read;
                end
            end
            // latch character data
            if( hpos < 640 ) 
            begin
                if( hpos[2:0] == 7 )
                    cur_cell <= row_buffer[col+1];
            end 
            else 
                if( hpos == 700 ) 
                    cur_cell <= row_buffer[0];
        end
  
endmodule

