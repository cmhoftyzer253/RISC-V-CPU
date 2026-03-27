#include <stdint.h>

void decode_golden (
    uint32_t instr_i, 
    uint32_t *rs1_o, uint32_t *rs2_o, uint8_t *rd_o, uint32_t *op_o, uint32_t *funct3_o, uint32_t *funct12_o, uint32_t *csr_addr_o, 
    uint32_t *r_type_o, uint32_t *i_type_o, uint32_t *s_type_o, uint32_t *b_type_o, uint32_t *u_type_o, uint32_t *j_type_o, uint32_t *system_type_o,
    uint64_t *imm_o, uint32_t *exc_valid_o, uint32_t *exc_code_o
) {

    uint32_t r_type = ((instr_i & 0x7F) == 0x33) | ((instr_i & 0x7F) == 0x3B);
    uint32_t i_type = ((instr_i & 0x7F) == 0x03) | ((instr_i & 0x7F) == 0x13) | ((instr_i & 0x7F) == 0x67) | ((instr_i & 0x7F) == 0x1B);
    uint32_t s_type = ((instr_i & 0x7F) == 0x23);
    uint32_t b_type = ((instr_i & 0x7F) == 0x63);
    uint32_t u_type = ((instr_i & 0x7F) == 0x37) | ((instr_i & 0x7F) == 0x17);
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
        *exc_valid_o = 1;
        *exc_code_o = 2;
    }
}