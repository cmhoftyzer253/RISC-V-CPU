module resetn_sync (
    input logic     clk,
    input logic     aresetn_i,
    output logic    resetn_o
);
    (* ASYNC_REG = "TRUE" *) logic  aresetn_q   =   1'b0;
    (* ASYNC_REG = "TRUE" *) logic  aresetn_2q  =   1'b01;

    always_ff @(posedge clk) begin
        aresetn_q   <=  aresetn_i;
        aresetn_2q  <=  aresetn_q;
    end

    assign resetn_o =   aresetn_2q;

endmodule