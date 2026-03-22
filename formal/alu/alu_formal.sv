`default_nettype none

import cpu_consts::*;

//Usage: sby -f alu.sby

module alu_formal;

    logic [63:0]    opr_a;
    logic [63:0]    opr_b;
    logic           alu_valid;
    logic [3:0]     alu_func;
    logic           word_op;
    logic           flush;

    logic           valid_res;
    logic [63:0]    alu_res;

    alu dut (
        .opr_a_i        (opr_a),
        .opr_b_i        (opr_b),
        .alu_valid_i    (alu_valid),
        .alu_func_i     (alu_func),
        .word_op_i      (word_op),
        .flush_i        (flush),
        .valid_res_o    (valid_res),
        .alu_res_o      (alu_res)
    );

    logic [63:0]    exp_raw;
    logic [63:0]    exp_out;

    always_comb begin
        case (alu_func)
            OP_ADD: exp_raw     =   opr_a + opr_b;
            OP_SUB: exp_raw     =   opr_a - opr_b;
            OP_SLL: exp_raw     =   word_op ? {32'h0, opr_a[31:0] << opr_b[4:0]} : {opr_a << opr_b[5:0]};
            OP_SRL: exp_raw     =   word_op ? {32'h0, opr_a[31:0] >> opr_b[4:0]} : {opr_a >> opr_b[5:0]};
            OP_SRA: exp_raw     =   word_op ? {{32{opr_a[31]}}, $signed(opr_a[31:0]) >>> opr_b[4:0]} : ($signed(opr_a) >>> opr_b[5:0]);
            OP_OR: exp_raw      =   opr_a | opr_b;
            OP_AND: exp_raw     =   opr_a & opr_b;
            OP_XOR: exp_raw     =   opr_a ^ opr_b;
            OP_SLTU: exp_raw    =   {63'h0, opr_a < opr_b};
            OP_SLT: exp_raw     =   {63'h0, $signed(opr_a) < $signed(opr_b)};
            OP_CSRRW: exp_raw   =   opr_a;
            default: exp_raw    =   64'h0;
        endcase

        exp_out =   word_op ? {{32{exp_raw[31]}}, exp_raw[31:0]} : exp_raw;
    end

    //================ Assumptions ====================================================================================
    LEGAL_WORD_OPS: assume property (
        word_op |-> ((alu_func == OP_ADD) | (alu_func == OP_SUB) | (alu_func == OP_SLL) | (alu_func == OP_SRL) | (alu_func == OP_SRA))
    );

    //================ Arithmetic ====================================================================================
    OP_ADD_correct: assert property (
        (alu_func == OP_ADD) |-> (alu_res == exp_out)
    );

    OP_SUB_correct: assert property (
        (alu_func == OP_SUB) |-> (alu_res == exp_out)
    );

    //================ Shift ====================================================================================
    SLL64_correct: assert property (
        ((alu_func == OP_SLL) & ~word_op) |-> (alu_res == (opr_a << opr_b[5:0]))
    );

    SLL32_correct: assert property (
        ((alu_func == OP_SLL) & word_op) |-> (alu_res == {{32{exp_raw[31]}}, opr_a[31:0] << opr_b[4:0]})
    );

    SRL64_correct: assert property (
        ((alu_func == OP_SRL) & ~word_op) |-> (alu_res == (opr_a >> opr_b[5:0]))
    );

    SRL32_correct: assert property (
        ((alu_func == OP_SRL) & word_op) |-> (alu_res == {{32{exp_raw[31]}}, (opr_a[31:0] >> opr_b[4:0])})
    );

    SRA64_correct: assert property (
        ((alu_func == OP_SRA) & ~word_op) |-> (alu_res == ($signed(opr_a) >>> opr_b[5:0]))
    );

    SRA32_correct: assert property (
        ((alu_func == OP_SRA) & word_op) |-> (alu_res == {{32{exp_raw[31]}}, ($signed(opr_a[31:0]) >>> opr_b[4:0])})
    );

    SRA64_preserve_pos: assert property (
        ((alu_func == OP_SRA) & ~word_op & ~opr_a[63]) |-> ~alu_res[63]
    );

    SRA64_preserve_neg: assert property (
        ((alu_func == OP_SRA) & ~word_op & opr_a[63]) |-> alu_res[63]
    );

    SRA32_preserve_pos: assert property (
        ((alu_func == OP_SRA) & word_op & ~opr_a[31]) |-> ~alu_res[63]
    );

    SRA32_preserve_neg: assert property (
        ((alu_func == OP_SRA) & word_op & opr_a[31]) |-> alu_res[63]
    );

    SLL64_zero_shift: assert property (
        ((alu_func == OP_SLL) & (opr_b[5:0] == 6'b0) & ~word_op) |-> (alu_res == opr_a)
    );

    SLL32_zero_shift: assert property (
        ((alu_func == OP_SLL) & (opr_b[4:0] == 5'b0) & word_op) |-> (alu_res == {{32{opr_a[31]}}, opr_a[31:0]})
    );

    SRL64_zero_shift: assert property (
        ((alu_func == OP_SRL) & (opr_b[5:0] == 6'b0) & ~word_op) |-> (alu_res == opr_a)
    );

    SRL32_zero_shift: assert property (
        ((alu_func == OP_SRL) & (opr_b[4:0] == 5'b0) & word_op) |-> (alu_res == {{32{opr_a[31]}}, opr_a[31:0]})
    );

    SRA64_zero_shift: assert property  (
        ((alu_func == OP_SRA) & (opr_b[5:0] == 6'b0) & ~word_op) |-> (alu_res == opr_a)
    );

    SRA32_zero_shift: assert property (
        ((alu_func == OP_SRA) & (opr_b[4:0] == 5'b0) & word_op) |-> (alu_res == {{32{opr_a[31]}}, opr_a[31:0]})
    );

    //================ Logic ====================================================================================
    OR_correct: assert property (
        (alu_func == OP_OR) |-> (alu_res == exp_out)
    );

    AND_correct: assert property (
        (alu_func == OP_AND) |-> (alu_res == exp_out)
    );

    XOR_correct: assert property (
        (alu_func == OP_XOR) |-> (alu_res == exp_out)
    );

    AND_identity: assert property (
        ((alu_func == OP_AND) & (opr_b == opr_a)) |-> (alu_res == opr_a)
    );

    OR_identity: assert property (
        ((alu_func == OP_OR) & (opr_b == 64'h0)) |-> (alu_res == opr_a)
    );

    XOR_identity: assert property (
        ((alu_func == OP_XOR) & (opr_b == opr_a)) |-> (alu_res == 64'h0)
    );

    //================ SLT(U) ====================================================================================
    SLTU_one_hot: assert property (
        (alu_func == OP_SLTU) |-> ((alu_res == 64'h0) | (alu_res == 64'h1))
    );

    SLT_one_hot: assert property (
        (alu_func == OP_SLT) |-> ((alu_res == 64'h0) | (alu_res == 64'h1))
    );

    SLTU_equal_opr: assert property (
        (alu_func == OP_SLTU) & (opr_a == opr_b) |-> (alu_res == 64'h0)
    );

    SLT_equal_opr: assert property (
        (alu_func == OP_SLT) & (opr_a == opr_b) |-> (alu_res == 64'h0)
    );

    SLTU_correct: assert property (
        (alu_func == OP_SLTU) |-> (alu_res == {63'h0, opr_a < opr_b})
    );

    SLT_correct: assert property (
        (alu_func == OP_SLT) |-> (alu_res == {63'h0, $signed(opr_a) < $signed(opr_b)})
    );

    SLT_SLTU_same_sign: assert property (
        (opr_a[63] == opr_b[63]) |-> ({63'h0, $signed(opr_a) < $signed(opr_b)} == {63'h0, opr_a < opr_b})
    );

    //================ CSRRW ======================================================================================
    CSRRW_correct: assert property (
        (alu_func == OP_CSRRW) |-> alu_res == opr_a
    );

    //================ Word Ops ====================================================================================
    word_op_sign_ext: assert property (
        word_op |-> alu_res[63:32] == {32{alu_res[31]}}
    );

    word_op_full_width: assert property (
        ~word_op |-> alu_res == exp_out
    );

    //================ Control ======================================================================================
    flush_kill_valid: assert property (
        flush |-> ~valid_res
    );

    valid_when_active: assert property (
        (~flush & alu_valid) |-> valid_res
    );

    invalid_if_no_input: assert property (
        (~flush & ~alu_valid) |-> ~valid_res
    );

    //================ Covers ====================================================================================
    cover_valid_no_flush: cover property (
        alu_valid & ~flush
    );

    cover_valid_flush: cover property (
        alu_valid & flush
    );

    cover_word_negative: cover property (
        word_op & alu_res[63]
    );

    cover_word_nonnegative: cover property (
        word_op & ~alu_res[63]
    );

    cover_SLT_true: cover property (
        alu_func == OP_SLT & (alu_res == 64'h1)
    );

    cover_SLT_false: cover property (
        (alu_func == OP_SLT) & (alu_res == 64'h0)
    );

    cover_SLTU_true: cover property (
        (alu_func == OP_SLTU) & (alu_res == 64'h1)
    );

    cover_SLTU_false: cover property (
        (alu_func == OP_SLTU) & (alu_res == 64'h0)
    );

    cover_SLL64_zero_shift: cover property (
        (alu_func == OP_SLL) & ~word_op & (opr_b[5:0] == 6'b0)
    );

    cover_SRL64_zero_shift: cover property (
        (alu_func == OP_SRL) & ~word_op & (opr_b[5:0] == 6'b0)
    );

    cover_SRA64_zero_shift: cover property (
        (alu_func == OP_SRA) & ~word_op & (opr_b[5:0] == 6'b0)
    );

    cover_SLL64_shift: cover property (
        (alu_func == OP_SLL) & ~word_op & (opr_b[5:0] != 6'b0)
    );

    cover_SRL64_shift: cover property (
        (alu_func == OP_SRL) & ~word_op & (opr_b[5:0] != 6'b0)
    );

    cover_SRA64_neg_shift: cover property (
        (alu_func == OP_SRA) & ~word_op & opr_a[63] & (opr_b[5:0] != 6'b0)
    );

    cover_SRA64_pos_shift: cover property (
        (alu_func == OP_SRA) & ~word_op & ~opr_a[63] & (opr_b[5:0] != 6'b0)
    );

    cover_SLL32_zero_shift: cover property (
        (alu_func == OP_SLL) & word_op & (opr_b[4:0] == 5'b0)
    );

    cover_SRL32_zero_shift: cover property (
        (alu_func == OP_SRL) & word_op & (opr_b[4:0] == 5'b0)
    );

    cover_SRA32_zero_shift: cover property (
        (alu_func == OP_SRA) & word_op & (opr_b[4:0] == 5'b0)
    );

    cover_SLL32_shift: cover property (
        (alu_func == OP_SLL) & word_op & (opr_b[4:0] != 5'b0)
    );

    cover_SRL32_shift: cover property (
        (alu_func == OP_SRL) & word_op & (opr_b[4:0] != 5'b0)
    );

    cover_SRA32_neg_shift: cover property (
        (alu_func == OP_SRA) & word_op & opr_a[31] & (opr_b[4:0] != 5'b0)
    );

    cover_SRA32_pos_shift: cover property (
        (alu_func == OP_SRA) & word_op & ~opr_a[31] & (opr_b[4:0] != 5'b0)
    );

    cover_add64: cover property (
        (alu_func == OP_ADD) & ~word_op
    );

    cover_add32: cover property (
        (alu_func == OP_ADD) & word_op
    );

    cover_sub64: cover property (
        (alu_func == OP_SUB) & ~word_op
    );

    cover_sub32: cover property (
        (alu_func == OP_SUB) & word_op
    );

    cover_add64_overflow: cover property (
        (alu_func == OP_ADD) & ~word_op & (opr_a[63] == opr_b[63]) & (alu_res[63] != opr_a[63])
    );

    cover_add32_overflow: cover property (
        (alu_func == OP_ADD) & word_op & (opr_a[31] == opr_b[31]) & (alu_res[31] != opr_a[31])
    );

    cover_sub_sign_change: cover property (
        (alu_func == OP_SUB) & ~word_op & (opr_a[63] != opr_b[63]) & (alu_res[63] != opr_a[63])
    );

    cover_sub32_sign_change: cover property (
        (alu_func == OP_SUB) & word_op & (opr_a[31] != opr_b[31]) & (alu_res[31] != opr_a[31])
    );
    
endmodule