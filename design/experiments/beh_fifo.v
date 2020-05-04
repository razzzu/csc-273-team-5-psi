// Raj Patel
//This module is NOT Synthesisable
module beh_fifo #(parameter DSIZE=8, ASIZE=4) 
                (output [DSIZE-1:0] rdata, 
                output wfull, rempty ,
                input [DSIZE-1:0] wdata,
                input w_en, wclk, wrst_n, r_en, rclk, rrst_n);

    reg [ASIZE:0] wptr, wrptr1, wrptr2, wrptr3;
    reg [ASIZE:0] rptr, rwptr1, rwptr2, rwptr3;

    parameter DEPTH = 1<<ASIZE;
    reg [DSIZE-1:0] ex_mem [0:DEPTH-1];

    always @(posedge wclk, negedge wrst_n) begin
        if (!wrst_n)    wptr <=0;
        else if (w_en && !wfull) begin
            ex_mem[wptr[ASIZE-1:0]] <= wdata;
            wptr <= wptr+1;
        end
    end

    always @(posedge wclk, negedge wrst_n) begin
        if (!wrst_n)    {wrptr3,wrptr2,wrptr1} <= 0;
        else            {wrptr3,wrptr2,wrptr1} <= {wrptr2,wrptr1,rptr};
    end

    always @(posedge rclk, negedge rrst_n) begin
        if (!rrst_n)    rptr <= 0;
        else if(r_en && !rempty) rptr <= rptr + 1;
    end

    always @(posedge rclk, negedge rrst_n) begin
        if (!rrst_n)    {rwptr3,rwptr2,rwptr1} <= 0;
        else            {rwptr3,rwptr2,rwptr1} <= {rwptr2,rwptr1,wptr};
    end

    assign rdata = ex_mem[rptr[ASIZE-1:0]];
    assign rempty = (rptr == rwptr3);
    assign wfull = ((wptr[ASIZE] != wrptr3[ASIZE]) && (wptr[ASIZE-1:0] == wrptr3[ASIZE-1:0]));

endmodule