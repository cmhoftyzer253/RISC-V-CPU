#include <stdint.h>
#include <branch_control_golden.h>

void branch_control_golden (
    uint64_t opr_a_i, uint64_t opr_b_i, uint32_t is_b_type_i, uint32_t instr_funct3_i,
    uint32_t *branch_taken_o
) {

    int64_t opr_a = (int64_t)opr_a_i;
    int64_t opr_b = (int64_t)opr_b_i;

    uint64_t opr_ua = opr_a_i;
    uint64_t opr_ub = opr_b_i;

    uint32_t branch_taken;

    switch (instr_funct3_i) {
        case BEQ:
            branch_taken = (opr_a == opr_b) ? 1 : 0; break;
        case BNE: 
            branch_taken = (opr_a != opr_b) ? 1 : 0; break;
        case BLT: 
            branch_taken = (opr_a < opr_b) ? 1 : 0; break;
        case BGE: 
            branch_taken = (opr_a >= opr_b) ? 1 : 0; break;
        case BLTU:
            branch_taken = (opr_ua < opr_ub) ? 1 : 0; break;
        case BGEU:
            branch_taken = (opr_ua >= opr_ub) ? 1 : 0; break;
        default: 
            branch_taken = 0;
    }

    *branch_taken_o = branch_taken & is_b_type_i;
}