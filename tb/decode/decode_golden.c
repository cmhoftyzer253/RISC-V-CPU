#include <stdint.h>
#include <stdbool.h>
#include "decode_golden.h"

void decode_golden (
    uint32_t instr_i, 
    uint32_t *rs1_o, uint32_t *rs2_o, uint32_t *rd_o, uint32_t *op_o, uint32_t *funct3_o, uint32_t *funct12_o, uint32_t *csr_addr_o, 
    uint32_t *r_type_o, uint32_t *i_type_o, uint32_t *s_type_o, uint32_t *b_type_o, uint32_t *u_type_o, uint32_t *j_type_o, uint32_t *system_type_o,
    uint64_t *imm_o, uint32_t *exc_valid_o, uint32_t *exc_code_o
) {

    uint32_t r_type_0 = ((instr_i & 0x7F) == R_TYPE_0);
    uint32_t r_type_1 = ((instr_i & 0x7F) == R_TYPE_1);
    uint32_t r_type = r_type_0 | r_type_1;

    uint32_t i_type_0 = ((instr_i & 0x7F) == I_TYPE_0);
    uint32_t i_type_1 = ((instr_i & 0x7F) == I_TYPE_1);
    uint32_t i_type_2 = ((instr_i & 0x7F) == I_TYPE_2);
    uint32_t i_type_3 = ((instr_i & 0x7F) == I_TYPE_3);
    uint32_t i_type = i_type_0 | i_type_1 | i_type_2 | i_type_3;

    uint32_t s_type = ((instr_i & 0x7F) == S_TYPE);
    uint32_t b_type = ((instr_i & 0x7F) == B_TYPE);

    uint32_t u_type_0 = ((instr_i & 0x7F) == U_TYPE_0);
    uint32_t u_type_1 = ((instr_i & 0x7F) == U_TYPE_1);
    uint32_t u_type = u_type_0 | u_type_1;

    uint32_t j_type = ((instr_i & 0x7F) == J_TYPE);
    uint32_t system_type = ((instr_i & 0x7F) == SYSTEM_TYPE);

    *exc_valid_o = 0;
    *exc_code_o = 0;

    *rs1_o = (instr_i >> 15) & 0x1F;
    *rs2_o = (instr_i >> 20) & 0x1F;
    *rd_o = (instr_i >> 7) & 0x1F;
    *op_o = instr_i & 0x7F;
    *funct3_o = (instr_i >> 12) & 0x7;
    *funct12_o = (instr_i >> 20) & 0xFFF;

    *r_type_o = r_type;
    *i_type_o = i_type;
    *s_type_o = s_type;
    *b_type_o = b_type;
    *u_type_o = u_type;
    *j_type_o = j_type;
    *system_type_o = system_type;

    *csr_addr_o = 0;
    *imm_o = 0;

    uint32_t funct7 = (*funct12_o >> 5) & 0x7F;
    uint32_t funct6 = (funct7 >> 1) & 0x3F;

    uint32_t funct3 = *funct3_o;
    uint32_t funct12 = *funct12_o;
    uint32_t opcode = (instr_i & 0x7F);

    bool legal_rtype_0 = false;
    bool legal_rtype_1 = false;
    bool legal_itype_1 = false;
    bool legal_itype_3 = false;
    bool legal_systemtype = false;

    int32_t s_imm_11_5;
    uint32_t s_imm_4_0;

    int32_t b_imm_12;
    uint32_t b_imm_11;
    uint32_t b_imm_10_5;
    uint32_t b_imm_4_1;

    int32_t j_imm_20;
    uint32_t j_imm_10_1;
    uint32_t j_imm_11;
    uint32_t j_imm_19_12;

    switch (opcode) {
        case R_TYPE_0:
            switch (funct7) {
                case 0x00: legal_rtype_0 = true; break;
                case 0x01: legal_rtype_0 = true; break;
                case 0x20: legal_rtype_0 = (*funct3_o == 0b000) || (*funct3_o == 0b101); break;
                default: legal_rtype_0 = false;
            }

            *exc_valid_o = !legal_rtype_0;
            break;

        case R_TYPE_1:
            switch (funct7) {
                case 0x00: 
                    legal_rtype_1 = (funct3 == 0b000) || (funct3 == 0b001) || (funct3 == 0b101); 
                    break;
                case 0x01: 
                    legal_rtype_1 = (funct3 == 0b000) || (funct3 == 0b100) || (funct3 == 0b101) || (funct3 == 0b110) || (funct3 == 0b111); 
                    break;
                case 0x20: 
                    legal_rtype_1 = (funct3 == 0b000) || (funct3 == 0b101);
                    break;
                default: legal_rtype_1 = false;
            }

            *exc_valid_o = !legal_rtype_1;
            break;

        case I_TYPE_0:
            *rs2_o = 0;
            *imm_o = (uint64_t)(int64_t)((int32_t)instr_i >> 20);

            *exc_valid_o = (funct3 == 0b111);
            break;

        case I_TYPE_1:
            *rs2_o = 0;
            *imm_o = (uint64_t)(int64_t)((int32_t)instr_i >> 20);    

            switch (funct3) {
                case 0b000: 
                case 0b010: 
                case 0b011:
                case 0b100: 
                case 0b110: 
                case 0b111: legal_itype_1 = true; break;
                case 0b001: legal_itype_1 = (funct6 == 0x0); break;                     
                case 0b101: legal_itype_1 = (funct6 == 0x0) || (funct6 == 0x10); break;
            }

            *exc_valid_o = !legal_itype_1;
            break;

        case I_TYPE_2:
            *rs2_o = 0;
            *imm_o = (uint64_t)(int64_t)((int32_t)instr_i >> 20);

            *exc_valid_o = (funct3 != 0b000);
            break;

        case I_TYPE_3:
            *rs2_o = 0;
            *imm_o = (uint64_t)(int64_t)((int32_t)instr_i >> 20);

            switch (funct3) {
                case 0b000: legal_itype_3 = true; break;
                case 0b001: legal_itype_3 = (funct7 == 0x0); break;
                case 0b101: legal_itype_3 = (funct7 == 0x0) || (funct7 == 0x20); break;
                default: legal_itype_3 = false;
            }

            *exc_valid_o = !legal_itype_3;
            break;

        case S_TYPE:
            *rd_o = 0;

            s_imm_11_5 = (((int32_t)instr_i) >> 20) & ~0x1F; 
            s_imm_4_0 = ((instr_i & 0xF80) >> 7);

            *imm_o = (uint64_t)(int64_t)(s_imm_11_5 | (int32_t)s_imm_4_0);

            *exc_valid_o = (funct3 > 0b011);
            break;

        case B_TYPE:
            *rd_o = 0;

            b_imm_12 = (((int32_t)instr_i) >> 19) & ~0xFFF;
            b_imm_11 = (instr_i & 0x80) << 4;
            b_imm_10_5 = (instr_i & 0x7E000000) >> 20;
            b_imm_4_1 = (instr_i & 0xF00) >> 7;

            *imm_o = (uint64_t)(int64_t)(b_imm_12 | (int32_t)b_imm_11 | (int32_t)b_imm_10_5 | (int32_t)b_imm_4_1);    

            *exc_valid_o = (funct3 == 0b010) || (funct3 == 0b011); 
            break;

        case U_TYPE_0:
        case U_TYPE_1:
            *rs1_o = 0;
            *rs2_o = 0;
            *imm_o = (uint64_t)(int64_t)(int32_t)(instr_i & ~0xFFF);

            *exc_valid_o = 0;
            break;

        case J_TYPE:
            *rs1_o = 0;
            *rs2_o = 0;

            j_imm_20 = (((int32_t)instr_i) >> 11) & ~0xFFFFF;
            j_imm_10_1 = (instr_i & 0x7FE00000) >> 20;
            j_imm_11 = (instr_i & 0x100000) >> 9;
            j_imm_19_12 = (instr_i & 0xFF000);

            *imm_o = (uint64_t)(int64_t)(j_imm_20 | (int32_t)j_imm_19_12 | (int32_t)j_imm_11 | (int32_t)j_imm_10_1);

            *exc_valid_o = 0;
            break;

        case SYSTEM_TYPE:
            *rs2_o = 0;
            *csr_addr_o = (instr_i & 0xFFF00000) >> 20;
            *imm_o = (instr_i & 0xF8000) >> 15;

            switch (funct3) {
                case 0b000:
                    legal_systemtype = ((funct12 == 0x000) || (funct12 == 0x001) || (funct12 == 0x302) || (funct12 == 0x105)) && (*rs1_o == 0) && (*rd_o == 0); break;
                case 0b100:
                    legal_systemtype = false; break;
                default:
                    legal_systemtype = true; break;
            }
            *exc_valid_o = !legal_systemtype;
            break;

        default:
            *exc_valid_o = 1;
    }

    *exc_code_o = *exc_valid_o ? 2 : 0;
}