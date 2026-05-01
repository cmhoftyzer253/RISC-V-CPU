#include <stdint.h>

void alu_golden(
    int64_t opr_a_i, int64_t opr_b_i, uint32_t alu_valid_i, uint32_t alu_func_i, uint32_t word_op_i, uint32_t flush_i,
    uint32_t *valid_res_o, int64_t *alu_res_o) {

    uint64_t uopr_a = (uint64_t)opr_a_i;
    uint64_t uopr_b = (uint64_t)opr_b_i;

    uint64_t res;
    uint32_t res32;

    uint64_t shift64 = uopr_b & 0x3F;
    uint32_t shift32 = uopr_b & 0x1F;

    // 0: Addition
    // 1: Subtraction
    // 2: Shift Left (Logic)
    // 3: Shift Right Logic
    // 4: Shift Right Arithmetic
    // 5: Or
    // 6: And
    // 7: Xor
    // 8: Select Less Than Unsigned
    // 9: Select Less Than
    // 10: CSSRW (Pass Through)

    switch (alu_func_i) {
        case 0:
            if (word_op_i) {
                res32 = (uint32_t)uopr_a + (uint32_t)uopr_b;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = uopr_a + uopr_b;
            }
            break;
        case 1:
            if (word_op_i) {  
                res32 = (uint32_t)uopr_a - (uint32_t)uopr_b;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = uopr_a - uopr_b;
            }
            break;
        case 2:
            if (word_op_i) {
                res32 = (uint32_t)uopr_a << shift32;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = uopr_a << shift64;
            }
            break;
        case 3:
            if (word_op_i) {
                res32 = (uint32_t)uopr_a >> shift32;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = uopr_a >> shift64;
            }
            break;
        case 4:
            if (word_op_i) {
                res32 = (int32_t)opr_a_i >> shift32;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = (uint64_t)(opr_a_i >> shift64);
            }
            break;
        case 5:  res = uopr_a | uopr_b; break;  
        case 6:  res = uopr_a & uopr_b; break;
        case 7:  res = uopr_a ^ uopr_b; break;
        case 8:  res = (uopr_a < uopr_b) ? 1 : 0; break;
        case 9:  res = (opr_a_i < opr_b_i) ? 1 : 0; break;
        case 10: res = (uint64_t)opr_a_i; break;
        default: res = 0; break;
    }

    *valid_res_o = alu_valid_i & !flush_i;
    *alu_res_o = res;

}