
module RAM_sync
#(
    parameter                   A = 10, // # of address bits
                                D = 8   // # of data bits
)(
    input   wire    [0   : 0]   clk,    // clock
    input   wire    [A-1 : 0]   addr,   // address
    input   wire    [D-1 : 0]   din,    // data input
    output  reg     [D-1 : 0]   dout,   // data output
    input   wire    [0   : 0]   we      // write enable
);
   
    reg     [D-1 : 0]   mem [0 : ( 1 << A ) - 1]; // (1<<A)xD bit memory
      
    always @(posedge clk) 
    begin
        dout <= mem[addr];
        if( we )
            mem[addr] <= din;
    end

endmodule

module RAM_async
#(
    parameter                   A = 10, // # of address bits
                                D = 8   // # of data bits
)(
    input   wire    [0   : 0]   clk,    // clock
    input   wire    [A-1 : 0]   addr,   // address
    input   wire    [D-1 : 0]   din,    // data input
    output  wire    [D-1 : 0]   dout,   // data output
    input   wire    [0   : 0]   we      // write enable
);		
  
    reg     [D-1 : 0]   mem [0 : ( 1 << A ) - 1]; // (1<<A)xD bit memory

    assign dout = mem[addr]; // read memory to dout (async)
    
    always @(posedge clk)
        if( we )		// if write enabled
            mem[addr] <= din;	// write memory from din

endmodule

module RAM_async_tristate
#(
    parameter                   A = 10, // # of address bits
                                D = 8   // # of data bits
)(
    input   wire    [0   : 0]   clk, 
    input   wire    [A-1 : 0]   addr, 
    inout   wire    [D-1 : 0]   data, 
    input   wire    [0   : 0]   we
);
    
    reg     [D-1 : 0]   mem [0 : ( 1 << A ) - 1]; // (1<<A)xD bit memory
    
    assign data = !we ? mem[addr] : { D { 1'bz } }; // read memory to data (async)
    
    always @(posedge clk)
        if( we )
            mem[addr] <= data; // write memory from data

endmodule
