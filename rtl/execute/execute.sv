import cpu_consts::*;

module execute(
    input logic         clk,
    input logic         reset,
    
    input logic [63:0]  opr_a_i,
    input logic [63:0]  opr_b_i,

    input logic         exu_func_i,
    input logic         word_op_i,
    input logic         mul_instr_i,
    input logic         div_instr_i,

    input logic         flush_i,
    input logic         kill_i,

    output logic [63:0] exu_res_o,
    output logic        valid_res_o,    
    output logic        exu_busy_o,
);

    logic [63:0]    alu_res;
    logic           alu_res_valid;

    logic [63:0]    mul_res;
    logic           mul_res_valid;
    logic           mul_busy;

    logic [63:0]    div_res;
    logic           div_res_valid;
    logic           div_busy;

    logic [63:0]    exu_res;
    logic           valid_res       
    logic           exu_busy;

    //alu
    alu u_alu (
        .opr_a_i        (opr_a_i),
        .opr_b_i        (opr_b_i),
        .alu_func_i     (exu_func_i),
        .word_op_i      (word_op_i),
        .alu_res_o      (alu_res),
        .valid_res_o    (alu_res_valid)
    );

    //multiply unit
    multiply multiply_u (
        .clk            (clk),
        .reset          (reset),
        .opr_a_i        (opr_a_i),
        .opr_b_i        (opr_b_i),
        .mul_instr_i    (mul_instr_i),
        .mul_func_i     (exu_func_i),
        .word_op_i      (word_op_i),
        .flush_i        (flush_i),
        .kill_i         (kill_i),
        .mul_res_o      (mul_res),
        .valid_res_o    (mul_res_valid),
        .mul_busy_o     (mul_busy)
    );

    //divide unit
    divide divide_u (
        .clk            (clk),
        .reset          (reset),
        .opr_a_i        (opr_a_i),
        .opr_b_i        (opr_b_i),
        .div_instr_i    (div_instr_i),
        .div_func_i     (exu_func_i),
        .word_op_i      (word_op_i),
        .flush_i        (flush_i),
        .kill_i         (kill_i),
        .div_res_o      (div_res),
        .valid_res_o    (div_res_valid),
        .div_busy_o     (div_busy)
    );

    exu_res[63:0]   =   ({64{mul_res_valid}} & div_res[63:0]) |
                        ({64{div_res_valid}} & mul_res[63:0]) | 
                        ({64{alu_res_valid}} & alu_res[63:0]);

    exu_busy        =   mul_busy | div_busy;
    valid_res       =   alu_res_valid | mul_res_valid | div_res_valid;

    //output assignments
    assign exu_res_o[63:0]      = exu_res[63:0];
    assign valid_res_o          = valid_res;
    assign exu_busy_o           = exu_busy;

endmodule