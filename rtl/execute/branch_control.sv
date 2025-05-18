import cpu_consts::*;

module branch_control (

    input logic [63:0] opr_a_i,
    input logic [63:0] opr_b_i,

    input logic         is_b_type_i,
    input logic [2:0]   instr_funct3_i,

    output logic branch_taken_o
);

    logic branch_taken;

    always_comb begin                                                                   
        case (instr_funct3_i)
            BEQ     : branch_taken = (opr_a_i == opr_b_i);
            BNE     : branch_taken = (opr_a_i != opr_b_i);
            BLT     : branch_taken = ($signed(opr_a_i) < $signed(opr_b_i));
            BGE     : branch_taken = ($signed(opr_a_i) >= $signed(opr_b_i));
            BLTU    : branch_taken = (opr_a_i < opr_b_i);
            BGEU    : branch_taken = (opr_a_i >= opr_b_i);
            default : branch_taken = 1'b0;
        endcase
    end

    assign branch_taken_o = is_b_type_i & branch_taken;

endmodule;