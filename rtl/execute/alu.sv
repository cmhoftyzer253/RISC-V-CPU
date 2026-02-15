import cpu_consts::*;

module alu (
    input logic [63:0]  opr_a_i,
    input logic [63:0]  opr_b_i,

    input logic         alu_valid_i,
    input logic [3:0]   alu_func_i,
    input logic         word_op_i,

    input logic         flush_i,

    output logic        valid_res_o,
    output logic [63:0] alu_res_o
);

    logic [63:0] alu_res;

    always_comb begin                                                                   
        case (alu_func_i)
            OP_ADD : alu_res = opr_a_i + opr_b_i;
            OP_SUB : alu_res = opr_a_i - opr_b_i;
            OP_SLL : alu_res = opr_a_i << opr_b_i[5:0];                 
            OP_SRL : alu_res = opr_a_i >> opr_b_i[5:0];                 
            OP_SRA : alu_res = $signed(opr_a_i) >>> opr_b_i[5:0];        
            OP_OR : alu_res = opr_a_i | opr_b_i;
            OP_AND : alu_res = opr_a_i & opr_b_i;
            OP_XOR : alu_res = opr_a_i ^ opr_b_i;
            OP_SLTU : alu_res = {63'h0, opr_a_i < opr_b_i};               
            OP_SLT : alu_res = {63'h0, $signed(opr_a_i) < $signed(opr_b_i)};    
            default : alu_res = 64'h0;
        endcase
    end

    assign alu_res_o    =   ({64{ word_op_i}} & {{32{alu_res[31]}}, alu_res[31:0]}) |
                            ({64{~word_op_i}} & alu_res);

    assign valid_res_o  =   alu_valid_i & ~flush_i;

endmodule