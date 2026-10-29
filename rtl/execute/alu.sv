module alu 
    import cpu_defines::*;
(
        input logic [63:0]      opr_a_i,
        input logic [63:0]      opr_b_i,

        input logic [3:0]       alu_op_i,
        input logic             word_op_i,

        output logic [63:0]     alu_res_o
);

    logic [31:0]                sllw_res;
    logic [31:0]                srlw_res;
    logic [31:0]                sraw_res;

    logic [63:0]                alu_res;

    always_comb begin                   
        sllw_res = opr_a_i[31:0] << opr_b_i[4:0];
        srlw_res = opr_a_i[31:0] >> opr_b_i[4:0];
        sraw_res = $signed(opr_a_i[31:0]) >>> opr_b_i[4:0];

        case (alu_op_i)
            ADD: alu_res        =   opr_a_i + opr_b_i;
            SUB: alu_res        =   opr_a_i - opr_b_i;
            SLL: alu_res        =   word_op_i ? {32'h0, sllw_res} : (opr_a_i << opr_b_i[5:0]); 
            SRL: alu_res        =   word_op_i ? {32'h0, srlw_res} : (opr_a_i >> opr_b_i[5:0]);                
            SRA: alu_res        =   word_op_i ? {32'h0, sraw_res} : ($signed(opr_a_i) >>> opr_b_i[5:0]);        
            OR: alu_res         =   opr_a_i | opr_b_i;
            AND: alu_res        =   opr_a_i & opr_b_i;
            XOR: alu_res        =   opr_a_i ^ opr_b_i;
            SLTU: alu_res       =   {63'h0, opr_a_i < opr_b_i};               
            SLT: alu_res        =   {63'h0, $signed(opr_a_i) < $signed(opr_b_i)};    
            default: alu_res    =   64'h0;
        endcase
    end

    assign alu_res_o    =   word_op_i ? {{32{alu_res[31]}}, alu_res[31:0]} : alu_res;

endmodule