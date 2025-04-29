module regfile (
    input logic clk,
    input logic rst_sync,

    //source registers - addresses and data
    input logic [4:0]   rs1_addr_i,
    input logic [4:0]   rs2_addr_i,
    output logic [63:0] rs1_data_o,
    output logic [63:0] rs2_data_o,

    //destination registers - address, write enable, data
    input logic [4:0]   rd_addr_i,
    input logic         wr_en_i,
    input logic         rd_data_i
);

    logic [63:0] regfile [31:1];

    always_ff @(posedge clk or posedge reset) begin
        if (rst_sync) begin
            for (int i=0; i<32; i++) begin
                regfile[i] <= 64'b0;
            end
        end else if (wr_en_i && rd_addr_i != 5'b0) begin
            regfile[rd_addr_i] <= rd_data_i;
        end
    end

    //output assignments
    assign rs1_data_o = (rs1_addr_i == 5'b0) ? 64'b0 : regfile[rs1_addr_i];
    assign rs2_data_o = (rs2_addr_i == 5'b0) ? 64'b0 : regfile[rs2_addr_i];

endmodule