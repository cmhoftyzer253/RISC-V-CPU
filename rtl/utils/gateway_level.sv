module gateway_level #(
    parameter logic REQ_LEVEL = 1'b1
)(
    input logic     clk,
    input logic     resetn,

    input logic     complete_i,
    input logic     source_i,
    output logic    request_o
);

    logic           block_ff;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            block_ff    <=  1'b0;
        end else if (complete_i) begin
            block_ff    <=  1'b0;
        end else if (request_o) begin
            block_ff    <=  1'b1;
        end
    end

    assign request_o = !block_ff && (source_i == REQ_LEVEL);

endmodule