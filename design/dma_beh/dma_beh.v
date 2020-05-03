//This module is NOT for synthesis

module dma_beh #(parameter DSIZE=32, PSIZE=4)(output reg [DSIZE-1:0] data, output reg req, pkt_end,
                            input en, grant, ready, p_clk, n_rst);
    
    localparam PBITS = $clog2(PSIZE);
    reg [DSIZE:0] mem [0:PSIZE-1];
    reg [PBITS-1:0] count;
    reg done, last, idle;
    
    always @(posedge p_clk, negedge n_rst)
        if(!n_rst)
            {done, count} <= 0;
        else if (!done && !idle && ready && (grant || last))
            {done, count} <= count + 1;

    always @(posedge p_clk, negedge n_rst)
        if(!n_rst)
            idle <= 1'b1;
        else if(grant)
            idle <= 1'b0;
        else 
            idle <= 1'b1;

    always @(*) begin 
        req=1'b1;
        if(idle && !en) req=1'b0;
        if(!idle && last && ready) req=1'b0;
        if(done) req=1'b0;
    end

    always @(*)
        last = ( (pkt_end && !en) || &count);

    always @(*)
        {pkt_end, data} = mem[count];


endmodule