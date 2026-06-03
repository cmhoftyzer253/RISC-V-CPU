#include <stdint.h>
#include <multiply_golden.h>

void multiply_golden (
    uint32_t resetn,
    uint64_t opr_a_i, uint64_t opr_b_i, uint32_t mul_valid_i, uint32_t mul_func_i, uint32_t word_op_i, uint32_t *mul_ready_o,
    uint32_t flush_i,
    uint32_t mul_res_ready_i, uint64_t *mul_res_o, uint32_t *mul_res_valid_o
) {
    int128_t mul_res128;
    uint128_t mul_ures128;
    uint64_t mul_ures64;
    uint32_t mul_ures32;

    int64_t opr_a64 = (int64_t)opr_a_i;
    int64_t opr_b64 = (int64_t)opr_b_i;
    int32_t opr_a32 = (int32_t)opr_a_i;
    int32_t opr_b32 = (int32_t)opr_b_i;
    uint32_t opr_ua32 = (uint32_t)opr_a_i;
    uint32_t opr_ub32 = (uint32_t)opr_b_i;

    *mul_ready_o = !mul_res_ready_i;
    *mul_res_valid_o = !flush_i && mul_valid_i;

    switch (mul_func_i) {
        case OP_MUL:
            mul_ures64 = opr_a_i * opr_b_i;
            mul_ures32 = opr_ua32 * opr_ub32;

            *mul_res_o = word_op_i ? (uint64_t)(int64_t)(int32_t)mul_ures32 : mul_ures64;
            break;
        case OP_MULH:
            mul_res128 = (int128_t)opr_a64 * (int128_t)opr_b64;

            *mul_res_o = (uint64_t)(mul_res128 >> 64);
            break;
        case OP_MULHSU:
            mul_res128 = (int128_t)opr_a64 * (int128_t)opr_b64;

            *mul_res_o = (uint64_t)(mul_res128 >> 64);
            break;
        case OP_MULHU:
            mul_ures128 = (uint128_t)opr_a_i * (uint128_t)opr_b_i;

            *mul_res_o = (uint64_t)(mul_ures128 >> 64);
            break;
        case OP_DIV:
            if (word_op_i) {
                if (opr_b32 == 0){
                    *mul_res_o = 0xFFFFFFFFFFFFFFFF;
                } else if (opr_a32 == (int32_t)0x80000000 && opr_b32 == -1) {
                    *mul_res_o = (uint64_t)(int64_t)opr_a32;
                } else {
                    *mul_res_o = (uint64_t)(int64_t)(opr_a32 / opr_b32);
                }
            } else {
                if (opr_b64 == 0) {
                    *mul_res_o = 0xFFFFFFFFFFFFFFFF;
                } else if (opr_a64 == 0x8000000000000000 && opr_b64 == -1) {
                    *mul_res_o = (uint64_t)opr_a64;
                } else {
                    *mul_res_o = (uint64_t)(opr_a64 / opr_b64);
                }
            }
            break;
        case OP_DIVU:
            if (word_op_i) {
                if (opr_ub32 == 0) {
                    *mul_res_o = 0xFFFFFFFFFFFFFFFF;
                } else {
                    mul_ures32 = opr_ua32 / opr_ub32;
                    *mul_res_o = (uint64_t)(int32_t)mul_ures32;
                }
            } else {
                if (opr_b_i == 0) {
                    *mul_res_o = 0xFFFFFFFFFFFFFFFF;
                } else {
                    *mul_res_o = opr_a_i / opr_b_i;
                }
            }
            break;
        case OP_REM:
            if (word_op_i) {
                if (opr_b32 == 0) {
                    *mul_res_o = (uint64_t)(int64_t)opr_a32;
                } else if (opr_a32 == (int32_t)0x80000000 && opr_b32 == -1) {
                    *mul_res_o = 0;
                } else {
                    *mul_res_o = (uint64_t)(int64_t)(opr_a32 % opr_b32);
                }
            } else {
                if (opr_b64 == 0) {
                    *mul_res_o = (uint64_t)opr_a64;
                } else if (opr_a64 == (int64_t)0x8000000000000000 && opr_b64 == -1) {
                    *mul_res_o = 0;
                } else {
                    *mul_res_o = (uint64_t)(opr_a64 % opr_b64);
                }
            }
            break;
        case OP_REMU:
            if (word_op_i) {
                if (opr_ub32 == 0) {
                    *mul_res_o = (uint64_t)(int64_t)(int32_t)opr_ua32;
                } else {
                    *mul_res_o = (uint64_t)(int64_t)(int32_t)(opr_ua32 % opr_ub32);
                }
            } else {
                if (opr_b_i == 0) {
                    *mul_res_o = opr_a_i;
                } else {
                    *mul_res_o = opr_a_i % opr_b_i;
                }
            }
            break;
    }

}