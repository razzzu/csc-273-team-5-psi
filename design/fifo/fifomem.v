module fifomem #(parameter DSIZE=32, ASIZE=32)
                (output reg [DSIZE-1:0] rdata, 
                input [DSIZE-1:0] wdata,
                input [ASIZE-1:0] raddr, waddr,
                input wfull, wclk, w_en
                );
    
    localparam MSIZE = 1<<ASIZE;
    reg [DSIZE-1:0] mem [0:MSIZE];

    always @(posedge wclk)
        if(w_en & ~wfull) 
            mem[waddr] <= wdata;

    always @(*) 
        rdata = mem[raddr];

endmodule