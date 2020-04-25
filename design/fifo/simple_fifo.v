`define W 31
`define L 2
module simple_fifo (in_data, push, pop, out_data, full, empty, clk, rst);
input push, pop, clk, rst;
input  [`W:0] in_data;
output [`W:0] out_data;
output full, empty;

reg [`W:0] out_data;
reg full, empty;

// Can use a "fifo_counter" with 0 meaning empty and all 1's as full, but lose async
reg [`L-1:0] fifo_head, fifo_tail;
reg [`W:0] fifo_mem [(1<<`L)-1:0];

always @(posedge clk or negedge rst)
begin
    out_data = 32'b0;
    if (!rst)
    begin
        fifo_head = `L'd0;
        fifo_tail = `L'd0;
    end
    else
    begin 
        if (push)
        begin
            fifo_mem[fifo_tail] <= in_data;
            fifo_tail <= fifo_tail + `L'd1;
        end
        if (pop)
        begin
            out_data <= fifo_mem[fifo_head];
            fifo_head <= fifo_head + `L'd1;
        end
    end
    
end

always @(*)
begin
    empty = 1'b0;
    full = 1'b0;
    if (fifo_head == fifo_tail)
        empty = 1'b1;
    if (fifo_head == fifo_tail + `L'd1)
        full = 1'b1;
end

endmodule