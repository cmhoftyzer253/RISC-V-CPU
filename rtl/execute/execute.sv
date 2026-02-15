import cpu_consts::*;

module execute(
    input logic         clk,
    input logic         resetn,

    input logic         valid_instr_i,
    output logic        exu_ready_o,

    input logic         flush_i,

    input logic [63:0]  opr_a_i,
    input logic [63:0]  opr_b_i,

    input logic [3:0]   exu_func_i,
    input logic         word_op_i,
    input logic         mul_instr_i,
    input logic         div_instr_i,

    input logic         res_ready_i,
    output logic        valid_res_o,
    output logic [63:0] exu_res_o
);

    logic           alu_valid;
    logic           mul_valid;
    logic           div_valid;

    logic           mul_ready;
    logic           div_ready;

    logic           alu_res_valid;
    logic           mul_res_valid;
    logic           div_res_valid;

    logic [63:0]    alu_res;
    logic [63:0]    mul_res;
    logic [63:0]    div_res;         

    alu u_alu (
        .opr_a_i            (opr_a_i),
        .opr_b_i            (opr_b_i),
        .alu_valid_i        (alu_valid),
        .alu_func_i         (exu_func_i),
        .word_op_i          (word_op_i),
        .flush_i            (flush_i),
        .valid_res_o        (alu_res_valid),
        .alu_res_o          (alu_res)
    );

    multiply u_multiply (
        .clk                (clk),
        .resetn             (resetn),
        .opr_a_i            (opr_a_i),
        .opr_b_i            (opr_b_i),
        .mul_valid_i        (mul_valid),
        .mul_func_i         (exu_func_i),
        .word_op_i          (word_op_i),
        .mul_ready_o        (mul_ready),
        .flush_i            (flush_i),
        .mul_res_ready_i    (res_ready_i),
        .mul_res_valid_o    (mul_res_valid),
        .mul_res_o          (mul_res)
    );

    divide u_divide (
        .clk                (clk),
        .resetn             (resetn),
        .opr_a_i            (opr_a_i),
        .opr_b_i            (opr_b_i),
        .div_valid_i        (div_valid),
        .div_func_i         (exu_func_i),
        .word_op_i          (word_op_i),
        .div_ready_o        (div_ready),
        .flush_i            (flush_i),
        .div_res_ready_i    (res_ready_i),
        .div_res_valid_o    (div_res_valid),
        .div_res_o          (div_res)
    );

    always_comb begin
        alu_valid   =   valid_instr_i & ~mul_instr_i & ~div_instr_i;
        mul_valid   =   valid_instr_i & mul_instr_i;
        div_valid   =   valid_instr_i & div_instr_i;

        exu_ready_o     =   div_ready & mul_ready & ~(alu_res_valid & ~res_ready_i);

        valid_res_o     =   alu_res_valid | mul_res_valid | div_res_valid;

        exu_res_o       =   ({64{alu_res_valid}} & alu_res) |
                            ({64{mul_res_valid}} & mul_res) | 
                            ({64{div_res_valid}} & div_res);
    end

endmodule