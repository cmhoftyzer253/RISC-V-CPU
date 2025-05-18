module writeback (
    input logic [63:0] alu_res_i,
    input logic [63:0] data_mem_rd_i,
    input logic [63:0] instr_imm_i,
    input logic [63:0] pc_val_i,

    input logic [1:0] rf_wr_data_src_i,

    //input for processing data memory values 
    input logic [1:0] data_byte_en_i,
    input logic       data_zero_extnd_i,
    input logic [2:0] data_mem_row_idx_i,

    output logic [63:0] rf_wr_data_o
);
    import cpu_consts::*;

    logic [63:0] data_mem_rd;
    logic [63:0] data_mem_rd_shift;
    logic [63:0] rf_wr_data;

    //shift data if needed
    assign data_mem_rd_shift = data_mem_rd_i >> (data_mem_row_idx_i*8);

    //zero & sign extend
    assign data_mem_rd_sign_extnd = (data_byte_en_i == BYTE)       ? {{56{data_mem_rd_shift[7]}}, data_mem_rd_shift[7:0]} :
                                    (data_byte_en_i == HALF_WORD)  ? {{48{data_mem_rd_shift[15]}}, data_mem_rd_shift[15:0]} :
                                    (data_byte_en_i == WORD)       ? {{32{data_mem_rd_shift[31]}}, data_mem_rd_shift[31:0]} :
                                                                        data_mem_rd_shift;
    
    assign data_mem_rd_zero_extnd = (data_byte_en_i == BYTE)       ? {{56{1'b0}}, data_mem_rd_shift[7:0]} :
                                    (data_byte_en_i == HALF_WORD)  ? {{48{1'b0}}, data_mem_rd_shift[15:0]} :
                                    (data_byte_en_i == WORD)       ? {{32{1'b0}}, data_mem_rd_shift[31:0]} :
                                                                        data_mem_rd_shift;

    assign data_mem_rd = data_zero_extnd_i ? data_mem_rd_sign_extnd : data_mem_rd_zero_extnd;

    assign rf_wr_data = (rf_wr_data_src_i == ALU) ? alu_res_i : 
                        (rf_wr_data_src_i == MEM) ? data_mem_rd : 
                        (rf_wr_data_src_i == IMM) ? instr_imm_i :
                        (rf_wr_data_src_i == PC) ? pc_val_i :
                        64'h0;

    //output assigment
    assign rf_wr_data_o = rf_wr_data;

endmodule