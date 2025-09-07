module bhr_table (
    input logic         clk,
    input logic         reset,

    input logic [63:0]  pc_i,

    input logic         update_en_i,
    input logic [63:0]  pc_u_i,
    input logic         taken_u_i,

    output logic [9:0]  bhr_o
);

    (* ram_style = "distributed" *) logic [9:0] bhr_table [256];

    logic [9:0] bhr_rd;
    logic [7:0] rd_idx;
    logic [7:0] u_idx;

    //initialize bhr table to 0
    initial begin
        for (int i=0; i<256; i++) bhr_table[i] = '0;
    end

    assign rd_idx[7:0] = pc_i[9:2];
    assign u_idx[7:0]  = pc_u_i[9:2];

    assign bhr_rd[9:0] = bhr_table[rd_idx];

    always_ff @(posedge clk) begin
        if (update_en_i) begin
            bhr_table[u_idx] <= {taken_u_i, bhr_table[u_idx][9:1]};
        end 
    end

    //output assignment
    assign bhr_o[9:0] = bhr_rd[9:0];

endmodule