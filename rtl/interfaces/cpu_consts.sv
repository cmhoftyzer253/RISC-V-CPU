package cpu_consts;

    //Instruction types
    typedef enum logic[6:0] {
        R_TYPE      = 7'h33,
        I_TYPE_0    = 7'h03,
        I_TYPE_1    = 7'h13,
        I_TYPE_2    = 7'h67,
        S_TYPE      = 7'h23,
        B_TYPE      = 7'h63,
        U_TYPE_0    = 7'h37,
        U_TYPE_1    = 7'h17,
        J_TYPE      = 7'h6F
    } riscv_op_t;

    //memory access width
    typedef enum logic[1:0] {
        BYTE        = 2'b00,
        HALF_WORD   = 2'b01,
        WORD        = 2'b10,
        DOUBLE_WORD = 2'b11
    } mem_access_size_t;

    //  R type instructions
    // {funct7[5], funct3}
    typedef enum logic[3:0] {
        ADD     = 4'h0,
        AND     = 4'h7,
        OR      = 4'h6,
        SLL     = 4'h1,
        SLT     = 4'h2,
        SLTU    = 4'h3,
        STA     = 4'hD,
        SRL     = 4'h5,
        SUB     = 4'h8,
        XOR     = 4'h4
    } r_type_t;

    //  I type instructions excluding JALR, SLLI, SRLI, SRAI
    // {opcode[4], funct3}
    typedef enum logic[3:0] {
        LB      = 4'h0,
        LBU     = 4'h4,
        LH      = 4'h1,
        LHU     = 4'h5,
        LW      = 4'h2,
        ADDI    = 4'h8,
        ANDI    = 4'hF,
        ORI     = 4'hE,
        SLTI    = 4'hA,
        SLTIU   = 4'hB,
        XORI    = 4'hC
    } i_type_t;

    //I type instructions - SLLI, SRLI, SRAI
    // {funct7[5], funct3}
    typedef enum logic[3:0] {
        SLLI = 4'h1;
        SRLI = 4'h5;
        SRAI = 4'hD;
    } i_type_shift_t;

    //  S type instructions
    typedef enum logic[2:0] {
        SB = 3'h0,
        SH = 3'h1,
        SW = 3'h2
    } s_type_t;

    // B type instructions
    typedef enum logic[6:0] {
        BEQ     = 3'h0,
        BNE     = 3'h1,
        BLT     = 3'h4,
        BGE     = 3'h5,
        BLTU    = 3'h6,
        BGEU    = 3'h7
    } b_type_t;

    // U type instructions
    typedef enum logic[6:0] {
        AUIPC = 7'h17,
        LUI = 7'h37
    } u_type_t;

    // J type instructions
    typedef enum logic[5:0] {
        JAL = 6'h3
    } j_type_t;

endpackage