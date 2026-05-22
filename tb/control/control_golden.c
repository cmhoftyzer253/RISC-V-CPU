#include <control_golden.h>
#include <stdint.h>

void control_golden (
    uint32_t r_type_i, uint32_t i_type_i, uint32_t s_type_i, uint32_t b_type_i, uint32_t u_type_i, uint32_t j_type_i, uint32_t system_type_i,
    uint32_t instr_funct3_i, uint32_t instr_funct12_i, uint32_t instr_opcode_i,
    uint32_t *pc_sel_o, uint32_t *opa_sel_o, uint32_t *opb_sel_o, uint32_t *exu_func_sel_o, uint32_t *rd_src_o, uint32_t *csr_en_o, uint32_t *csr_rw_o,
    uint32_t *data_req_o, uint32_t *data_byte_o, uint32_t *bypass_avail_o, uint32_t *data_wr_o, uint32_t *zero_extnd_o, uint32_t *rf_wr_en_o, uint32_t *word_op_o, 
    uint32_t *alu_instr_o, uint32_t *mul_instr_o, uint32_t *div_instr_o, uint32_t *mret_o, uint32_t *wfi_o,
    uint32_t *exc_valid_o, uint32_t *exc_code_o
) {
    ctrl_t ctrl = {0};

    uint32_t funct7 = (instr_funct12_i >> 5) & 0x7F;
    
    uint32_t r_type_base_code = (((funct7 >> 5) & 0x1) << 3) | instr_funct3_i;
    uint32_t r_type_m_code = instr_funct3_i;
    uint32_t i_type_code = (((instr_opcode_i >> 4) & 0x1) << 3) | instr_funct3_i;
    uint32_t funct7_b5 = (funct7 >> 5) & 0x1;

    *exc_valid_o = 0;
    *exc_code_o = 0;

    if (r_type_i) {
        ctrl.pc_sel = 0;
        ctrl.opa_sel = RS1_OPERAND_A;
        ctrl.opb_sel = RS2_OPERAND_B;
        ctrl.rd_src = EXU_SRC;
        ctrl.csr_en = 0;
        ctrl.csr_rw = 0;
        ctrl.data_req = 0;
        ctrl.data_byte = BYTE;
        ctrl.bypass_avail = EXU_BYPASS;
        ctrl.data_wr = 0;
        ctrl.zero_extnd = 0;
        ctrl.rf_wr_en = 1;
        ctrl.word_op = (instr_opcode_i == R_TYPE_1);
        ctrl.alu_instr = 0;
        ctrl.mul_instr = 0;
        ctrl.div_instr = 0;
        ctrl.mret = 0;
        ctrl.wfi = 0;    

        if (funct7 == 0x00 || funct7 == 0x20) {
            ctrl.alu_instr = 1;
            ctrl.mul_instr = 0;
            ctrl.div_instr = 0;

            switch (r_type_base_code) {
                case ADD:
                    ctrl.exu_func_sel = OP_ADD; break;
                case AND:
                    ctrl.exu_func_sel = OP_AND; break;
                case OR:
                    ctrl.exu_func_sel = OP_OR; break;
                case SLL:
                    ctrl.exu_func_sel = OP_SLL; break;
                case SLT:
                    ctrl.exu_func_sel = OP_SLT; break;
                case SLTU:
                    ctrl.exu_func_sel = OP_SLTU; break;
                case SRA: 
                    ctrl.exu_func_sel = OP_SRA; break;
                case SRL: 
                    ctrl.exu_func_sel = OP_SRL; break;
                case SUB:
                    ctrl.exu_func_sel = OP_SUB; break;
                case XOR:
                    ctrl.exu_func_sel = OP_XOR; break;
            }
        } else if (funct7 == 0x01) {
            ctrl.alu_instr = 0;
            ctrl.mul_instr = (instr_funct3_i < 0b100);
            ctrl.div_instr = (instr_funct3_i >= 0b100);

            switch (r_type_m_code) {
                case MUL:
                    ctrl.exu_func_sel = OP_MUL; break;
                case MULH:
                    ctrl.exu_func_sel = OP_MULH; break;
                case MULHSU:
                    ctrl.exu_func_sel = OP_MULHSU; break;
                case MULHU:
                    ctrl.exu_func_sel = OP_MULHU; break;
                case DIV:
                    ctrl.exu_func_sel = OP_DIV; break;
                case DIVU:
                    ctrl.exu_func_sel = OP_DIVU; break;
                case REM:
                    ctrl.exu_func_sel = OP_REM; break;
                case REMU:
                    ctrl.exu_func_sel = OP_REMU; break;
            }
        }
    
    } else if (i_type_i) {
        ctrl.opa_sel = RS1_OPERAND_A;
        ctrl.opb_sel = IMM_OPERAND_B;
        ctrl.csr_en = 0;
        ctrl.csr_rw = 0;
        ctrl.rf_wr_en = 1;
        ctrl.word_op = (instr_opcode_i == I_TYPE_3);
        ctrl.alu_instr = 1;
        ctrl.mul_instr = 0;
        ctrl.div_instr = 0;
        ctrl.mret = 0;
        ctrl.wfi = 0;

        //JALR
        if (instr_opcode_i == 0x67) {
            ctrl.pc_sel = 1;
            ctrl.exu_func_sel = OP_ADD;
            ctrl.rd_src = PC_SRC;
            ctrl.data_req = 0;
            ctrl.data_byte = BYTE;
            ctrl.bypass_avail = EXU_BYPASS;
            ctrl.zero_extnd = 0;
        } 
        
        //Load instructions
        else if (instr_opcode_i == 0x03) {
            ctrl.pc_sel = 0;
            ctrl.exu_func_sel = OP_ADD;
            ctrl.rd_src = MEM_SRC;
            ctrl.data_req = 1;
            ctrl.bypass_avail = WB_BYPASS;
            
            switch (i_type_code) {
                case LB:
                    ctrl.data_byte = BYTE;
                    ctrl.zero_extnd = 0;
                    break;
                case LH:
                    ctrl.data_byte = HALF_WORD;
                    ctrl.zero_extnd = 0;
                    break;
                case LW:
                    ctrl.data_byte = WORD;
                    ctrl.zero_extnd = 0;
                    break;
                case LD:
                    ctrl.data_byte = DOUBLE_WORD;
                    ctrl.zero_extnd = 0;
                    break;
                case LBU:
                    ctrl.data_byte = BYTE;
                    ctrl.zero_extnd = 1;
                    break;
                case LHU:
                    ctrl.data_byte = HALF_WORD;
                    ctrl.zero_extnd = 1;
                    break;
                case LWU:
                    ctrl.data_byte = WORD;
                    ctrl.zero_extnd = 1;
                    break;
            }
        } 
        
        //ALU Immediates
        else {
            ctrl.pc_sel = 0;
            ctrl.rd_src = EXU_SRC;
            ctrl.data_req = 0;
            ctrl.data_byte = BYTE;
            ctrl.bypass_avail = EXU_BYPASS;
            ctrl.zero_extnd = 0;
            
            switch (i_type_code) {
                case ADDI:
                    ctrl.exu_func_sel = OP_ADD; break;
                case ANDI:
                    ctrl.exu_func_sel = OP_AND; break;
                case ORI:
                    ctrl.exu_func_sel = OP_OR; break;
                case SLLI:
                    ctrl.exu_func_sel = OP_SLL; break;
                case SRXI:
                    ctrl.exu_func_sel = (funct7_b5) ? OP_SRA : OP_SRL; break;
                case SLTI:
                    ctrl.exu_func_sel = OP_SLT; break;
                case SLTIU:
                    ctrl.exu_func_sel = OP_SLTU; break;
                case XORI:
                    ctrl.exu_func_sel = OP_XOR; break;
            }
        }
    } else if (s_type_i) {
        ctrl.pc_sel = 0;
        ctrl.opa_sel = RS1_OPERAND_A;
        ctrl.opb_sel = IMM_OPERAND_B;
        ctrl.exu_func_sel = OP_ADD;
        ctrl.rd_src = EXU_SRC;
        ctrl.csr_en = 0;
        ctrl.csr_rw = 0;
        ctrl.data_req = 1;
        ctrl.bypass_avail = EXU_BYPASS;
        ctrl.data_wr = 1;
        ctrl.zero_extnd = 0;
        ctrl.rf_wr_en = 0;
        ctrl.word_op = 0;
        ctrl.alu_instr = 1;
        ctrl.mul_instr = 0;
        ctrl.div_instr = 0;
        ctrl.mret = 0;
        ctrl.wfi = 0;

        switch (instr_funct3_i) {
            case SB:
                ctrl.data_byte = BYTE; break;
            case SH:
                ctrl.data_byte = HALF_WORD; break;
            case SW:
                ctrl.data_byte = WORD; break;
            case SD:
                ctrl.data_byte = DOUBLE_WORD; break;
        }

    } else if (b_type_i) {
        ctrl.pc_sel = 0;
        ctrl.opa_sel = PC_OPERAND_A;
        ctrl.opb_sel = IMM_OPERAND_B;
        ctrl.exu_func_sel = OP_ADD;
        ctrl.rd_src = EXU_SRC;
        ctrl.csr_en = 0;
        ctrl.csr_rw = 0;
        ctrl.data_req = 0;
        ctrl.data_byte = BYTE;
        ctrl.bypass_avail = EXU_BYPASS;
        ctrl.data_wr = 0;
        ctrl.zero_extnd = 0;
        ctrl.rf_wr_en = 0;
        ctrl.word_op = 0;
        ctrl.alu_instr = 0;
        ctrl.mul_instr = 0;
        ctrl.div_instr = 0;
        ctrl.mret = 0;
        ctrl.wfi = 0;
    } else if (u_type_i) {
        ctrl.pc_sel = 0;
        ctrl.rd_src = EXU_SRC;
        ctrl.csr_en = 0;
        ctrl.csr_rw = 0;
        ctrl.data_req = 0;
        ctrl.data_byte = BYTE;
        ctrl.bypass_avail = EXU_BYPASS;
        ctrl.data_wr = 0;
        ctrl.zero_extnd = 0;
        ctrl.rf_wr_en = 1;
        ctrl.word_op = 0;
        ctrl.alu_instr = 1;
        ctrl.mul_instr = 0;
        ctrl.div_instr = 0;
        ctrl.mret = 0;
        ctrl.wfi = 0;

        if (instr_opcode_i == 0x37) {
            ctrl.opa_sel = IMM_OPERAND_A;
            ctrl.opb_sel = RS2_OPERAND_B;
            ctrl.exu_func_sel = OP_PASS_A;
        } else if (instr_opcode_i == 0x17) {
            ctrl.opa_sel = PC_OPERAND_A;
            ctrl.opb_sel = IMM_OPERAND_B;
            ctrl.exu_func_sel = OP_ADD;
        }
    } else if (j_type_i) {
        ctrl.pc_sel = 1;
        ctrl.opa_sel = PC_OPERAND_A;
        ctrl.opb_sel = IMM_OPERAND_B;
        ctrl.exu_func_sel = OP_ADD;
        ctrl.rd_src = PC_SRC;
        ctrl.csr_en = 0;
        ctrl.csr_rw = 0;
        ctrl.data_req = 0;
        ctrl.data_byte = BYTE;
        ctrl.bypass_avail = EXU_BYPASS;
        ctrl.data_wr = 0;
        ctrl.zero_extnd = 0;
        ctrl.rf_wr_en = 1;
        ctrl.word_op = 0;
        ctrl.alu_instr = 1;
        ctrl.mul_instr = 0;
        ctrl.div_instr = 0;
        ctrl.mret = 0;
        ctrl.wfi = 0;
    } else if (system_type_i) {
        ctrl.pc_sel = 0;
        ctrl.rd_src = EXU_SRC;
        ctrl.data_req = 0;
        ctrl.data_byte = BYTE;
        ctrl.bypass_avail = EXU_BYPASS;
        ctrl.data_wr = 0;
        ctrl.zero_extnd = 0;
        ctrl.word_op = 0;
        ctrl.mul_instr = 0;
        ctrl.div_instr = 0;

        //Privileged instructions
        if (instr_funct3_i == 0b000) {
            ctrl.opa_sel = RS1_OPERAND_A;
            ctrl.opb_sel = RS2_OPERAND_B;
            ctrl.exu_func_sel = OP_ADD;
            ctrl.csr_en = 0;
            ctrl.csr_rw = 0;
            ctrl.rf_wr_en = 0;
            ctrl.alu_instr = 0;

            switch (instr_funct12_i) {
                case MRET:
                    ctrl.mret = 1; break;
                case WFI:
                    ctrl.wfi = 1; break;
                case ECALL:
                    *exc_valid_o = 1;
                    *exc_code_o = 11;
                    break;
                case EBREAK:
                    *exc_valid_o = 1;
                    *exc_code_o = 3;
                    break;
            }
        } else {
            ctrl.opb_sel = IMM_OPERAND_B;
            ctrl.csr_en = 1;
            ctrl.csr_rw = 1;
            ctrl.rf_wr_en = 1;
            ctrl.alu_instr = 1;
            ctrl.mret = 0;
            ctrl.wfi = 0;

            switch (instr_funct3_i) {
                case CSRRW:
                    ctrl.opa_sel = RS1_OPERAND_A;
                    ctrl.exu_func_sel = OP_PASS_A;
                    break;
                case CSRRS:
                    ctrl.opa_sel = RS1_OPERAND_A;
                    ctrl.exu_func_sel = OP_OR;
                    break;
                case CSRRC:
                    ctrl.opa_sel = RS1_OPERAND_A;
                    ctrl.exu_func_sel = OP_AND;
                    break;
                case CSRRWI:
                    ctrl.opa_sel = IMM_OPERAND_A;
                    ctrl.exu_func_sel = OP_PASS_A;
                    break;
                case CSRRSI:
                    ctrl.opa_sel = IMM_OPERAND_A;
                    ctrl.exu_func_sel = OP_OR;
                    break;
                case CSRRCI:
                    ctrl.opa_sel = IMM_OPERAND_A;
                    ctrl.exu_func_sel = OP_AND;
                    break;
            }
        }
    }

    *pc_sel_o = ctrl.pc_sel;
    *opa_sel_o = ctrl.opa_sel;
    *opb_sel_o = ctrl.opb_sel;
    *exu_func_sel_o = ctrl.exu_func_sel;
    *rd_src_o = ctrl.rd_src;
    *csr_en_o = ctrl.csr_en;
    *csr_rw_o = ctrl.csr_rw;
    *data_req_o = ctrl.data_req;
    *data_byte_o = ctrl.data_byte;
    *bypass_avail_o = ctrl.bypass_avail;
    *data_wr_o = ctrl.data_wr;
    *zero_extnd_o = ctrl.zero_extnd;
    *rf_wr_en_o = ctrl.rf_wr_en;
    *word_op_o = ctrl.word_op;
    *alu_instr_o = ctrl.alu_instr;
    *mul_instr_o = ctrl.mul_instr;
    *div_instr_o = ctrl.div_instr;
    *mret_o = ctrl.mret;
    *wfi_o = ctrl.wfi;

}