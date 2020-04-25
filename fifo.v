`include "sync_ptr.v"
`include "wptr_full.v"
`include "rptr_empty.v"
`include "fifomem.v"

module fifo #(parameter DSIZE = 32, ASIZE = 32) 
            (output [DSIZE-1:0] rdata,
             output wfull,
             output rempty,
             input [DSIZE-1:0] wdata,
             input  w_en, wclk, wrst_n, r_en, rclk, rrst_n);

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0]  wptr, rptr, wsync_rptr, rsync_wptr;

    sync_ptr #(.ASIZE(ASIZE))  sync_r2w (.sync_ptr(wsync_rptr), .ptr(rptr), .sync_clk(wclk), .sync_rst(wrst_n));
    sync_ptr #(.ASIZE(ASIZE))  sync_w2r (.sync_ptr(rsync_wptr), .ptr(wptr), .sync_clk(rclk), .sync_rst(rrst_n));

    fifomem #(.DSIZE(DSIZE), .ASIZE(ASIZE)) fifomem (.rdata(rdata), .wdata(wdata), .waddr(waddr), .raddr(raddr), .w_en(w_en), .wfull(wfull), .wclk(wclk));

    rptr_empty #(.ASIZE(ASIZE)) rptr_empty (.rempty(rempty), .raddr(raddr), .rptr(rptr), .rsync_wptr(rsync_wptr), .r_en(r_en), .rclk(rclk), .rrst_n(rrst_n));
    wptr_full  #(.ASIZE(ASIZE)) wptr_full  (.wfull(wfull),   .waddr(waddr), .wptr(wptr), .wsync_rptr(wsync_rptr), .w_en(w_en), .wclk(wclk), .wrst_n(wrst_n));

endmodule