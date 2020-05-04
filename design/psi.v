// Raj Patel

`include "par_com.v"
`include "serial_com.v"
`include "fifo.v"

module psi #(parameter DSIZE=32, ASIZE=5) (output s_data, grant, ready,
                                            input [DSIZE-1:0] data,      
                                            input req, pkt_end, p_clk, s_clk, n_rst);

    wire [DSIZE:0] wdata, rdata;
    wire w_en, wfull, r_en, rempty;

    par_com #(.DSIZE(DSIZE)) par_com (.wdata(wdata), .grant(grant), .w_en(w_en), .ready(ready), .data(data), .req(req), .pkt_end(pkt_end), .wfull(wfull), .wclk(p_clk), .wrst_n(n_rst));
    fifo #(.DSIZE(DSIZE+1), .ASIZE(ASIZE)) fifo (.rdata(rdata), .rempty(rempty), .wfull(wfull), .wdata(wdata), .w_en(w_en), .r_en(r_en), .wclk(p_clk), .rclk(s_clk), .wrst_n(n_rst), .rrst_n(n_rst));
    serial_com #(.DSIZE(DSIZE)) serial_com (.s_out(s_data), .r_en(r_en), .rdata(rdata), .rempty(rempty), .rclk(s_clk), .rrst_n(n_rst));

endmodule