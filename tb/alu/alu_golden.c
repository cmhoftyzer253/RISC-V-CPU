#include <stdint.h>
#include "alu_golden.h"

void alu_golden (
    int64_t opr_a_i, int64_t opr_b_i, uint32_t alu_valid_i, uint32_t alu_func_i, uint32_t word_op_i, uint32_t flush_i,
    uint32_t *valid_res_o, int64_t *alu_res_o) {

    uint64_t opr_ua = (uint64_t)opr_a_i;
    uint64_t opr_ub = (uint64_t)opr_b_i;
    int64_t opr_a = opr_a_i;
    int64_t opr_b = opr_b_i;

    uint64_t res;
    uint32_t res32;

    uint64_t shift64 = opr_ub & 0x3F;
    uint32_t shift32 = opr_ub & 0x1F;

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
        case OP_ADD:
            if (word_op_i) {
                res32 = (uint32_t)opr_ua + (uint32_t)opr_ub;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = opr_ua + opr_ub;
            }
            break;
        case OP_SUB:
            if (word_op_i) {  
                res32 = (uint32_t)opr_ua - (uint32_t)opr_ub;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = opr_ua - opr_ub;
            }
            break;
        case OP_SLL:
            if (word_op_i) {
                res32 = (uint32_t)opr_ua << shift32;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = opr_ua << shift64;
            }
            break;
        case OP_SRL:
            if (word_op_i) {
                res32 = (uint32_t)opr_ua >> shift32;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = opr_ua >> shift64;
            }
            break;
        case OP_SRA:
            if (word_op_i) {
                res32 = (int32_t)opr_a_i >> shift32;
                res = (uint64_t)(int64_t)(int32_t)res32;
            } else {
                res = (uint64_t)(opr_a_i >> shift64);
            }
            break;
        case OP_OR: res = opr_ua | opr_ub; break;  
        case OP_AND: res = opr_ua & opr_ub; break;
        case OP_XOR: res = opr_ua ^ opr_ub; break;
        case OP_SLTU: res = (opr_ua < opr_ub) ? 1 : 0; break;
        case OP_SLT: res = (opr_a < opr_b) ? 1 : 0; break;
        case OP_PASS_A: res = (uint64_t)opr_a; break;
        default: res = 0; break;
    }

    *valid_res_o = alu_valid_i & !flush_i;
    *alu_res_o = res;

}