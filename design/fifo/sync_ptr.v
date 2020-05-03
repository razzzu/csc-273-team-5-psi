// Raj Patel
// Reference: Clifford E. Cummings, Simulation and Synthesis Techniques for Asynchronous FIFO Design
// http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf

module sync_ptr #(parameter ASIZE=32)
                (output reg [ASIZE:0] sync_ptr,
                input [ASIZE:0] ptr,
                input sync_clk, sync_rst);

    reg [ASIZE:0] t_ptr;

    always @(posedge sync_clk, negedge sync_rst)
        if(!sync_rst) {sync_ptr, t_ptr} <= 0;
        else        {sync_ptr, t_ptr} <= {t_ptr,ptr};

endmodule