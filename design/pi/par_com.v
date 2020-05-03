// Raj Patel

`include "com_fsm.v"
module par_com #(parameter DSIZE=32) (output grant, w_en, output reg [DSIZE:0] wdata, output reg ready,
                input [DSIZE-1:0] data, input req, pkt_end, wfull, wclk, wrst_n);

    com_fsm com_fsm(.grant(grant), .w_en(w_en), .req(req), .wclk(wclk), .wrst_n(wrst_n));

    always @(*)
        wdata = {pkt_end, data};
    
    always @(*)
        ready = ~wfull;

endmodule