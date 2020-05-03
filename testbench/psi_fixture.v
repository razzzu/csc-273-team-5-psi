`include "psi.v"
`include "dma_beh.v"

module psi_fixture;

    parameter DSIZE=32, ASIZE=4, PSIZE=32;
    
    integer i, j;
    wire [DSIZE-1:0] data;
    wire req, grant, pkt_end, ready, s_data;
    reg en, p_clk, s_clk, n_rst;



    psi #(.DSIZE(DSIZE), .ASIZE(ASIZE)) dut (.s_data(s_data), .data(data), .req(req), .grant(grant), .pkt_end(pkt_end), .ready(ready), .p_clk(p_clk), .s_clk(s_clk), .n_rst(n_rst));
    dma_beh #(.DSIZE(DSIZE), .PSIZE(PSIZE)) dma (.data(data), .req(req), .en(en), .grant(grant), .ready(ready), .pkt_end(pkt_end), .p_clk(p_clk), .n_rst(n_rst));

    initial
        $monitor($time, " | state:%b | grant:%b | req:%b | en:%b | pkt_end:%b | ready:%b | wfull:%b | fifo_mem: %h %h %h %h | dma.count: %d | s_data:%b|"
                            , dut.par_com.com_fsm.state, grant, req, en, pkt_end, ready, dut.wfull, 
                            dut.fifo.fifomem.mem[3], dut.fifo.fifomem.mem[2], dut.fifo.fifomem.mem[1], dut.fifo.fifomem.mem[0], dma.count, s_data);

    initial begin
        n_rst = 1'b0;
        #2 n_rst = 1'b1;
        p_clk = 1'b0;
        forever #5 p_clk = ~p_clk;
    end

    
    initial begin
        #4 s_clk=1'b0;
        forever #5 s_clk = ~s_clk;
    end

    initial begin
        fill_dma;
        #2;
        send_packet(.n(1));
        #500 $finish;
    end

    task fill_dma;
    begin
        for (i=0; i<PSIZE; i=i+1) begin
            {dma.mem[i][DSIZE],dma.mem[i][DSIZE-1:0]} = {$random%2,$random};
            $display("mem[%d]: %h", i,dma.mem[i]);
        end    
    end
    endtask

    task send_packet (input integer n);
    begin
        en=1'b1;
        if (n==1) begin
            @(posedge p_clk) en=1'b0;
        end
        else 
        begin
            while (n>1) begin
                @(posedge p_clk) begin
                    if (!dma.idle && pkt_end) n=n-1;
                end
            end
        en = 1'b0;
        end
    end
    endtask

endmodule