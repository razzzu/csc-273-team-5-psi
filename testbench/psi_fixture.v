`include "psi.v"
`include "dma_beh.v"

module psi_fixture;

    parameter DSIZE=32, ASIZE=4, PSIZE=2;
    
    integer i, j;
    integer dma_compare_index, dwords, pkts;
    wire [DSIZE-1:0] data;
    wire req, grant, pkt_end, ready, s_data;
    reg [DSIZE-1:0] dma_compare_data;
    reg [DSIZE-1:0] s_compare_data;
    reg en, p_clk, s_clk, n_rst;
    reg [1:0] last_state;



    psi #(.DSIZE(DSIZE), .ASIZE(ASIZE)) dut (.s_data(s_data), .data(data), .req(req), .grant(grant), .pkt_end(pkt_end), .ready(ready), .p_clk(p_clk), .s_clk(s_clk), .n_rst(n_rst));
    dma_beh #(.DSIZE(DSIZE), .PSIZE(PSIZE)) dma (.data(data), .req(req), .en(en), .grant(grant), .ready(ready), .pkt_end(pkt_end), .p_clk(p_clk), .n_rst(n_rst));

    initial
        $monitor($time, " | state:%b | grant:%b | req:%b | en:%b | pkt_end:%b | ready:%b | wfull:%b | fifo_mem: %h %h %h %h | rptr:%02h | wptr:%02h | dma.count: %d | s_data:%b"
                            , dut.par_com.com_fsm.state, grant, req, en, pkt_end, ready, dut.wfull, 
                            dut.fifo.fifomem.mem[3], dut.fifo.fifomem.mem[2], dut.fifo.fifomem.mem[1], dut.fifo.fifomem.mem[0], dut.fifo.raddr, dut.fifo.waddr, dma.count, s_data);

    // Parallel clock
    initial begin
        p_clk = 1'b0;
        forever #5 p_clk = ~p_clk;
    end

    // Serial clock
    initial begin
        s_clk=1'b0;
        forever #5 s_clk = ~s_clk;
    end

    // Fill dma with data to send to psi
    initial begin
        fill_dma;
        dwords = 0; pkts = 0; dma_compare_index = 0;
        s_compare_data = {DSIZE{1'b0}};
        n_rst = 1'b0;
        #1 dma_compare_data = dma.mem[dma_compare_index][DSIZE-1:0];
        n_rst = 1'b1;
        #1 send_packet(.n(2));
        // #512 $finish;
    end
    initial
        #4096 $finish;


    task fill_dma;
    begin
        for (i=0; i<PSIZE; i=i+1) begin
            // dma.mem[i][DSIZE] = ($random%2) == 1;
            dma.mem[i][DSIZE] = 1'b1;
            dma.mem[i][DSIZE-1:0] = $random;
            // dma.mem[i][DSIZE] = &dma.mem[i][1:0];
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

    task inc_dma_compare;
    begin
        dma_compare_index = dma_compare_index + 1;
        dma_compare_data = dma.mem[dma_compare_index][DSIZE-1:0];
    end
    endtask
    
    always @(posedge s_clk)
    begin
        // s_compare_data[31] = s_out;
        if (dut.serial_com.bit_counter[4:0] == 5'b0)
            if (last_state == `SOF && dut.serial_com.state == `DATA)
            begin
                if (s_compare_data != 32'h5a5a5a5a)
                begin
                    $display("Failed! %08x != %08x", s_compare_data, 32'h5a5a5a5a);
                    $finish();
                end
                else
                begin
                    $display($time, " si.state:%5s dword_out:%08x  total_dwords:%6d total_packets:%4d", "SOF", s_compare_data, dwords, pkts);
                end
            end
            else if (last_state == `DATA && (dut.serial_com.state == `DATA || dut.serial_com.state == `EOF))
            begin
                if (s_compare_data != dma_compare_data)
                begin
                    $display("Failed! %08x != %08x", s_compare_data, dma_compare_data);
                    $finish();
                end
                else
                begin
                    dwords = dwords + 1;
                    inc_dma_compare;
                    $display($time, " si.state:%5s dword_out:%08x  total_dwords:%6d total_packets:%4d", "DATA", s_compare_data, dwords, pkts);
                end
            end
            else if (last_state == `EOF && dut.serial_com.state == `EOF)
            begin
                if (s_compare_data != 32'h0f0f0f0f)
                begin
                    $display("Failed! %08x != %08x", s_compare_data, 32'h0f0f0f0f);
                    $finish();
                end
                else
                    $display($time, " si.state:%5s dword_out:%08x  total_dwords:%6d total_packets:%4d", "EOF", s_compare_data, dwords, pkts);
            end
            else if (last_state == `EOF && dut.serial_com.state != `EOF)
            begin
                if (s_compare_data[31:16] != 16'h0f0f)
                begin
                    $display("Failed! %04x != %04x", s_compare_data[31:16], 16'h0f0f);
                    $finish();
                end
                else
                begin
                    pkts = pkts + 1;
                    $display($time, " si.state:%5s  word_out:%04x      total_dwords:%6d total_packets:%4d", "EOF", s_compare_data[31:16], dwords, pkts);
                end
                if (dut.serial_com.state == `IDLE)
                    $display($time, " si.state:%5s dword_out:%08x  total_dwords:%6d total_packets:%4d", "IDLE", s_compare_data, dwords, pkts);
            end
            else if (dut.serial_com.state == `IDLE && s_compare_data[31] != 1'b0)
            begin
                $display("Failed! Expected 0 during idle, not %b", s_compare_data[31]);
                $finish();
            end
        last_state = dut.serial_com.state;
        s_compare_data = {s_data, s_compare_data[31:1]};
    end

endmodule