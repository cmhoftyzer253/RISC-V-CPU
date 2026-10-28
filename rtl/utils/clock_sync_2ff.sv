module clk_sync_2ff #(
    parameter int WIDTH = 1
) (
    input logic                 clk,
    input logic                 resetn,
    input logic [WIDTH-1:0]     d_i,
    output logic [WIDTH-1:0]    q_o
);

    (* ASYNC_REG = "TRUE" *) logic [WIDTH-1:0]  d_q;
    (* ASYNC_REG = "TRUE" *) logic [WIDTH-1:0]  d_q2;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            d_q     <=  '0;
            d_2q    <=  '0;
        end else begin
            d_q     <=  d_i;
            d_2q    <=  d_q;
        end
    end

    assign q_o  =   d_2q;

endmodule