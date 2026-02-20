import cpu_consts::*;

module control (

    //instruction types
    input logic                 r_type_i,
    input logic                 i_type_i,
    input logic                 s_type_i,
    input logic                 b_type_i,
    input logic                 u_type_i,
    input logic                 j_type_i,
    input logic                 zicsr_type_i,

    //instruction opcode and funct fields
    input logic [2:0]           instr_funct3_i,
    input logic                 instr_funct7_bit0_i,
    input logic                 instr_funct7_bit5_i,
    input logic [6:0]           instr_opcode_i,
    
    //control signals
    output logic                pc_sel_o,
    output alu_opr_a_sel_t      opa_sel_o,
    output alu_opr_b_sel_t      opb_sel_o,
    output logic [3:0]          exu_func_sel_o,
    output rd_src_t             rd_src_o,
    output logic                csr_en_o,    
    output logic                data_req_o,
    output mem_access_size_t    data_byte_o,
    output bypass_avail_t       bypass_avail_o,
    output logic                data_wr_o,
    output logic                zero_extnd_o,
    output logic                rf_wr_en_o,
    output logic                word_op_o,
    output logic                alu_instr_o,
    output logic                mul_instr_o,
    output logic                div_instr_o,

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o
);

    logic [3:0] r_type_code;
    logic [3:0] i_type_code;

    logic [6:0] instr_type;

    logic       exc_valid_r;
    logic       exc_valid_i;
    logic       exc_valid_s;
    logic       exc_valid_u;
    logic       exc_valid_zicsr;

    control_t   r_type_controls;
    control_t   i_type_controls;
    control_t   s_type_controls;
    control_t   b_type_controls;
    control_t   u_type_controls;
    control_t   j_type_controls;
    control_t   zicsr_type_controls;
    control_t   controls;          

    // R type instruction
    assign r_type_code = {instr_funct7_bit5_i, instr_funct3_i};
    always_comb begin
        exc_valid_r                 =   1'b0;

        r_type_controls             =   '0;
        r_type_controls.rf_wr_en    =   1'b1;
        r_type_controls.word_op     =   (instr_opcode_i == R_TYPE_1);
        if (instr_funct7_bit0_i) begin
            case ({1'b0, instr_funct3_i})
                MUL     : {r_type_controls.exu_func_sel,
                            r_type_controls.mul_instr} = {OP_MUL, 1'b1};
                MULH    : {r_type_controls.exu_func_sel,
                            r_type_controls.mul_instr} = {OP_MULH, 1'b1};
                MULHSU  : {r_type_controls.exu_func_sel,
                            r_type_controls.mul_instr} = {OP_MULHSU, 1'b1};
                MULHU   : {r_type_controls.exu_func_sel,
                            r_type_controls.mul_instr} = {OP_MULHU, 1'b1};
                DIV     : {r_type_controls.exu_func_sel,
                            r_type_controls.div_instr} = {OP_DIV, 1'b1};
                DIVU    : {r_type_controls.exu_func_sel,
                            r_type_controls.div_instr} = {OP_DIVU, 1'b1};
                REM     : {r_type_controls.exu_func_sel,
                            r_type_controls.div_instr} = {OP_REM, 1'b1};
                REMU    : {r_type_controls.exu_func_sel,
                            r_type_controls.div_instr} = {OP_REMU, 1'b1};
                default: begin
                    exc_valid_r         =   r_type_i; 
                    r_type_controls     =   '0;
                end
            endcase
        end else begin
            case (r_type_code)
                ADD     : {r_type_controls.exu_func_sel, 
                            r_type_controls.alu_instr} = {OP_ADD, 1'b1};
                AND     : {r_type_controls.exu_func_sel,
                            r_type_controls.alu_instr} = {OP_AND, 1'b1};
                OR      : {r_type_controls.exu_func_sel, 
                            r_type_controls.alu_instr} = {OP_OR, 1'b1};
                SLL     : {r_type_controls.exu_func_sel, 
                            r_type_controls.alu_instr} = {OP_SLL, 1'b1};
                SLT     : {r_type_controls.exu_func_sel,
                            r_type_controls.alu_instr} = {OP_SLT, 1'b1};
                SLTU    : {r_type_controls.exu_func_sel, 
                            r_type_controls.alu_instr} = {OP_SLTU, 1'b1};
                SRA     : {r_type_controls.exu_func_sel, 
                            r_type_controls.alu_instr} = {OP_SRA, 1'b1};
                SRL     : {r_type_controls.exu_func_sel, 
                            r_type_controls.alu_instr} = {OP_SRL, 1'b1};
                SUB     : {r_type_controls.exu_func_sel, 
                            r_type_controls.alu_instr} = {OP_SUB, 1'b1};
                XOR     : {r_type_controls.exu_func_sel,
                            r_type_controls.alu_instr} = {OP_XOR, 1'b1};
                default: begin
                    exc_valid_r         =   r_type_i;
                    r_type_controls     =   '0;
                end                                    
            endcase
        end
    end

    // I type instruction
    assign i_type_code = {instr_opcode_i[4], instr_funct3_i};
    always_comb begin
        exc_valid_i                 = 1'b0;

        i_type_controls             = '0;
        i_type_controls.rf_wr_en    = 1'b1;
        i_type_controls.op2_sel     = IMM_OPERAND_B;
        i_type_controls.alu_instr   = 1'b1;  

        //JALR 
        if (instr_opcode_i == I_TYPE_2) begin
            i_type_controls.rd_src          = PC_SRC;
            i_type_controls.pc_sel          = 1'b1;
            i_type_controls.exu_func_sel    = OP_ADD;
        end else begin
            i_type_controls.word_op     =   (instr_opcode_i == I_TYPE_3);
            case (i_type_code)
                ADDI    : i_type_controls.exu_func_sel  =   OP_ADD;
                ANDI    : i_type_controls.exu_func_sel  =   OP_AND;
                ORI     : i_type_controls.exu_func_sel  =   OP_OR;
                SLLI    : i_type_controls.exu_func_sel  =   OP_SLL;
                SRXI    : i_type_controls.exu_func_sel  =   instr_funct7_bit5_i ? OP_SRA : OP_SRL;
                SLTI    : i_type_controls.exu_func_sel  =   OP_SLT;
                SLTIU   : i_type_controls.exu_func_sel  =   OP_SLTU;
                XORI    : i_type_controls.exu_func_sel  =   OP_XOR;
                LB      : {i_type_controls.data_req,
                            i_type_controls.data_byte,
                            i_type_controls.rd_src,
                            i_type_controls.bypass_avail} = {1'b1, BYTE, MEM_SRC, MEM_BYPASS};
                LH      : {i_type_controls.data_req,
                            i_type_controls.data_byte,
                            i_type_controls.rd_src,
                            i_type_controls.bypass_avail} = {1'b1, HALF_WORD, MEM_SRC, MEM_BYPASS};
                LW      : {i_type_controls.data_req,
                            i_type_controls.data_byte,
                            i_type_controls.rd_src,
                            i_type_controls.bypass_avail} = {1'b1, WORD, MEM_SRC, MEM_BYPASS};
                LD      : {i_type_controls.data_req, 
                            i_type_controls.data_byte,
                            i_type_controls.rd_src,
                            i_type_controls.bypass_avail} = {1'b1, DOUBLE_WORD, MEM_SRC, MEM_BYPASS};
                LBU     : {i_type_controls.data_req, 
                            i_type_controls.data_byte,
                            i_type_controls.rd_src,
                            i_type_controls.zero_extnd,
                            i_type_controls.bypass_avail} = {1'b1, BYTE, MEM_SRC, 1'b1, MEM_BYPASS};
                LHU     : {i_type_controls.data_req, 
                            i_type_controls.data_byte,
                            i_type_controls.rd_src,
                            i_type_controls.zero_extnd,
                            i_type_controls.bypass_avail} = {1'b1, HALF_WORD, MEM_SRC, 1'b1, MEM_BYPASS};
                LWU     : {i_type_controls.data_req,
                            i_type_controls.data_byte,
                            i_type_controls.rd_src,
                            i_type_controls.zero_extnd,
                            i_type_controls.bypass_avail} = {1'b1, WORD, MEM_SRC, 1'b1, MEM_BYPASS};
                default : begin
                    exc_valid_i     =   i_type_i;
                    i_type_controls =   '0;
                end
            endcase
        end 
    end

    // S type instruction
    always_comb begin
        exc_valid_s                     = 1'b0;

        s_type_controls                 = '0;
        s_type_controls.data_req        = 1'b1;
        s_type_controls.data_wr         = 1'b1;
        s_type_controls.op2_sel         = IMM_OPERAND_B;
        s_type_controls.exu_func_sel    = OP_ADD;
        s_type_controls.alu_instr       = 1'b1;       
        case (instr_funct3_i)
            SB      : s_type_controls.data_byte = BYTE;
            SH      : s_type_controls.data_byte = HALF_WORD;
            SW      : s_type_controls.data_byte = WORD;
            SD      : s_type_controls.data_byte = DOUBLE_WORD;
            default : begin
                exc_valid_s     =   s_type_i;
                s_type_controls =   '0;
            end
        endcase
    end

    // B type instruction
    always_comb begin
        b_type_controls                 = '0;
        b_type_controls.exu_func_sel    = OP_ADD;        
        b_type_controls.opa_sel         = PC_OPERAND_A;        
        b_type_controls.opb_sel         = IMM_OPERAND_B;     
        b_type_controls.alu_instr       = 1'b1;
    end

    // U type instruction
    always_comb begin
        exc_valid_u                 = 1'b0;

        u_type_controls             = '0;
        u_type_controls.rf_wr_en    = 1'b1;
        case (instr_opcode_i)
            AUIPC   : {u_type_controls.opb_sel, 
                        u_type_controls.opa_sel, 
                        u_type_controls.exu_func_sel,
                        u_type_controls.alu_instr}      = {IMM_OPERAND_B, PC_OPERAND_A, OP_ADD, 1'b1};
            LUI     : u_type_controls.rd_src            = IMM_SRC;
            default : begin
                exc_valid_u     =   u_type_i;
                u_type_controls =   '0;
            end
        endcase
    end

    // J type instruction
    always_comb begin
        j_type_controls                 =   '0;
        j_type_controls.rf_wr_en        =   1'b1;
        j_type_controls.rd_src          =   PC_SRC;
        j_type_controls.opa_sel         =   PC_OPERAND_A;
        j_type_controls.opb_sel         =   IMM_OPERAND_B;
        j_type_controls.pc_sel          =   1'b1;
        j_type_controls.exu_func_sel    =   OP_ADD;
        j_type_controls.alu_instr       =   1'b1;
    end

    // ZICSR type instruction
    always_comb begin
        exc_valid_zicsr                 =   1'b0;

        zicsr_type_controls             =   '0;
        zicsr_type_controls.opa_sel     =   CSR_OPERAND_A;
        zicsr_type_controls.csr_en      =   1'b1;
        zicsr_type_controls.rf_wr_en    =   1'b1;
        zicsr_type_controls.alu_instr   =   1'b1;
        
        case (instr_funct3_i)
            3'b001: {zicsr_type_controls.opb_sel,
                     zicsr_type_controls.exu_func_sel}  = {RS1_OPERAND_B, OP_CSRRW};
            3'b101: {zicsr_type_controls.opb_sel,
                     zicsr_type_controls.exu_func_sel}  = {IMM_OPERAND_B, OP_CSRRW};
            3'b010: {zicsr_type_controls.opb_sel,
                     zicsr_type_controls.exu_func_sel}  = {RS1_OPERAND_B, OP_OR};
            3'b110: {zicsr_type_controls.opb_sel,
                     zicsr_type_controls.exu_func_sel}  = {IMM_OPERAND_B, OP_OR};
            3'b011: {zicsr_type_controls.opb_sel,
                     zicsr_type_controls.exu_func_sel}  = {RS1_OPERAND_B, OP_AND};
            3'b111: {zicsr_type_controls.opb_sel, 
                     zicsr_type_controls.exu_func_sel}  = {IMM_OPERAND_B, OP_AND};   
            default: begin
                exc_valid_zicsr     =   zicsr_type_i;
                zicsr_type_controls =   '0;
            end
        endcase
    end

    assign instr_type                   =   {r_type_i, i_type_i, s_type_i, b_type_i, u_type_i, j_type_i, zicsr_type_i};

    always_comb begin
        unique case (instr_type)
            7'b1000000: begin
                controls        =   r_type_controls;
                exc_valid_o     =   exc_valid_r;
            end
            7'b0100000: begin
                controls        =   i_type_controls;
                exc_valid_o     =   exc_valid_i;
            end
            7'b0010000: begin
                controls        =   s_type_controls;
                exc_valid_o     =   exc_valid_s;
            end
            7'b0001000: begin
                controls        =   b_type_controls;
                exc_valid_o     =   1'b0;
            end
            7'b0000100: begin
                controls        =   u_type_controls;
                exc_valid_o     =   exc_valid_u;
            end
            7'b0000010: begin
                controls        =   j_type_controls;
                exc_valid_o     =   1'b0;
            end
            7'b0000001: begin
                controls        =   zicsr_type_controls;
                exc_valid_o     =   exc_valid_zicsr;
            end
            default: begin
                controls        =   '0;
                exc_valid_o     =   1'b1;
            end
        endcase
    end  

    assign exc_code_o           =   5'd2;             

    // output assigments
    assign pc_sel_o             =   controls.pc_sel;
    assign opa_sel_o            =   controls.opa_sel;
    assign opb_sel_o            =   controls.opb_sel;
    assign exu_func_sel_o       =   controls.exu_func_sel;
    assign rd_src_o             =   controls.rd_src;
    assign csr_en_o             =   controls.csr_en;
    assign data_req_o           =   controls.data_req;
    assign data_byte_o          =   controls.data_byte;
    assign bypass_avail_o       =   controls.bypass_avail;
    assign data_wr_o            =   controls.data_wr;
    assign zero_extnd_o         =   controls.zero_extnd;
    assign rf_wr_en_o           =   controls.rf_wr_en;
    assign word_op_o            =   controls.word_op;
    assign alu_instr_o          =   controls.alu_instr;
    assign mul_instr_o          =   controls.mul_instr;
    assign div_instr_o          =   controls.div_instr;

endmodule
