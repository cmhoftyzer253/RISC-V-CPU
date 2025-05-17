module execute (
    input logic [63:0] opr_a_i,
    input logic [63:0] opr_b_i,

    input logic [3:0] alu_func_i,

    output logic [63:0] alu_res_o
);
    import cpu_consts::*;

    logic [63:0] twos_compl_a;
    logic [63:0] twos_compl_b;

    logic [63:0] alu_res;

    assign twos_compl_a = opr_a_i[63] ? ~opr_a_i + 64'h1 : opr_a_i;
    assign twos_compl_b = opr_b_i[63] ? ~opr_b_i + 64'h1 : opr_b_i;

    always_comb begin                                                                   
        case (alu_func_i)
            OP_ADD : alu_res = opr_a_i + opr_b_i;
            OP_SUB : alu_res = opr_a_i - opr_b_i;
            OP_SLL : alu_res = opr_a_i << opr_b_i[5:0];                 
            OP_SRL : alu_res = opr_a_i >> opr_b_i[5:0];                 
            OP_SRA : alu_res = $signed(opr_a_i) >>> opr_b_i[4:0]        
            OP_OR : alu_res = opr_a_i | opr_b_i;
            OP_AND : alu_res = opr_a_i & opr_b_i;
            OP_XOR : alu_res = opr_a_i ^ opr_b_i;
            OP_SLTU : alu_res = {63'h0, opr_a_i < opr_b_i};               
            OP_SLT : alu_res = {63'h0, $signed(opr_a_i) < $signed(opr_b_i)};    
            default : alu_res = 64'h0;
        endcase
    end

    assign alu_res_o = alu_res;

endmodule