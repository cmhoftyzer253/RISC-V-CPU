package cpu_consts;

    // instruction types
    typedef enum logic[6:0] {
        R_TYPE_0    = 7'h33,
        R_TYPE_1    = 7'h3B,
        I_TYPE_0    = 7'h03,
        I_TYPE_1    = 7'h13,
        I_TYPE_2    = 7'h67,
        I_TYPE_3    = 7'h1B,
        S_TYPE      = 7'h23,
        B_TYPE      = 7'h63,
        U_TYPE_0    = 7'h37,
        U_TYPE_1    = 7'h17,
        J_TYPE      = 7'h6F
    } riscv_op_t;

    // base operations
    typedef enum logic [3:0] {
        OP_ADD,
        OP_SUB,
        OP_SLL,
        OP_SRL,
        OP_SRA,
        OP_OR,
        OP_AND,
        OP_XOR,
        OP_SLTU,
        OP_SLT
    } alu_op_t;

    // M extension operations
    typedef enum logic [3:0] {
        OP_MUL,
        OP_MULH,
        OP_MULHSU,
        OP_MULHU,
        OP_DIV,
        OP_DIVU,
        OP_REM,
        OP_REMU
    } md_op_t;

    //memory access width
    typedef enum logic[1:0] {
        BYTE        = 2'b00,
        HALF_WORD   = 2'b01,
        WORD        = 2'b10,
        DOUBLE_WORD = 2'b11
    } mem_access_size_t;

    //  base R type instructions
    // {funct7[5], funct3}
    typedef enum logic[3:0] {
        ADD     = 4'h0,
        AND     = 4'h7,
        OR      = 4'h6,
        SLL     = 4'h1,
        SLT     = 4'h2,
        SLTU    = 4'h3,
        SRA     = 4'hD,
        SRL     = 4'h5,
        SUB     = 4'h8,
        XOR     = 4'h4
    } r_type_t;

    // M R type instructions
    typedef enum logic[2:0] {
        MUL     = 3'h0;
        MULH    = 3'h1;
        MULHSU  = 3'h2;
        MULHU   = 3'h3;
        DIV     = 3'h4;
        DIVU    = 3'h5;
        REM     = 3'h6;
        REMU    = 3'h7;
    } r_type_m_t;

    // I type instructions
    // {opcode[4], funct3}
    typedef enum logic[3:0] {
        LB      = 4'h0,
        LBU     = 4'h4,
        LH      = 4'h1,
        LHU     = 4'h5,
        LW      = 4'h2,
        LWU     = 4'h6,
        LD      = 4'h3,
        ADDI    = 4'h8,
        ANDI    = 4'hF,
        ORI     = 4'hE,
        SLLI    = 4'h9,
        SRXI    = 4'hD,    //covers SRLI & SRAI
        SLTI    = 4'hA,
        SLTIU   = 4'hB,
        XORI    = 4'hC
    } i_type_t;

    //  S type instructions
    typedef enum logic[2:0] {
        SB = 3'h0,
        SH = 3'h1,
        SW = 3'h2,
        SD = 3'h3
    } s_type_t;

    // B type instructions
    typedef enum logic[2:0] {
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

    // control signals
    typedef struct packed {
        logic               pc_sel;
        logic               op1_sel;
        logic               op2_sel;
        logic [3:0]         exu_func_sel;
        logic [1:0]         rf_wr_data_sel;
        logic               data_req;
        mem_access_size_t   data_byte;
        logic               data_wr;
        logic               zero_extnd;
        logic               rf_wr_en;
        logic               word_op;
        logic               alu_instr;
        logic               mul_instr;
        logic               div_instr;
    } control_t;

    // register file writeback data source
    typedef enum logic[1:0] {
        ALU     = 2'b00,
        MEM     = 2'b01,
        IMM     = 2'b10,
        PC      = 2'b11
    } rf_wr_data_src_t;

    typedef enum logic[2:0] {
        NONE            = 3'b000;
        ZERO_DIVISOR    = 3'b001;
        OVERFLOW        = 3'b010;
        ZERO_DIVIDEND   = 3'b011;
        SHORT_DIV       = 3'b100;
    } div_status_t;

    typedef logic [1:0] bp_cnt_t;

    typedef enum logic[1:0] {
        BRANCH  = 2'b00,
        CALL    = 2'b01,
        RETURN  = 2'b10,
        JUMP    = 2'b11
    } btb_type_t;

    typedef struct packed {
        logic [50:0]    tag;
        logic [61:0]    target;
        btb_type_t      type;
    } btb_entry_t;

    typedef struct packed {
        logic [63:0]    addr;
        logic [7:0]     len;
        logic [2:0]     size;
        logic [1:0]     burst;
    } imem_req_t;

    /*
    typedef struct packed {
        logic [50:0] tag;
        logic [6:0] index;
        logic [5:0] offset;
    } cache_addr_t;
    */

    typedef struct packed {
        logic           valid;
        logic [50:0]    tag;
    } cache_tag_t;

    typdef struct packed {
        logic           error;
        logic           last;
        logic [63:0]    data;
    } fifo_entry_t;

endpackage