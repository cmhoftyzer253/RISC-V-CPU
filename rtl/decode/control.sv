import cpu_consts::*;

module control (

    //instruction types
    input logic is_r_type_i,
    input logic is_i_type_i,
    input logic is_s_type_i,
    input logic is_b_type_i,
    input logic is_u_type_i,
    input logic is_j_type_i,

    //instruction opcode and funct fields
    input logic [2:0]   instr_funct3_i,
    input logic         instr_funct7_bit5_i,
    input logic [6:0]   instr_opcode_i,
    
    //control signals
    output logic        pc_sel_o,
    output logic        op1_sel_o,
    output logic        op2_sel_o,
    output logic [3:0]  alu_func_sel_o,
    output logic [1:0]  rf_wr_data_src_o,    
    output logic        data_req_o,
    output logic [1:0]  data_byte_o,
    output logic        data_wr_o,
    output logic        zero_extnd_o,
    output logic        rf_wr_en_o,
    output logic        word_op_o

);

    logic [3:0] r_type_code;
    logic [3:0] i_type_code;

    control_t r_type_controls;
    control_t i_type_controls;
    control_t s_type_controls;
    control_t b_type_controls;
    control_t u_type_controls;
    control_t j_type_controls;
    control_t controls;

    // R type instruction
    assign r_type_code = {instr_funct7_bit5_i, instr_funct3_i};
    always_comb begin
        r_type_controls             = '0;
        r_type_controls.rf_wr_en    = 1'b1;
        r_type_controls.word_op      = (instr_opcode_i == R_TYPE_1) ? 1'b1 : 1'b0;
        case (r_type_code)
            ADD     : r_type_controls.alu_func_sel = OP_ADD;
            AND     : r_type_controls.alu_func_sel = OP_AND;
            OR      : r_type_controls.alu_func_sel = OP_OR;
            SLL     : r_type_controls.alu_func_sel = OP_SLL;
            SLT     : r_type_controls.alu_func_sel = OP_SLT;
            SLTU    : r_type_controls.alu_func_sel = OP_SLTU;
            SRA     : r_type_controls.alu_func_sel = OP_SRA;
            SRL     : r_type_controls.alu_func_sel = OP_SRL;
            SUB     : r_type_controls.alu_func_sel = OP_SUB;
            XOR     : r_type_controls.alu_func_sel = OP_XOR;
            default : r_type_controls.alu_func_sel = OP_ADD;                                    
        endcase
    end

    // I type instruction
    assign i_type_code = {instr_opcode_i[4], instr_funct3_i};
    always_comb begin
        i_type_controls             = '0;
        i_type_controls.rf_wr_en    = 1'b1;
        i_type_controls.op2_sel     = 1'b1;
        i_type_controls.word_op     = (instr_opcode_i == I_TYPE_3) ? 1'b1 : 1'b0;
        case (i_type_code)
            ADDI    : i_type_controls.alu_func_sel = OP_ADD;
            ANDI    : i_type_controls.alu_func_sel = OP_AND;
            ORI     : i_type_controls.alu_func_sel = OP_OR;
            SLLI    : i_type_controls.alu_func_sel = OP_SLL;
            SRXI    : i_type_controls.alu_func_sel = instr_funct7_bit5_i ? OP_SRA : OP_SRL;
            SLTI    : i_type_controls.alu_func_sel = OP_SLT;
            SLTIU   : i_type_controls.alu_func_sel = OP_SLTU;
            XORI    : i_type_controls.alu_func_sel = OP_XOR;
            LB      : {i_type_controls.data_req,
                        i_type_controls.data_byte,
                        i_type_controls.rf_wr_data_sel} = {1'b1, BYTE, MEM};
            LH      : {i_type_controls.data_req,
                        i_type_controls.data_byte,
                        i_type_controls.rf_wr_data_sel} = {1'b1, HALF_WORD, MEM};
            LW      : {i_type_controls.data_req,
                        i_type_controls.data_byte,
                        i_type_controls.rf_wr_data_sel} = {1'b1, WORD, MEM};
            LD      : {i_type_controls.data_req, 
                        i_type_controls.data_byte,
                        i_type_controls.rf_wr_data_sel} = {1'b1, DOUBLE_WORD, MEM};
            LBU     : {i_type_controls.data_req, 
                        i_type_controls.data_byte,
                        i_type_controls.rf_wr_data_sel,
                        i_type_controls.zero_extnd} = {1'b1, BYTE, MEM, 1'b1};
            LHU     : {i_type_controls.data_req, 
                        i_type_controls.data_byte,
                        i_type_controls.rf_wr_data_sel,
                        i_type_controls.zero_extnd} = {1'b1, HALF_WORD, MEM, 1'b1};
            LWU     : {i_type_controls.data_req,
                        i_type_controls.data_byte,
                        i_type_controls.rf_wr_data_sel,
                        i_type_controls.zero_extnd} = {1'b1, WORD, MEM, 1'b1};
            default : i_type_controls = '0;
        endcase
        //JALR instruction
        if (instr_opcode_i == I_TYPE_2) begin
            i_type_controls.rf_wr_data_sel  = PC;
            i_type_controls.pc_sel          = 1'b1;
            i_type_controls.alu_func_sel    = OP_ADD;
        end
    end

    // S type instruction
    always_comb begin
        s_type_controls                 = '0;
        s_type_controls.data_req        = 1'b1;
        s_type_controls.data_wr         = 1'b1;
        s_type_controls.op2_sel         = 1'b1;
        s_type_controls.alu_func_sel    = OP_ADD;       
        case (instr_funct3_i)
            SB      : s_type_controls.data_byte = BYTE;
            SH      : s_type_controls.data_byte = HALF_WORD;
            SW      : s_type_controls.data_byte = WORD;
            SD      : s_type_controls.data_byte = DOUBLE_WORD;
            default : s_type_controls = '0;
        endcase
    end

    // B type instruction
    always_comb begin                          
        b_type_controls                 = '0;
        b_type_controls.alu_func_sel    = OP_ADD;        
        b_type_controls.op1_sel         = 1'b1;        
        b_type_controls.op2_sel         = 1'b1;     
    end

    // U type instruction
    always_comb begin
        u_type_controls             = '0;
        u_type_controls.rf_wr_en    = 1'b1;
        case (instr_opcode_i)
            AUIPC   : {u_type_controls.op2sel, 
                        u_type_controls.op1sel, 
                        u_type_controls.alu_func_sel} = {1'b1, 1'b1, OP_ADD};
            LUI     : u_type_controls.rf_wr_data_src = IMM;
            default : u_type_controls = '0;
        endcase
    end

    // J type instruction
    always_comb begin
        j_type_controls                 = '0;
        j_type_controls.rf_wr_en        = 1'b1;
        j_type_controls.rf_wr_data_src  = PC;
        j_type_controls.op1_sel         = 1'b1;
        j_type_controls.op2_sel         = 1'b1;
        j_type_controls.pc_sel          = 1'b1;
        j_type_controls.alu_func_sel    = OP_ADD;
    end

    assign controls =   is_r_type_i         ? r_type_controls : 
                        is_i_type_i         ? i_type_controls :
                        is_s_type_i         ? s_type_controls :
                        is_b_type_i         ? b_type_controls :
                        is_u_type_i         ? u_type_controls :
                        is_j_type_i         ? j_type_controls :
                                            '0;

    // output assigments
    assign pc_sel_o             = controls.pc_sel;
    assign op1_sel_o            = controls.op1_sel;
    assign op2_sel_o            = controls.op2_sel;
    assign alu_func_sel_o       = controls.alu_func_sel;
    assign rf_wr_en_o           = controls.rf_wr_en;
    assign data_req_o           = controls.data_req;
    assign data_byte_o          = controls.data_byte;
    assign data_wr_o            = controls.data_wr;
    assign zero_extnd_o         = controls.zero_extnd;
    assign rf_wr_data_src_o     = controls.rf_wr_data_src;
    assign word_op_o            = controls.word_op;

endmodule
