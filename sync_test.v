`include "sync_ptr.v"
`include "sync_ptr_2_clk.v"

module sync_test;

    parameter wdelay=5, rdelay=3;

    reg [2:0] rptr;
    reg wclk, wrst, rclk, rrst;
    wire [2:0] wsync_rptr_beh, wsync_rptr_test;

    sync_ptr #(.ASIZE(2)) sync_beh ( .sync_ptr(wsync_rptr_beh), .ptr(rptr), .sync_clk(wclk), .sync_rst(wrst));
    sync_ptr_2_clk #(.ASIZE(2)) sync_test (.sync_ptr(wsync_rptr_test), .ptr(rptr), .l_clk(rclk), .l_rst(rrst), .c_clk(wclk), .c_rst(wrst));

    always@(posedge rclk, negedge rrst)
        if(!rrst)   rptr <= 0;
        else        rptr <= rptr + 1;

    initial 
        $vcdpluson;

    initial begin        
        {wrst, rrst} = 2'b00;
        #2;
        {wrst, rrst} = 2'b11;
        rclk = 1'b0;
        forever #(rdelay) rclk = ~rclk;
    end

    initial begin
        #2;
        wclk = 1'b0;
        forever #(wdelay) wclk = ~wclk;
    end

    initial
        #100 $finish;


endmodule