module resetn_sync (
    input logic     clk,
    input logic     aresetn_i,
    output logic    resetn_o
);
    (* ASYNC_REG = "TRUE" *) logic  aresetn_q;
    (* ASYNC_REG = "TRUE" *) logic  aresetn_2q;

    always_ff @(posedge clk or negedge aresetn_i) begin
        if (!areset_n_i) begin
            aresetn_q   <=  1'b0;
            aresetn_2q  <=  1'b0;
        end else begin
            aresetn_q   <=  1'b1;
            aresetn_2q  <=  aresetn_q;
        end
    end

    assign resetn_o =   aresetn_2q;

endmodule