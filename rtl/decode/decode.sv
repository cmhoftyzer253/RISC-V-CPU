import cpu_defines::*;
import cpu_utils::*;

module decode (
    input logic [31:0]      instr_i,

    input logic [1:0]       priv_level_i,
    input logic [31:0]      mcounteren_i,
    input logic [31:0]      scounteren_i,
    input logic             mstatus_tsr_i,
    input logic             mstatus_tw_i,
    input logic             mstatus_tvm_i,
    input logic             menvcfg_stce_i,

    output logic [4:0]      rs1_o,
    output logic [4:0]      rs2_o,
    output logic [4:0]      rd_o,
    output logic [63:0]     imm_o,

    output logic [11:0]     csr_addr_o,

    output logic [2:0]      pc_sel_o,
    output logic [1:0]      opa_sel_o,
    output logic            opb_sel_o,
    output logic            word_op_o,
    output logic            alu_en_o,
    output logic            md_en_o,
    output logic [3:0]      exu_op_o,
    output logic [2:0]      branch_op_o,
    output logic            csr_en_o,
    output logic [1:0]      csr_op_o,
    output logic            mctrl_en_o,
    output logic [1:0]      mctrl_op_o,
    output logic            lsu_en_o,
    output logic [1:0]      lsu_ls_o,
    output logic [1:0]      lsu_size_o,
    output logic [4:0]      atomic_op_o,
    output logic            lsu_se_o,
    output logic            rf_wr_en_o,
    output logic [2:0]      rf_sel_o,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o
);

    logic [6:0]     opcode;
    logic [2:0]     funct3;
    logic [6:0]     funct7;
    logic [11:0]    funct12;
    
    logic           r_type;
    logic           i_type;
    logic           s_type;
    logic           b_type;
    logic           u_type;
    logic           j_type;
    logic           a_type;
    logic           fence;
    logic           privileged;

    logic           csr_addr_valid;

    control_t       r_type_controls;
    control_t       i_type_controls;
    control_t       s_type_controls;
    control_t       b_type_controls;
    control_t       u_type_controls;
    control_t       j_type_controls;
    control_t       a_type_controls;
    control_t       fence_controls;
    control_t       privileged_controls;

    control_t       controls;

    csr_addr_decode u_csr_addr_decode (
        .csr_addr_i         (csr_addr_o),
        .funct3_i           (funct3),
        .rs1_i              (rs1_o),
        .priv_level_i       (priv_level_i),
        .mcounteren_i       (mcounteren_i),
        .scounteren_i       (scounteren_i),
        .mstatus_tvm_i      (mstatus_tvm_i),
        .menvcfg_stce_i     (menvcfg_stce_i),
        .csr_addr_valid_o   (csr_addr_valid)
    );

    always_comb begin
        exc_valid_o     =   1'b0;
        exc_code_o      =   ILLEGAL_INSTR;

        rs1_o           =   instr_i[19:15];
        rs2_o           =   instr_i[24:20];
        rd_o            =   instr_i[11:7];
        imm_o           =   64'h0;
        csr_addr_o      =   instr_i[31:20];

        opcode          =   instr_i[6:0];
        funct3          =   instr_i[14:12];
        funct7          =   instr_i[31:25];
        funct12         =   instr_i[31:20];    

        r_type          =   (opcode == R_TYPE_0) || (opcode == R_TYPE_1);
        i_type          =   (opcode == I_TYPE_0) || (opcode == I_TYPE_1) || (opcode == I_TYPE_2) || (opcode == I_TYPE_3);
        s_type          =   (opcode == S_TYPE);
        b_type          =   (opcode == B_TYPE);
        u_type          =   (opcode == U_TYPE_0) || (opcode == U_TYPE_1);
        j_type          =   (opcode == J_TYPE);
        a_type          =   (opcode == A_TYPE);
        fence           =   (opcode == FENCE);
        privileged      =   (opcode == PRIVILEGED);

        //exceptions
        case (opcode)
            R_TYPE_0: exc_valid_o   =   !((funct7 == 7'h00) || (funct7 == 7'h01) || (funct7 == 7'h20)) || ((funct7 == 7'h20) && !((funct3 == 3'b000) || (funct3 == 3'b101)));
            R_TYPE_1: begin
                case (funct7) 
                    7'h00: exc_valid_o      =   !((funct3 == 3'b000) || (funct3 == 3'b001) || (funct3 == 3'b101));
                    7'h01: exc_valid_o      =   !((funct3 == 3'b000) || (funct3[2]));
                    7'h20: exc_valid_o      =   !((funct3 == 3'b000) || (funct3 == 3'b101));
                    default: exc_valid_o    =   1'b1;
                endcase
            end
            I_TYPE_0: exc_valid_o   =   &funct3;
            I_TYPE_1: begin
                case (funct3)
                    3'b001: exc_valid_o     =   |instr_i[31:26];
                    3'b101: exc_valid_o     =   |{instr_i[31], instr_i[29:26]};
                endcase
            end
            I_TYPE_2: exc_valid_o   =   |funct3;
            I_TYPE_3: begin
                case (funct3)
                    3'b000: exc_valid_o     =   1'b0;
                    3'b001: exc_valid_o     =   |funct7 || instr_i[25];
                    3'b101: exc_valid_o     =   |{funct7[6], funct7[4:0]};
                    default: exc_valid_o    =   1'b1;
                endcase
            end
            S_TYPE: exc_valid_o     =   funct3[2];
            B_TYPE: exc_valid_o     =   (funct3[2:1] == 2'b01);      
            U_TYPE_0: exc_valid_o   =   1'b0;
            U_TYPE_1: exc_valid_o   =   1'b0;
            J_TYPE: exc_valid_o     =   1'b0;
            A_TYPE: begin
                case (funct7[6:2])
                    5'b00010: exc_valid_o   =   !((funct3 == 3'b010) || (funct3 == 3'b011)) || |rs2_o;
                    5'b00011, 
                    5'b00001,
                    5'b00000,
                    5'b00100,
                    5'b01100,
                    5'b01000,
                    5'b10000,
                    5'b10100,
                    5'b11000,
                    5'b11100: exc_valid_o   =   !((funct3 == 3'b010) || (funct3 == 3'b011));
                    default: exc_valid_o    =   1'b1;
                endcase
            end
            FENCE: exc_valid_o      =   |funct3[2:1];
            PRIVILEGED: begin
                case (funct3)
                    3'b000: begin
                        if (|instr_i[19:7]) begin
                            exc_valid_o     =   1'b1;
                        end else begin
                            case (funct12)
                                ECALL: begin
                                    exc_valid_o         =   1'b1;
                                    case (priv_level_i)
                                        U_MODE: exc_code_o  =   ECALL_UMODE;
                                        S_MODE: exc_code_o  =   ECALL_SMODE;
                                        M_MODE: exc_code_o  =   ECALL_MMODE;
                                    endcase
                                end
                                EBREAK: begin
                                    exc_valid_o         =   1'b1;
                                    exc_code_o          =   EBREAK_EXC;
                                end
                                SRET: exc_valid_o       =   mstatus_tsr_i ? (priv_level_i != M_MODE) : (priv_level_i == U_MODE);
                                WFI: exc_valid_o        =   mstatus_tw_i ? (priv_level_i != M_MODE) : (priv_level_i == U_MODE);
                                MRET: exc_valid_o       =   (priv_level_i != M_MODE);
                                default: exc_valid_o    =   1'b1;
                            endcase
                        end
                    end
                    3'b001,   
                    3'b010,
                    3'b011,
                    3'b101,
                    3'b110,
                    3'b111: exc_valid_o     =   !csr_addr_valid;
                    default: exc_valid_o    =   1'b1;
                endcase
            end
            default: exc_valid_o    =   1'b1;
        endcase

        //immediate
        case (opcode)
            I_TYPE_0,
            I_TYPE_1,
            I_TYPE_2,
            I_TYPE_3:       imm_o   =   {{52{instr_i[31]}}, instr_i[31:20]};
            S_TYPE:         imm_o   =   {{52{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            B_TYPE:         imm_o   =   {{51{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
            U_TYPE_0,
            U_TYPE_1:       imm_o   =   {{32{instr_i[31]}}, instr_i[31:12], 12'h0};
            J_TYPE:         imm_o   =   {{43{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
            PRIVILEGED:     imm_o   =   {59'h0, instr_i[19:15]};
        endcase
    end

    // Control flags
    // R type
    always_comb begin
        r_type_controls             =   '0;

        r_type_controls.word_op     =   (opcode == R_TYPE_1);
        r_type_controls.rf_wr_en    =   1'b1;
        if (funct7[0]) begin
            r_type_controls.md_en   =   1'b1;
            r_type_controls.exu_op  =   {1'b0, funct3};
            r_type_controls.rf_sel  =   RF_MDU_SRC;
        end else begin
            r_type_controls.alu_en  =   1'b1;
            r_type_controls.exu_op  =   {funct7[5], funct3};
        end
    end

    always_comb begin
        i_type_controls             =   '0;

        i_type_controls.opb_sel     =   IMM;
        i_type_controls.alu_en      =   1'b1;
        i_type_controls.rf_wr_en    =   1'b1;

        if (opcode == I_TYPE_0) begin
            i_type_controls.lsu_en              =   1'b1;
            i_type_controls.rf_sel              =   RF_LSU_SRC;
            case (funct3)
                LB: i_type_controls.lsu_se      =   1'b1;
                LH: begin
                    i_type_controls.lsu_size    =   HALF_WORD;
                    i_type_controls.lsu_se      =   1'b1;
                end
                LW: begin
                    i_type_controls.lsu_size    =   WORD;
                    i_type_controls.lsu_se      =   1'b1;
                end
                LD: begin
                    i_type_controls.lsu_size    =   DOUBLE_WORD;
                    i_type_controls.lsu_se      =   1'b1;
                end
                LHU: i_type_controls.lsu_size    =   HALF_WORD;
                LWU: i_type_controls.lsu_size    =   WORD;  
            endcase
        end else if (opcode == I_TYPE_2) begin
            i_type_controls.pc_sel              =   ALU_RES;
            i_type_controls.rf_sel              =   RF_PC_INCR_SRC;
        end else begin
            i_type_controls.word_op             =   (opcode == I_TYPE_3);
            case (funct3)
                ADDI: i_type_controls.exu_op    =   ADD;
                SLTI: i_type_controls.exu_op    =   SLT;
                SLTIU: i_type_controls.exu_op   =   SLTU;
                XORI: i_type_controls.exu_op    =   XOR;
                ORI: i_type_controls.exu_op     =   OR;
                ANDI: i_type_controls.exu_op    =   AND;
                SLLI: i_type_controls.exu_op    =   SLL;
                SRXI: i_type_controls.exu_op    =   funct7[5] ? SRA : SRL;
            endcase
        end
    end

    //S type   
    always_comb begin
        s_type_controls             =   '0;

        s_type_controls.opb_sel     =   IMM;
        s_type_controls.alu_en      =   1'b1;
        s_type_controls.lsu_en      =   1'b1;
        s_type_controls.lsu_ls      =   LSU_STORE;
        s_type_controls.lsu_size    =   funct3[1:0];
    end

    //B type
    always_comb begin
        b_type_controls             =   '0;

        b_type_controls.pc_sel      =   BRANCH;
        b_type_controls.opa_sel     =   PC;
        b_type_controls.opb_sel     =   IMM;
        b_type_controls.alu_en      =   1'b1;
        b_type_controls.branch_op   =   funct3;
    end

    //U type
    always_comb begin
        u_type_controls                     =   '0;

        u_type_controls.opb_sel             =   IMM;
        u_type_controls.alu_en              =   1'b1;
        u_type_controls.rf_wr_en            =   1'b1;
        case (opcode)
            LUI: u_type_controls.opa_sel    =   ZERO;
            AUIPC: u_type_controls.opa_sel  =   PC;
        endcase
    end

    //J type (JAL)
    always_comb begin
        j_type_controls             =   '0;

        j_type_controls.pc_sel      =   ALU_RES;
        j_type_controls.opa_sel     =   PC;
        j_type_controls.opb_sel     =   IMM;
        j_type_controls.alu_en      =   1'b1;
        j_type_controls.rf_wr_en    =   1'b1;
        j_type_controls.rf_sel      =   RF_PC_INCR_SRC;
    end

    //A type
    always_comb begin
        a_type_controls = '0;

        a_type_controls.opb_sel     =   IMM;
        a_type_controls.alu_en      =   1'b1;
        a_type_controls.lsu_en      =   1'b1;
        a_type_controls.lsu_ls      =   LSU_ATOMIC;
        a_type_controls.lsu_size    =   (funct3 == 3'b011) ? DOUBLE_WORD : WORD;
        a_type_controls.atomic_op   =   funct7[6:2];
        a_type_controls.lsu_se      =   1'b1;
        a_type_controls.rf_wr_en    =   1'b1;
        a_type_controls.rf_sel      =   RF_LSU_SRC;
    end

    //fence
    always_comb begin
        fence_controls = '0;

        if (funct3 == 3'b001) begin
            fence_controls.mctrl_en     =   1'b1;
            fence_controls.mctrl_op     =   FENCE_I;
        end
    end

    //privileged
    always_comb begin
        privileged_controls = '0;

        case (funct3)
            CSRRW,
            CSRRS,
            CSRRC: begin
                privileged_controls.csr_en      =   1'b1;
                privileged_controls.csr_op      =   funct3[1:0];
                privileged_controls.rf_wr_en    =   |rd_o;
                privileged_controls.rf_sel      =   RF_CSR_SRC;
            end
            CSRRWI,
            CSRRSI,
            CSRRCI: begin
                privileged_controls.opa_sel     =   UIMM;
                privileged_controls.csr_en      =   1'b1;
                privileged_controls.csr_op      =   funct3[1:0];
                privileged_controls.rf_wr_en    =   |rd_o;
                privileged_controls.rf_sel      =   RF_CSR_SRC;
            end
            3'b000: begin
                case (funct12)
                    SRET: begin
                        privileged_controls.pc_sel      =   SEPC;
                        privileged_controls.mctrl_en    =   1'b1;
                        privileged_controls.mctrl_op    =   SRET_OP;
                    end
                    WFI: begin
                        privileged_controls.mctrl_en    =   1'b1;
                        privileged_controls.mctrl_op    =   WFI_OP;
                    end
                    MRET: begin
                        privileged_controls.mctrl_en    =   1'b1;
                        privileged_controls.pc_sel      =   MEPC;
                        privileged_controls.mctrl_op    =   MRET_OP;
                    end
                endcase
            end
        endcase
    end

    assign controls     =   r_type      ?   r_type_controls     :
                            i_type      ?   i_type_controls     : 
                            s_type      ?   s_type_controls     : 
                            b_type      ?   b_type_controls     : 
                            u_type      ?   u_type_controls     : 
                            j_type      ?   j_type_controls     : 
                            a_type      ?   a_type_controls     : 
                            fence       ?   fence_controls      : 
                            privileged  ?   privileged_controls : '0;

    assign pc_sel_o         =   controls.pc_sel;
    assign opa_sel_o        =   controls.opa_sel;
    assign opb_sel_o        =   controls.opb_sel;
    assign word_op_o        =   controls.word_op;
    assign alu_en_o         =   controls.alu_en;
    assign md_en_o          =   controls.md_en;
    assign exu_op_o         =   controls.exu_op;
    assign branch_op_o      =   controls.branch_op;
    assign csr_en_o         =   controls.csr_en;
    assign csr_op_o         =   controls.csr_op;
    assign mctrl_en_o       =   controls.mctrl_en;
    assign mctrl_op_o       =   controls.mctrl_op;
    assign lsu_en_o         =   controls.lsu_en;
    assign lsu_ls_o         =   controls.lsu_ls;
    assign lsu_size_o       =   controls.lsu_size;
    assign atomic_op_o      =   controls.atomic_op;
    assign lsu_se_o         =   controls.lsu_se;
    assign rf_wr_en_o       =   controls.rf_wr_en;
    assign rf_sel_o         =   controls.rf_sel;

endmodule