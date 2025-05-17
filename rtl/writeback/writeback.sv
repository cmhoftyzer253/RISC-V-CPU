module writeback (
    input [63:0] alu_res_i,
    input [63:0] data_mem_rd_i,
    input [63:0] instr_imm_i,
    input [63:0] pc_val_i,

    input [1:0] rf_wr_data_src_i,

    output [63:0] rf_wr_data_o
);
    import cpu_consts::*;

    logic [63:0] rf_wr_data;

    assign rf_wr_data = (rf_wr_data_src_i == ALU) ? alu_res_i : 
                        (rf_wr_data_src_i == MEM) ? data_mem_rd_i : 
                        (rf_wr_data_src_i == IMM) ? instr_imm_i :
                        (rf_wr_data_src_i == PC) ? pc_val_i :
                        64'h0;

    //output assigment
    assign rf_wr_data_o = rf_wr_data;

endmodule