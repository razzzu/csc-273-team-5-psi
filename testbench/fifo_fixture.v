//Raj Patel

`include "fifo.v"
// `include "beh_fifo.v"

module fifo_fixture();

    parameter ASIZE=2, DSIZE=16;
    parameter wdelay=3, rdelay=5;
    reg [DSIZE-1:0] wdata;
    reg w_en, r_en, wclk, rclk, wrst_n, rrst_n;
    wire [DSIZE-1:0] rdata, rdata_beh;
    wire rempty, wfull, rempty_beh, wfull_beh;

    fifo #(.ASIZE(ASIZE), .DSIZE(DSIZE)) dut (.wdata(wdata), .w_en(w_en), .r_en(r_en), .wclk(wclk), .rclk(rclk), .wrst_n(wrst_n), .rrst_n(rrst_n), .rdata(rdata), .rempty(rempty), .wfull(wfull));
    // beh_fifo #(.ASIZE(ASIZE), .DSIZE(DSIZE)) beh (.wdata(wdata), .w_en(w_en), .r_en(r_en), .wclk(wclk), .rclk(rclk), .wrst_n(wrst_n), .rrst_n(rrst_n), .rdata(rdata_beh), .rempty(rempty_beh), .wfull(wfull_beh));

    initial
        $vcdpluson;
    
    // initial
    //     $monitor($time," | MEM: %h %h %h %h | MEM_beh: %h %h %h %h |wdata: %h | rdata: %h | rdata_beh: %h| wptr: %b| wptr_beh: %b", 
    //                     dut.fifomem.mem[3], dut.fifomem.mem[2], dut.fifomem.mem[1], dut.fifomem.mem[0],
    //                     beh.ex_mem[3], beh.ex_mem[2], beh.ex_mem[1], beh.ex_mem[0],
    //                     wdata, rdata, rdata_beh, dut.wptr, beh.wptr);

    initial
        $monitor($time," | MEM: %h %h %h %h | wdata:%h | w_en:%b | wptr:%b| wsync_rptr:%b| rdata:%h | r_en:%b |rptr:%b | rsync_wptr: %b | wfull:%b | rempty:%b", 
                        dut.fifomem.mem[3], dut.fifomem.mem[2], dut.fifomem.mem[1], dut.fifomem.mem[0],
                        wdata, w_en, dut.wptr, dut.wsync_rptr, rdata, r_en, dut.rptr, dut.rsync_wptr, wfull, rempty);

    initial begin
        
        {w_en, r_en, wrst_n, rrst_n} = 4'b0000;
        #2;
        {wrst_n, rrst_n} = 2'b11;
        rclk = 1'b0;
        forever #(rdelay) rclk = ~rclk;
    end

    initial begin
        #2;
        wclk = 1'b0;
        forever #(wdelay) wclk = ~wclk;
    end

    initial begin
        fill_n(4);
        read_n(3);
        fill_n(4);
        read_n(6);
    end

    initial 
        #200 $finish;

    task fill_n (input integer n);
    begin
        repeat(n) begin 
            @(negedge wclk) #(3*wdelay/4) w_en = 1'b1; wdata=$random;
        end
        w_en = 1'b0;
    end
    endtask   

    task read_n (input integer n);
    begin
        r_en = 1'b1;
        repeat(n) @(posedge rclk);
        r_en = 1'b0;
    end
    endtask     

endmodule