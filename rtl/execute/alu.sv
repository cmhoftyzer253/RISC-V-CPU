import cpu_consts::*;

module alu (
        input logic [63:0]      opr_a_i,
        input logic [63:0]      opr_b_i,

        input logic [3:0]       alu_op_i,
        input logic             word_op_i,

        output logic [63:0]     alu_res_o
    );

    logic [63:0]                alu_res;

    always_comb begin                                                                   
        case (alu_op_i)
            OP_ADD: alu_res     =   opr_a_i + opr_b_i;
            OP_SUB: alu_res     =   opr_a_i - opr_b_i;
            OP_SLL: alu_res     =   word_op_i ? (opr_a_i[31:0] << opr_b_i[4:0]) : (opr_a_i << opr_b_i[5:0]); 
            OP_SRL: alu_res     =   word_op_i ? (opr_a_i[31:0] >> opr_b_i[4:0]) : (opr_a_i >> opr_b_i[5:0]);                
            OP_SRA: alu_res     =   word_op_i ? ($signed(opr_a_i[31:0]) >>> opr_b_i[4:0]) : ($signed(opr_a_i) >>> opr_b_i[5:0]);        
            OP_OR: alu_res      =   opr_a_i | opr_b_i;
            OP_AND: alu_res     =   opr_a_i & opr_b_i;
            OP_XOR: alu_res     =   opr_a_i ^ opr_b_i;
            OP_SLTU: alu_res    =   {63'h0, opr_a_i < opr_b_i};               
            OP_SLT: alu_res     =   {63'h0, $signed(opr_a_i) < $signed(opr_b_i)};    
            OP_PASS_A: alu_res  =   opr_a_i;
            default: alu_res    =   64'h0;
        endcase
    end

    assign alu_res_o    =   word_op_i ? {{32{alu_res[31]}}, alu_res[31:0]} : alu_res;

endmodule