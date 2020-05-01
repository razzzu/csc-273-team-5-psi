module com_fsm (output reg grant, w_en,
                input req, wclk, wrst_n);
    
    reg [1:0] state, next_state;
    parameter idle=2'b00, data=2'b01, rest_1=2'b11, rest_2=2'b10;

    always @(posedge wclk, negedge wrst_n)
        if (!wrst_n)    state <= idle;
        else            state <= next_state;

    always @(*) begin
        next_state = 2'bxx;
        grant=1'b0;
        w_en=1'b0;
        case(state)
            idle: if(req)   begin grant=1'b1;            next_state=data; end
                    else    begin                        next_state=idle; end 

            data: if(req)   begin grant=1'b1; w_en=1'b1; next_state=data; end
                    else    begin grant=1'b0; w_en=1'b1; next_state=rest_1; end

            rest_1: next_state=rest_2;
            rest_2: next_state=idle;
        endcase
    end


endmodule