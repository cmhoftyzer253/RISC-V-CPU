#include <stdint.h>
#include "divide_golden.h"

void divide_golden (
    uint64_t opr_a_i, uint64_t opr_b_i, uint32_t div_func_i, uint32_t word_op_i, 
    uint64_t *div_res_o
) {
    int32_t div_res32;
    uint32_t div_ures32;
    int64_t div_res64;
    uint64_t div_ures64;

    int32_t opr_a32 = (int32_t)opr_a_i;
    int32_t opr_b32 = (int32_t)opr_b_i;
    uint32_t opr_ua32 = (uint32_t)opr_a_i;
    uint32_t opr_ub32 = (uint32_t)opr_b_i;
    int64_t opr_a64 = (int64_t)opr_a_i;
    int64_t opr_b64 = (int64_t)opr_b_i;

    switch (div_func_i) {
        case OP_DIV:
            if (word_op_i) {
                if (opr_b32 == 0) {
                    div_res32 = -1;
                } else if (opr_a32 == INT32_MIN && opr_b32 == -1) {
                    div_res32 = INT32_MIN;
                } else {
                    div_res32 = opr_a32 / opr_b32;
                }

                *div_res_o = (uint64_t)(int64_t)div_res32;
            } else {
                if (opr_b64 == 0) {
                    div_res64 = -1;
                } else if (opr_a64 == INT64_MIN && opr_b64 == -1) {
                    div_res64 = INT64_MIN;
                } else {
                    div_res64 = opr_a64 / opr_b64;
                }

                *div_res_o = (uint64_t)div_res64;
            }
            break;
        case OP_DIVU:
            if (word_op_i) {
                if (opr_ub32 == 0) {
                    div_ures32 = UINT32_MAX;
                } else {
                    div_ures32 = opr_ua32 / opr_ub32;
                }

                *div_res_o = (uint64_t)(int64_t)(int32_t)div_ures32;
            } else {
                if (opr_b_i == 0) {
                    div_ures64 = UINT64_MAX;
                } else {
                    div_ures64 = opr_a_i / opr_b_i;
                }

                *div_res_o = div_ures64;
            }
            break;
        case OP_REM:
            if (word_op_i) {
                if (opr_b32 == 0) {
                    div_res32 = opr_a32;
                } else if (opr_a32 == INT32_MIN && opr_b32 == -1) {
                    div_res32 = 0;
                } else {
                    div_res32 = opr_a32 % opr_b32;
                }

                *div_res_o = (uint64_t)(int64_t)div_res32;
            } else {
                if (opr_b64 == 0) {
                    div_res64 = opr_a64;
                } else if (opr_a64 == INT64_MIN && opr_b64 == -1) {
                    div_res64 = 0;
                } else {
                    div_res64 = opr_a64 % opr_b64;
                }

                *div_res_o = (uint64_t)div_res64;
            }
            break;
        case OP_REMU:
            if (word_op_i) {
                if (opr_ub32 == 0) {
                    div_ures32 = opr_ua32;
                } else {
                    div_ures32 = opr_ua32 % opr_ub32;
                }

                *div_res_o = (uint64_t)(int64_t)(int32_t)div_ures32;
            } else {
                if (opr_b_i == 0) {
                    div_ures64 = opr_a_i;
                } else {
                    div_ures64 = opr_a_i % opr_b_i;
                }

                *div_res_o = div_ures64;
            }
            break;
    }
}