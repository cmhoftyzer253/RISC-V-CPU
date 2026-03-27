interface alu_if;

    logic [63:0]    opr_a_i;
    logic [63:0]    opr_b_i;
    logic           alu_valid_i;
    logic [3:0]     alu_func_i;
    logic           word_op_i;
    logic           flush_i;
    
    logic           valid_res_o;
    logic [63:0]    alu_res_o;

endinterface