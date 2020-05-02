module serial_com #(parameter DSIZE=32) (output s_out, r_en,
                                input [DSIZE:0] rdata,
                                input rempty, rclk, rrst_n);

reg s_out, r_en;
reg [3:0] state;
reg [7:0] bit_counter;
reg [16:1] shift_register;

always @(posedge rclk or negedge rrst_n)
begin
    if (!rrst_n)
    begin
        state <= 4'b0;
        bit_counter <= 8'b11111111;
        shift_register <= 16'b01110;
    end
    else
    begin
        if (state == 4'b0000)
        begin
            bit_counter <= 8'b11111111;
        end
        else
        begin
            if (bit_counter[3:0] == 4'b1111)
            begin
                if (state == 4'b0001)
                    shift_register[16:1] <= 16'h5a5a;
                else if (state == 4'b0010 && bit_counter[4])
                    shift_register[16:1] <= rdata[31:16];
                else if (state == 4'b0010)
                    shift_register[16:1] <= rdata[15:0];
                else if (state == 4'b0011)
                    shift_register[16:1] <= 16'h0f0f;
                else
                    shift_register[16:1] <= 16'h1234;
            end
            else
                shift_register <= shift_register >> 1;
            bit_counter <= bit_counter + 1;
        end
    end
end

always @(*)
begin
    s_out = shift_register[1]; r_en = 1'b0;
    case (state)
        4'b0000:
            if (!rempty) state = 4'b0001;
        4'b0001:
            if (bit_counter[5:4] == 2'b10)
            begin
                state = 4'b0010;
                bit_counter = 8'b11111111;
            end
        4'b0010:
            if (bit_counter[5:4] == 2'b10 && rdata[32])
            begin
                state = 4'b0011;
                bit_counter = 8'b11111111;
            end
            else if (bit_counter[5:4] == 2'b10)
            begin
                r_en = 1'b1;
            end
        4'b0011:
            if (bit_counter[6:4] == 3'b100 && !rempty)
            begin
                state = 4'b0001;
                bit_counter = 8'b11111111;
            end
            else if (bit_counter[6:4] == 3'b100)
            begin
                state = 4'b0000;
                bit_counter = 8'b11111111;
            end
    endcase
end

endmodule
