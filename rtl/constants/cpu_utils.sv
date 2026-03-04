package cpu_utils
    function automatic logic [2:0] exc_priority_encode (input logic [4:0] exc_code);
        begin
            case (exc_code)
                5'd3:   return 3'd0; 
                5'd1:   return 3'd1; 
                5'd2:   return 3'd2; 
                5'd0:   return 3'd3; 
                5'd11:  return 3'd4; 
                5'd4, 5'd6: return 3'd5; 
                5'd5, 5'd7: return 3'd6; 
                default: return 3'd7;
            endcase 
        end
    endfunction

endpackage

//send interrupt requests on positive edges of switches
module irq_sw_gw (
    input logic     clk,
    input logic     resetn,

    input logic     signal_i,
    output logic    gw_irq_o
);

    always_ff @(posedge clk or negedge reset) begin
        if (~resetn) begin
            signal_q    <=  1'b0;
        end else begin
            signal_q    <=  signal_i;
        end
    end

    assign gw_irq_o     =   signal_i & ~signal_q;

endmodule

