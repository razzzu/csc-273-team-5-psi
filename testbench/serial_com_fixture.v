// Ethan Weidman

`include "serial_com.v"

module serial_com_fixture;

integer index, dwords, pkts;
reg clk, rst, rempty;
reg [32:0] rdata;
reg [32:0] odata;
wire s_out, r_en;
reg [31:0] cmd_data, last_data;
reg [1:0] last_state;

serial_com s (.s_out(s_out), .r_en(r_en), .rdata(rdata),
        .rempty(rempty), .rclk(clk), .rrst_n(rst));

initial
begin
    $display("%20s STATE   DATA   DWORDS PKTS", "time");
    // $monitor($time, " %05d %08X",
    //     s.state, s.buffer[31:0]);
    // $monitor("%4d %b %b %032b %08x%c%08x|%08x %08x %b (%b%b) %b %b %b", $time, rst,
    //     {1'bz, s.state, s.next, 1'bz, s.bit_counter, 1'bz, s.sr.sr_en, s.sr.sr_load, s.sr.sr_in, 1'bz, s.sr.sr_reg, 1'bz, s_out, r_en, 1'bz, rdata, 1'bz},
    //     cmd_data, cmd_data, cmd_data == last_data ? "=" : " ",
    //     last_data, s.buffer[31:0], s.rdata[31:0], s.rdata[32], s.buffer[32], s.b_eof, s.b_en, s.r_en, rempty);
end
// time r state  counte
always @(posedge clk)
begin
    // cmd_data[31] = s_out;
    if (s.bit_counter[4:0] == 5'b0)
        if (last_state == `SOF && s.state == `DATA)
        begin
            if (cmd_data != 32'h5a5a5a5a)
            begin
                $display("Failed! %08x != %08x", cmd_data, 32'h5a5a5a5a);
                $finish();
            end
            else
                $display($time, " %5s %08x  %6d %4d", "SOF", cmd_data, dwords, pkts);
        end
        else if (last_state == `DATA && (s.state == `DATA || s.state == `EOF))
        begin
            if (cmd_data != last_data)
            begin
                $display("Failed! %08x != %08x", cmd_data, last_data);
                $finish();
            end
            else
            begin
                dwords = dwords + 1;
                $display($time, " %5s %08x  %6d %4d", "DATA", cmd_data, dwords, pkts);
            end
        end
        else if (last_state == `EOF && s.state == `EOF)
        begin
            if (cmd_data != 32'h0f0f0f0f)
            begin
                $display("Failed! %08x != %08x", cmd_data, 32'h0f0f0f0f);
                $finish();
            end
            else
                $display($time, " %5s %08x  %6d %4d", "EOF", cmd_data, dwords, pkts);
        end
        else if (last_state == `EOF && s.state != `EOF)
        begin
            if (cmd_data[31:16] != 16'h0f0f)
            begin
                $display("Failed! %04x != %04x", cmd_data[31:16], 16'h0f0f);
                $finish();
            end
            else
            begin
                pkts = pkts + 1;
                $display($time, " %5s %04x      %6d %4d", "EOF", cmd_data[31:16], dwords, pkts);
            end
            if (s.state == `IDLE)
                $display($time, " %5s %08x  %6d %4d", "IDLE", cmd_data, dwords, pkts);
        end
        else if (s.state == `IDLE && cmd_data[31] != 1'b0)
        begin
            $display("Failed! Expected 0 during idle, not %b", cmd_data[31]);
            $finish();
        end
    last_state = s.state;
    cmd_data = {s_out, cmd_data[31:1]};
end

always @(posedge clk)
begin
    // odata = odata >> 1;
    // odata[31] = s_out;
    if (s.b_en)
        last_data = s.buffer[31:0];
    if (r_en)
        if (rempty)
            rdata = {1'b0, $random};
        else
            rdata = {rdata[14] & rdata[15] & rdata[16], $random};
end

initial
begin
    cmd_data = 32'b0;
    last_data = 32'b0;
    dwords = 0; pkts = 0;
    rst = 1'b0; clk = 1'b0; rempty = 1'b0; rdata[31:0] = $random; rdata[32] = 1'b0;
    #1 rst = 1'b1;
    for (index = 0; index < 2048 && s.state != `EOF; index = index + 1)
    begin
        #1 clk = !clk;
        #1 clk = !clk;
    end
    rempty = 1'b1;
    for (index = 80 + $random % 512; index < 512; index = index + 1)
    begin
        #1 clk = !clk;
        #1 clk = !clk;
    end
    rempty = 1'b0;
    for (index = 0; index < 4096; index = index + 1)
    begin
        #1 clk = !clk;
        #1 clk = !clk;
    end
    #1 $finish;
end
endmodule