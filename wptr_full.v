module wptr_full #(parameter ASIZE=32)
                    (output reg wfull,
                    output reg [ASIZE-1:0] waddr,
                    output reg [ASIZE:0] wptr,
                    input [ASIZE:0] wsync_rptr,
                    input w_en, wclk, wrst_n);
    
    reg [ASIZE:0] next_wptr;
    reg next_wfull;

    always @ (posedge wclk, negedge wrst_n) begin
        if(!wrst_n) wptr <= 0;
        else        wptr <= next_wptr; 
    end

    always @ (*) begin
        next_wptr = wptr + (~wfull & w_en);
    end

    always @ (posedge wclk, negedge wrst_n) begin
        if(!wrst_n) wfull <= 0;
        else        wfull <= next_wfull;
    end

    always @(*)
        next_wfull = ((wsync_rptr[ASIZE-1:0]==next_wptr[ASIZE-1:0]) && (wsync_rptr[ASIZE]!=next_wptr[ASIZE]));

    always @ (*)
        waddr = wptr[ASIZE-1:0];


endmodule