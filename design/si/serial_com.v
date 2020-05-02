// Ethan Weidman

`include "shift_reg.v"

`define IDLE 2'b00
`define SOF  2'b01
`define DATA 2'b11
`define EOF  2'b10
`define COUNT_LEN 8
`define ZERO_C `COUNT_LEN'b0
`define SOF_WORD 16'h5a5a
`define EOF_WORD 16'h0f0f
`define READ_CYCLE 5'b11111
`define READ_NEXT 5'b11110
`define R_EOF rdata[DSIZE-1]

module serial_com #(parameter DSIZE=32) (output reg s_out, r_en,
                                input [DSIZE:0] rdata,
                                input rempty, rclk, rrst_n);

// reg s_out, r_en;
reg sr_load, sr_en, b_en, b_eof;
reg [1:0] state, next;
reg [`COUNT_LEN-1:0] bit_counter;
reg [15:0] sr_in;
reg [DSIZE:0] buffer;
wire sr_out;
reg zero, fetch, word_out, words_out_2, words_out_5;
shift_reg sr (.sr_out(sr_out), .sr_in(sr_in), .sr_load(sr_load),
              .sr_en(sr_en), .rclk(rclk), .rrst_n(rrst_n));

always @(posedge rclk or negedge rrst_n)
begin
    if (!rrst_n)
    begin
        state <= 2'b0;
        bit_counter <= `ZERO_C;
        buffer <= {DSIZE+1{1'b0}};
        b_eof <= 1'b0;
    end
    else
    begin
        if (state != next)
            bit_counter <= `ZERO_C;
        else if (state != `IDLE)
            bit_counter <= bit_counter + 8'b1;
        state <= next;
        if (b_en)
        begin
            b_eof <= buffer[32];
            buffer <= rdata;
        end
    end
end

always @(*)
begin
    r_en = 1'b0; sr_en = 1'b1; sr_load = 1'b0;
    b_en = 1'b0;
    s_out = sr_out;
    next = state;
    sr_in = 16'b0;

    fetch = bit_counter[3:0] == 4'b1110;
    word_out = &bit_counter[3:0];
    words_out_2 = bit_counter[4] == 1'b1;
    words_out_5 = bit_counter[6] == 1'b1;

    case (state)
        `IDLE:
        begin
            s_out = 1'b0;
            if (!rempty)
            begin
                sr_load = 1'b1;
                sr_in = `SOF_WORD;
                next = `SOF;
            end
            else sr_en = 1'b0;
        end
        `SOF:
        begin
            sr_in = `SOF_WORD;
            if (words_out_2 & fetch)
                b_en = 1'b1;
            else if (words_out_2 & word_out)
            // if (words_out_2 & word_out)
            begin
                sr_load = 1'b1;
                next = `DATA;
                sr_in = buffer[15:0];
                r_en = 1'b1;
            end
            else if (word_out)
                sr_load = 1'b1;
        end
        `DATA:
        begin
            if (words_out_2 && fetch)
                b_en = 1'b1;
            else if (words_out_2 & word_out)
            begin
                sr_load = 1'b1;
                if (b_eof)
                begin
                    next = `EOF;
                    sr_in = `EOF_WORD;
                end
                else
                begin
                    sr_in = buffer[15:0];
                    r_en = 1'b1;
                end
            end
            else if (!words_out_2)
            begin
                if (bit_counter[3:0] == 4'b1111)
                    sr_load = 1'b1;
                sr_in = buffer[31:16];
            end
        end
        `EOF:
        begin
            sr_in = `EOF_WORD;
            if (bit_counter[6:0] == 7'b1001111 && !rempty)
            begin
                next = `SOF;
                sr_in = `SOF_WORD;
            end
            else if (bit_counter[6:0] == 7'b1001111)
            begin
                next = `IDLE;
            end
            if (bit_counter[3:0] == 4'b1111)
            begin
                sr_load = 1'b1;
            end
        end
    endcase
end

endmodule
