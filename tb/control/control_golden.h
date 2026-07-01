#include <stdint.h>

    #define R_TYPE_0 0x33
    #define R_TYPE_1 0x3B
    #define I_TYPE_0 0x03
    #define I_TYPE_1 0x13
    #define I_TYPE_2 0x67
    #define I_TYPE_3 0x1B
    #define S_TYPE 0x23
    #define B_TYPE 0x63
    #define U_TYPE_0 0x37
    #define U_TYPE_1 0x17
    #define J_TYPE 0x6F
    #define SYSTEM_TYPE 0x73

    #define OP_ADD 0x0
    #define OP_SUB 0x1
    #define OP_SLL 0x2
    #define OP_SRL 0x3
    #define OP_SRA 0x4
    #define OP_OR 0x5
    #define OP_AND 0x6
    #define OP_XOR 0x7
    #define OP_SLTU 0x8
    #define OP_SLT 0x9
    #define OP_PASS_A 0xA

    #define OP_MUL 0x0
    #define OP_MULH 0x1
    #define OP_MULHSU 0x2
    #define OP_MULHU 0x3
    #define OP_DIV 0x4
    #define OP_DIVU 0x5
    #define OP_REM 0x6
    #define OP_REMU 0x7

    #define BYTE 0x0
    #define HALF_WORD 0x1
    #define WORD 0x2
    #define DOUBLE_WORD 0x3

    #define EXU_BYPASS 0x0
    #define WB_BYPASS 0x1

    #define EXU_SRC 0x0
    #define MEM_SRC 0x1
    #define IMM_SRC 0x2
    #define PC_SRC 0x3
    #define CSR_SRC 0x4

    #define RS1_OPERAND_A 0x0
    #define PC_OPERAND_A 0x1
    #define CSR_OPERAND_A 0x2
    #define IMM_OPERAND_A 0x3

    #define RS2_OPERAND_B 0x0
    #define IMM_OPERAND_B 0x1
    #define RS1_OPERAND_B 0x2

    #define ADD 0x0
    #define AND 0x7
    #define OR 0x6
    #define SLL 0x1
    #define SLT 0x2
    #define SLTU 0x3
    #define SRA 0xD
    #define SRL 0x5
    #define SUB 0x8
    #define XOR 0x4

    #define MUL 0x0
    #define MULH 0x1
    #define MULHSU 0x2
    #define MULHU 0x3
    #define DIV 0x4
    #define DIVU 0x5
    #define REM 0x6
    #define REMU 0x7

    #define LB 0x0
    #define LBU 0x4
    #define LH 0x1
    #define LHU 0x5
    #define LW 0x2
    #define LWU 0x6
    #define LD 0x3
    #define ADDI 0x8
    #define ANDI 0xF
    #define ORI 0xE
    #define SLLI 0x9
    #define SRXI 0xD
    #define SLTI 0xA
    #define SLTIU 0xB
    #define XORI 0xC

    #define SB 0x0
    #define SH 0x1
    #define SW 0x2
    #define SD 0x3

    #define AUIPC 0x17
    #define LUI 0x37

    #define CSRRW 0x1
    #define CSRRS 0x2
    #define CSRRC 0x3
    #define CSRRWI 0x5
    #define CSRRSI 0x6
    #define CSRRCI 0x7

    #define ECALL 0x0
    #define EBREAK 0x1
    #define MRET 0x302
    #define WFI 0x105

    typedef struct {
        uint32_t pc_sel         : 1;
        uint32_t opa_sel        : 2;
        uint32_t opb_sel        : 2;
        uint32_t exu_func_sel   : 4;
        uint32_t rd_src         : 3;
        uint32_t csr_en         : 1;
        uint32_t csr_rw         : 1;
        uint32_t data_req       : 1;
        uint32_t data_byte      : 2;
        uint32_t bypass_avail   : 1;
        uint32_t data_wr        : 1;
        uint32_t zero_extnd     : 1;
        uint32_t rf_wr_en       : 1;
        uint32_t word_op        : 1;
        uint32_t alu_instr      : 1;
        uint32_t mul_instr      : 1;
        uint32_t div_instr      : 1;
        uint32_t mret           : 1;
        uint32_t wfi            : 1;
    } ctrl_t;