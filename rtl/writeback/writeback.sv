import cpu_consts::*;

module writeback (
    input logic [63:0] alu_res_i,
    input logic [63:0] data_mem_rd_i,
    input logic [63:0] instr_imm_i,
    input logic [63:0] pc_val_i,

    input logic [1:0] rf_wr_data_src_i,

    output logic [63:0] rf_wr_data_o
);

    logic [63:0] rf_wr_data;

    assign rf_wr_data = ({64{rf_wr_data_src_i == ALU}} & alu_res_i[63:0]) | 
                        ({64{rf_wr_data_src_i == MEM}} & data_mem_rd_i[63:0]) |
                        ({64{rf_wr_data_src_i == IMM}} & instr_imm_i[63:0]) | 
                        ({64{rf_wr_data_src_i == PC}}  & pc_val_i[63:0]);

    //output assigment
    assign rf_wr_data_o = rf_wr_data;

endmodule