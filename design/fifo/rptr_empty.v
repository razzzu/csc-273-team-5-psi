// Raj Patel
// Reference: Clifford E. Cummings, Simulation and Synthesis Techniques for Asynchronous FIFO Design
// http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf

module rptr_empty #(parameter ASIZE=32) 
                    (output reg rempty,
                    output reg [ASIZE-1:0] raddr,
                    output reg [ASIZE:0] rptr,
                    input [ASIZE:0] rsync_wptr,
                    input r_en, rclk, rrst_n);

    reg [ASIZE:0] next_rptr;
    reg next_rempty;

    always @ (posedge rclk, negedge rrst_n) begin
        if(!rrst_n) rptr <= 0;
        else        rptr <= next_rptr;
    end

    always @ (*) begin
        next_rptr = rptr + (~rempty & r_en);    
    end

    always @ (posedge rclk, negedge rrst_n) begin
        if(!rrst_n) rempty <= 1'b1;
        else        rempty <= next_rempty;
    end

    always @ (*) begin
        next_rempty = (next_rptr == rsync_wptr);
    end

    always @ (*) begin
        raddr = rptr[ASIZE-1:0];
    end


endmodule