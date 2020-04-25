module sync_ptr_2_clk #(parameter ASIZE=32)
                (output reg [ASIZE:0] sync_ptr,
                input [ASIZE:0] ptr,
                input l_clk, l_rst, c_clk, c_rst);

    reg [ASIZE:0] t_ptr;

    always @(posedge l_clk, negedge l_rst)
        if(!l_rst) t_ptr <= 0;
        else     t_ptr <= ptr;

    always @(posedge c_clk, negedge c_rst)
        if(!c_rst)  sync_ptr <= 0;
        else        sync_ptr <= t_ptr;

endmodule