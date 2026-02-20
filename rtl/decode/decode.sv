import cpu_consts::*;

module decode (
    input logic [31:0]  instr_i,
    output logic [4:0]  rs1_o,
    output logic [4:0]  rs2_o,
    output logic [4:0]  rd_o,
    output logic [6:0]  op_o,
    output logic [2:0]  funct3_o,
    output logic [6:0]  funct7_o,
    output logic [11:0] csr_addr_o,
    output logic        r_type_o,
    output logic        i_type_o,
    output logic        s_type_o,
    output logic        b_type_o,
    output logic        u_type_o,
    output logic        j_type_o,
    output logic        zicsr_type_o,
    output logic [63:0] imm_o,

    output logic        exc_valid_o,
    output logic [4:0]  exc_code_o
);

    logic [4:0]     rs1;
    logic [4:0]     rs2;
    logic [4:0]     rd;
    logic [6:0]     op;
    logic [6:0]     funct7;
    logic [2:0]     funct3;
    logic [63:0]    imm;
    logic           r_type;
    logic           i_type;
    logic           s_type;
    logic           b_type;
    logic           u_type;
    logic           j_type;
    logic           zicsr_type;

    always_comb begin
        exc_valid_o     =   1'b0;
        exc_code_o      =   5'b0;

        rs1_o           =   instr_i[19:15];
        rs2_o           =   instr_i[24:20];
        rd_o            =   instr_i[11:7];
        op_o            =   instr_i[6:0];
        funct3_o        =   instr_i[14:12];
        funct7_o        =   instr_i[31:25];
        csr_addr_o      =   12'h0;

        r_type_o        =   1'b0;
        i_type_o        =   1'b0;
        s_type_o        =   1'b0;
        b_type_o        =   1'b0;
        u_type_o        =   1'b0;
        j_type_o        =   1'b0;
        zicsr_type_o    =   1'b0;

        imm_o           =   64'h0;   

        case (instr_i[6:0])
            R_TYPE_0,
            R_TYPE_1: begin
                r_type_o        =   1'b1;
                imm_o           =   64'h0;
            end
            I_TYPE_0,
            I_TYPE_1, 
            I_TYPE_2,
            I_TYPE_3: begin
                rs2_o           =   5'b0;
                i_type_o        =   1'b1;
                imm_o           =   {{52{instr_i[31]}}, instr_i[31:20]};
            end
            S_TYPE: begin
                rd_o            =   5'b0;
                s_type_o        =   1'b1;
                imm_o           =   {{52{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            end 
            B_TYPE: begin
                rd_o            =   5'b0;
                b_type_o        =   1'b1;
                imm_o           =   {{51{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
            end
            U_TYPE_0,
            U_TYPE_1: begin
                rs1_o           =   5'b0;
                rs2_o           =   5'b0;
                u_type_o        =   1'b1;
                imm_o           =   {{32{instr_i[31]}}, instr_i[31:12], 12'h0};
            end 
            J_TYPE: begin
                rs1_o           =   5'b0;
                rs2_o           =   5'b0;
                j_type_o        =   1'b1;
                imm_o           =   {{43{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
            end 
            ZICSR_TYPE: begin
                rs2_o           =   5'b0;
                csr_addr_o      =   instr_i[31:20];
                zicsr_type_o    =   1'b1;
                imm_o           =   {59'h0, instr_i[19:15]};
            end
            default: begin          
                exc_valid_o     =   1'b1;
                exc_code_o      =   5'd2;
            end
        endcase
    end

endmodule
