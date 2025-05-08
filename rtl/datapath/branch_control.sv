module branch_control (

    input logic [63:0] opr_a_i,
    input logic [63:0] opr_b_i,

    input logic         is_b_type_i,
    input logic [2:0]   instr_funct3_i,

    output logic branch_taken_o
);

    import cpu_consts::*;

    logic [31:0] twos_compl_a;
    logic [31:0] twos_compl_b;

    logic branch_taken;

    assign twos_compl_a = opr_a_i[63] ? ~opr_a_i + 63'h1 : opr_a_i;
    assign twos_compl_b = opr_b_i[63] ? ~opr_b_i + 63'h1 : opr_b_i;

    always_comb begin
        case (instr_funct3_i)
            BEQ     : branch_taken = (opr_a_i == opr_b_i);
            BNE     : branch_taken = (opr_a_i != opr_b_i);
            BLT     : branch_taken = (twos_compl_a < twos_compl_b);
            BGE     : branch_taken = (twos_compl_a >= twos_compl_b);
            BLTU    : branch_taken = (opr_a_i < opr_b_i);
            BGEU    : branch_taken = (opr_a_i >= opr_b_i);
            default : branch_taken = 1'b0;
        endcase
    end

    assign branch_taken_o = is_b_type_i & branch_taken;

endmodule;