`include "par_com.v"
`include "dma_beh.v"
`include "fifo.v"

module pi_fixture;

    parameter DSIZE = 4, PSIZE=4, ASIZE=$clog2(PSIZE);
    wire req, pkt_end;
    wire [DSIZE-1:0] data;
    wire grant, w_en, ldata, ready, wfull;
    wire [DSIZE:0] wdata;
    reg  r_en,wclk, wrst_n;
    integer i=0;

    par_com #(.DSIZE(DSIZE)) dut(.wdata(wdata), .grant(grant), .data(data), .w_en(w_en), .ready(ready), .req(req), .pkt_end(pkt_end), .wfull(wfull), .wclk(wclk), .wrst_n(wrst_n));
    dma_beh #(.DSIZE(DSIZE), .PSIZE(PSIZE)) dma_beh(.data(data), .req(req), .pkt_end(pkt_end), .grant(grant), .ready(ready), .p_clk(wclk), .n_rst(wrst_n));
    fifo #(.DSIZE(DSIZE+1), .ASIZE(ASIZE)) fifo (.wfull(wfull), .wdata(wdata) , .w_en(w_en), .wclk(wclk), .wrst_n(wrst_n), .r_en(r_en) ,.rclk(wclk), .rrst_n(wrst_n));


    initial 
        $vcdpluson;

    initial
        $monitor($time, " | state:%b | grant:%b | req:%b | w_en:%b | wdata[4]:%b | pkt_end:%b | ready:%b | wfull:%b | wdata: %h| fifo_mem: %h %h %h %h| wptr: %b | wsync_rptr: %b"
                        , dut.com_fsm.state, grant, req, w_en, wdata[DSIZE], pkt_end, ready, wfull, wdata[DSIZE-1:0], 
                        fifo.fifomem.mem[3], fifo.fifomem.mem[2], fifo.fifomem.mem[1], fifo.fifomem.mem[0], fifo.wptr_full.wptr, fifo.wptr_full.wsync_rptr);

    initial begin
        wrst_n = 1'b0;
        r_en = 1'b0;
        #2;
        wrst_n = 1'b1;
        wclk = 1'b0;
        forever #5 wclk = ~wclk; 
    end

    initial begin
        for(i=0; i<PSIZE-1; i=i+1) begin
            dma_beh.mem[i] = {1'b0,$random};
            $display("mem[%b]: %h", i,dma_beh.mem[i]);
        end
            dma_beh.mem[i] = {1'b1,$random%DSIZE};
            $display("mem[%b]: %b", i,dma_beh.mem[i]);
        #3;
        dma_beh.count=2'b00;
        dma_beh.done=1'b0;
        @(posedge dma_beh.done)
        #2;
        dma_beh.idle=1'b1;
        dma_beh.done=1'b0;
        #45 r_en = 1'b1;
        #100 $finish;
    end

endmodule