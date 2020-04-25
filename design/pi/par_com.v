`include "com_fsm.v"
module par_com (output grant, w_en, output reg ldata, ready,
                input req, pkt_end, wfull, wclk, wrst_n);

    com_fsm com_fsm(.grant(grant), .w_en(w_en), .req(req), .wclk(wclk), .wrst_n(wrst_n));

    always @(*)
        ldata = ~pkt_end;  
    
    always @(*)
        ready = ~wfull;

endmodule