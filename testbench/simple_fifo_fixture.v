`include "simple_fifo.v"

module simple_fifo_fixture;

reg clk, rst, push, pop;
reg [`W:0] in_data;
wire [`W:0] out_data;
wire full, empty;

integer cycle;

simple_fifo f (.in_data(in_data), .push(push), .pop(pop),
        .out_data(out_data), .full(full), .empty(empty),
        .clk(clk), .rst(rst));

initial
begin
    $monitor("%4d %b %b %b %08x %b %08x %b %b %4d %4d %08x %08x %08x %08x",
        $time, clk, rst, push, in_data,
        pop, out_data, full, empty,
        f.fifo_head, f.fifo_tail,
        f.fifo_mem[0], f.fifo_mem[1], f.fifo_mem[2], f.fifo_mem[3]);
end

task push_data;
begin
    #1 clk = 1'b1;
    in_data = $random; push = 1'b1;
    #1 clk = 1'b0; push = 1'b0;
end
endtask

task pop_data;
begin
    #1 clk = 1'b1; pop = 1'b1;
    #1 clk = 1'b0;
    pop = 1'b0;
end
endtask

task push_pop;
begin
    push_data;
    pop_data;
end
endtask

initial
begin
    rst = 1'b0; clk = 1'b0; push = 1'b0; pop = 1'b0;
    in_data = 32'b0;
    #1 rst = 1'b1;
    push_data;
    push_data;
    push_data;
    push_data;
    push_data;
    pop_data;
    pop_data;
    for (cycle = 0; cycle < 16; cycle = cycle + 1)
        push_pop;
    pop_data;
    #1 $finish;
end

endmodule