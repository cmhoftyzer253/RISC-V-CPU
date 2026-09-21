module mdu (
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      opr_a_i,
    input logic [63:0]      opr_b_i,
    input logic             mdu_en_i,
    input logic [3:0]       exu_op_i,
    input logic             word_op_i,
    output logic            mdu_ready_o,

    input logic             stallE_i,
    input logic             flushE_i,
    input logic             stallM_i,

    output logic            mdu_res_valid_o,
    output logic [63:0]     mdu_res_o
);

    logic                   mul_valid;
    logic                   div_valid;

    logic                   mul_ready;
    logic                   div_ready;

    logic                   mul_res_valid;
    logic [63:0]            mul_res;

    logic                   div_res_valid;
    logic [63:0]            div_res;

    multiply u_multiply (
        .clk                (clk),
        .resetn             (resetn),
        .opr_a_i            (opr_a_i),
        .opr_b_i            (opr_b_i),
        .mul_valid_i        (mul_valid),
        .mul_func_i         (exu_op_i),
        .word_op_i          (word_op_i),
        .mul_ready_o        (mul_ready),
        .stallE_i           (stallE_i),
        .flushE_i           (flushE_i),
        .stallM_i           (stallM_i),
        .mul_res_o          (mul_res),
        .mul_res_valid_o    (mul_res_valid)
    );
    
    divide u_divide (
        .clk                (clk),
        .resetn             (resetn),
        .opr_a_i            (opr_a_i),
        .opr_b_i            (opr_b_i),
        .div_valid_i        (div_valid),
        .div_func_i         (exu_op_i),
        .word_op_i          (word_op_i),
        .div_ready_o        (div_ready),
        .stallE_i           (stallE_i),
        .flushE_i           (flushE_i),
        .stallM_i           (stallM_i),
        .div_res_o          (div_res),
        .div_res_valid_o    (div_res_valid)
    );

    assign mul_valid        =   mdu_en_i && !exu_op_i[2];
    assign div_valid        =   mdu_en_i && exu_op_i[2];

    assign mdu_ready_o      =   mul_ready && div_ready;

    assign mdu_res_valid_o  =   mul_res_valid || div_res_valid;
    assign mdu_res_o        =   mul_res_valid ? mul_res : div_res;

endmodule