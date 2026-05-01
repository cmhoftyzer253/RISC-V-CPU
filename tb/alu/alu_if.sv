interface alu_if(
    input logic     clk
);

    logic [63:0]    opr_a_i;
    logic [63:0]    opr_b_i;
    logic           alu_valid_i;
    logic [3:0]     alu_func_i;
    logic           word_op_i;
    logic           flush_i;
    
    logic           valid_res_o;
    logic [63:0]    alu_res_o;

    modport dut(
        input       opr_a_i,
        input       opr_b_i,
        input       alu_valid_i,
        input       alu_func_i,
        input       word_op_i,
        input       flush_i,
        output      valid_res_o,
        output      alu_res_o
    );

    modport tb(
        output      opr_a_i,
        output      opr_b_i,
        output      alu_valid_i,
        output      alu_func_i,
        output      word_op_i,
        output      flush_i,
        input       valid_res_o,
        input       alu_res_o
    );

endinterface