import cpu_consts::*;

//TODO: Check for allowed field values for each instruction type. Eg funct7 allowed values for R type

module decode (
    input logic [31:0]  instr_i,
    output logic [4:0]  rs1_o,
    output logic [4:0]  rs2_o,
    output logic [4:0]  rd_o,
    output logic [6:0]  op_o,
    output logic [2:0]  funct3_o,
    output logic [11:0]  funct12_o,
    output logic [11:0] csr_addr_o,
    output logic        r_type_o,
    output logic        i_type_o,
    output logic        s_type_o,
    output logic        b_type_o,
    output logic        u_type_o,
    output logic        j_type_o,
    output logic        system_type_o,
    output logic [63:0] imm_o,

    output logic        exc_valid_o,
    output logic [4:0]  exc_code_o
);

    logic [6:0]         funct7;

    always_comb begin
        exc_valid_o     =   1'b0;

        exc_opcode      =   1'b0;
        exc_funct       =   1'b0;

        rs1_o           =   instr_i[19:15];
        rs2_o           =   instr_i[24:20];
        rd_o            =   instr_i[11:7];
        op_o            =   instr_i[6:0];
        funct3_o        =   instr_i[14:12];
        funct12_o       =   instr_i[31:20];
        csr_addr_o      =   12'h0;

        r_type_o        =   1'b0;
        i_type_o        =   1'b0;
        s_type_o        =   1'b0;
        b_type_o        =   1'b0;
        u_type_o        =   1'b0;
        j_type_o        =   1'b0;
        system_type_o   =   1'b0;

        imm_o           =   64'h0;   

        funct7          =   instr_i[31:25];

        case (instr_i[6:0])
            R_TYPE_0: begin
                r_type_o        =   1'b1;
                imm_o           =   64'h0;

                exc_valid_o     =   ~((funct7 == 7'b000_0000) | (funct7 == 7'b000_0001) | (funct7 == 7'b010_0000)) | 
                                    ((funct7 == 7'b010_0000) & ~((funct3_o == 3'b000) | (funct3_o == 3'b101)));
            end
            R_TYPE_1: begin
                r_type_o        =   1'b1;
                imm_o           =   64'h0;

                case (funct7)
                    7'b000_0000: exc_valid_o  =   ~((funct3_o == 3'b000) | (funct3_o == 3'b001) | (funct3_o == 3'b101));
                    7'b000_0001: exc_valid_o  =   ~((funct3_o == 3'b000) | funct3_o[2]);
                    7'b010_0000: exc_valid_o  =   ~((funct3_o == 3'b000) | (funct3_o == 3'b101));
                    default: exc_valid_o      =   1'b1;
                endcase
            end
            I_TYPE_0: begin
                rs2_o           =   5'b0;
                i_type_o        =   1'b1;
                imm_o           =   {{52{instr_i[31]}}, instr_i[31:20]};

                exc_valid_o     =   &funct3_o;
            end
            I_TYPE_1: begin
                rs2_o           =   5'b0;
                i_type_o        =   1'b1;
                imm_o           =   {{52{instr_i[31]}}, instr_i[31:20]};

                case (funct3_o)
                    3'b001: exc_valid_o     =   |instr_i[31:26];
                    3'b101: exc_valid_o     =   |{instr_i[31], instr_i[29:26]};
                endcase
            end
            I_TYPE_2: begin
                rs2_o           =   5'b0;
                i_type_o        =   1'b1;
                imm_o           =   {{52{instr_i[31]}}, instr_i[31:20]};

                exc_valid_o     =   |funct3_o;
            end
            I_TYPE_3: begin
                rs2_o           =   5'b0;
                i_type_o        =   1'b1;
                imm_o           =   {{52{instr_i[31]}}, instr_i[31:20]};

                case (funct3_o)
                    3'b000: exc_valid_o     =   1'b0;
                    3'b001: exc_valid_o     =   |funct7 | instr_i[25];
                    3'b101: exc_valid_o     =   |{funct7[6], funct7[4:0]};
                    default: exc_valid_o    =   1'b1;
                endcase
            end
            S_TYPE: begin
                rd_o            =   5'b0;
                s_type_o        =   1'b1;
                imm_o           =   {{52{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};

                exc_valid_o     =   funct3_o[2];
            end 
            B_TYPE: begin
                rd_o            =   5'b0;
                b_type_o        =   1'b1;
                imm_o           =   {{51{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};

                exc_valid_o     =   (funct3_o[2:1] == 2'b01);
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
            SYSTEM_TYPE: begin
                rs2_o           =   5'b0;
                csr_addr_o      =   instr_i[31:20];
                system_type_o   =   1'b1;
                imm_o           =   {59'h0, instr_i[19:15]};

                case (funct3_o) 
                    3'b000: exc_valid_o =   ~((funct12_o == 12'h000) | (funct12_o == 12'h001) | (funct12_o == 12'h302) | (funct12_o == 12'h105)) | (|rs1_o) | (|rd_o);
                    3'b100: exc_valid_o =   1'b1;
                endcase
            end
            default: begin          
                exc_valid_o     =   1'b1;
            end
        endcase

        exc_code_o  =   exc_valid_o ? 5'd2 : 5'd0;
    end

endmodule