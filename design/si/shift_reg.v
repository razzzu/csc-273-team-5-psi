// Ethan Weidman

// There were no papers for this outside of application specific dealing with feedback
// While searching I found a solution, here is the reference:
// B. Cohen, Real Chip Design and Verification Using Verilog and VHDL
// https://books.google.com/books?hl=en&lr=&id=aQd4QYNV88EC

module shift_reg #(parameter SSIZE=16) (output reg sr_out, input [SSIZE-1:0] sr_in,
                  input sr_load, sr_en, rclk, rrst_n);

reg [SSIZE-1:0] sr_reg;

always @(posedge rclk or negedge rrst_n)
begin
    if (!rrst_n)
        sr_reg <= {SSIZE{1'b0}};
    else if (sr_load)
        sr_reg <= sr_in;
    else if (sr_en)
        sr_reg <= sr_reg >> 1;
end

always @(*)
    sr_out = sr_reg[0];

endmodule