#include <stdint.h>
#include <stdbool.h>

void decode_golden (
    uint32_t instr_i, 
    uint32_t *rs1_o, uint32_t *rs2_o, uint32_t *rd_o, uint32_t *op_o, uint32_t *funct3_o, uint32_t *funct12_o, uint32_t *csr_addr_o, 
    uint32_t *r_type_o, uint32_t *i_type_o, uint32_t *s_type_o, uint32_t *b_type_o, uint32_t *u_type_o, uint32_t *j_type_o, uint32_t *system_type_o,
    uint64_t *imm_o, uint32_t *exc_valid_o, uint32_t *exc_code_o
) {
    uint32_t exc_opcode = 0;
    uint32_t exc_funct;

    uint32_t exc_funct_rtype_0;
    uint32_t exc_funct_rtype_1;
    uint32_t exc_funct_rtype;

    uint32_t r_type_0 = ((instr_i & 0x7F) == 0x33);
    uint32_t r_type_1 = ((instr_i & 0x7F) == 0x3B);
    uint32_t r_type = r_type_0 | r_type_1;

    uint32_t i_type_0 = ((instr_i & 0x7F) == 0x03);
    uint32_t i_type_1 = ((instr_i & 0x7F) == 0x13);
    uint32_t i_type_2 = ((instr_i & 0x7F) == 0x67);
    uint32_t i_type_3 = ((instr_i & 0x7F) == 0x1B);
    uint32_t i_type = i_type_0 | i_type_1 | i_type_2 | i_type_3;

    uint32_t s_type = ((instr_i & 0x7F) == 0x23);
    uint32_t b_type = ((instr_i & 0x7F) == 0x63);

    uint32_t u_type_0 = ((instr_i & 0x7F) == 0x37);
    uint32_t u_type_1 = ((instr_i & 0x7F) == 0x17);
    uint32_t u_type = u_type_0 | u_type_1;

    uint32_t j_type = ((instr_i & 0x7F) == 0x6F);
    uint32_t system_type = ((instr_i & 0x7F) == 0x73);

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

    if (r_type) {
        
    } else if (i_type) {
        *rs2_o = 0;
        *imm_o = (uint64_t)(int64_t)((int32_t)instr_i >> 20);
    } else if (s_type) {
        *rd_o = 0;

        int32_t imm_11_5 = (((int32_t)instr_i) >> 20) & ~0x1F; 
        uint32_t imm_4_0 = ((instr_i & 0xF80) >> 7);

        *imm_o = (uint64_t)(int64_t)(imm_11_5 | (int32_t)imm_4_0);
    } else if (b_type) {
        *rd_o = 0;

        int32_t imm_12 = (((int32_t)instr_i) >> 19) & ~0xFFF;
        uint32_t imm_11 = (instr_i & 0x80) << 4;
        uint32_t imm_10_5 = (instr_i & 0x7E000000) >> 20;
        uint32_t imm_4_1 = (instr_i & 0xF00) >> 7;

        *imm_o = (uint64_t)(int64_t)(imm_12 | (int32_t)imm_11 | (int32_t)imm_10_5 | (int32_t)imm_4_1);
    } else if (u_type) {
        *rs1_o = 0;
        *rs2_o = 0;
        *imm_o = (uint64_t)(int64_t)(int32_t)(instr_i & ~0xFFF);
    } else if (j_type) {
        *rs1_o = 0;
        *rs2_o = 0;

        int32_t imm_20 = (((int32_t)instr_i) >> 11) & ~0xFFFFF;
        uint32_t imm_10_1 = (instr_i & 0x7FE00000) >> 20;
        uint32_t imm_11 = (instr_i & 0x100000) >> 9;
        uint32_t imm_19_12 = (instr_i & 0xFF000);

        *imm_o = (uint64_t)(int64_t)(imm_20 | (int32_t)imm_19_12 | (int32_t)imm_11 | (int32_t)imm_10_1);
    } else if (system_type) {
        *rs2_o = 0;
        *csr_addr_o = (instr_i & 0xFFF00000) >> 20;
        *imm_o = (instr_i & 0xF8000) >> 15;
    } else {
        exc_opcode = 1;
    }

    uint32_t funct7 = (*funct12_o >> 5) & 0x7F;
    uint32_t funct6 = (funct7 >> 1) & 0x3F;

    uint32_t funct3 = *funct3_o;
    uint32_t funct12 = *funct12_o;
    uint32_t opcode = (instr_i & 0x7F);

    bool legal_rtype_0 = false;
    bool legal_rtype_1 = false;
    bool legal_itype_0 = false;
    bool legal_itype_1 = false;
    bool legal_itype_2 = false;
    bool legal_itype_3 = false;
    bool legal_stype = false;
    bool legal_btype = false;
    bool legal_systemtype = false;

    switch (opcode) {
        case 0x33: 
            switch (funct7) {
                case 0x00: legal_rtype_0 = true; break;
                case 0x01: legal_rtype_0 = true; break;
                case 0x20: legal_rtype_0 = (*funct3_o == 0b000) || (*funct3_o == 0b101); break;
                default: legal_rtype_0 = false;
            }
            break;

        case 0x3B:
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
            break;
        
        case 0x03: 
            legal_itype_0 = (funct3 != 0b111); break;

        case 0x13:
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
            break;

        case 0x67:
            legal_itype_2 = (funct3 == 0b000); break;

        case 0x1B:
            switch (funct3) {
                case 0b000: legal_itype_3 = true; break;
                case 0b001: legal_itype_3 = (funct7 == 0x0); break;
                case 0b101: legal_itype_3 = (funct7 == 0x0) || (funct7 == 0x20); break;
                default: legal_itype_3 = false;
            }
            break;

        case 0x23:
            legal_stype = (funct3 <= 0b011); break;

        case 0x63:
            legal_btype = (funct3 != 0b010) && (funct3 != 0b011); break;
            
        case 0x73:
            switch (funct3) {
                case 0b000:
                    legal_systemtype = (funct12 == 0x000) || (funct12 == 0x001) || (funct12 == 0x302) || (funct12 == 0x105); break;
                case 0b100:
                    legal_systemtype = false; break;
                default:
                    legal_systemtype = true; break;
            }
            break;
    }

    exc_funct = !(legal_rtype_0 || legal_rtype_1 || legal_itype_0 || legal_itype_1 || legal_itype_2 || legal_itype_3 
                || legal_stype || legal_btype || legal_systemtype || u_type || j_type);

    *exc_valid_o = exc_opcode || exc_funct;
    *exc_code_o = *exc_valid_o ? 2 : 0;
}