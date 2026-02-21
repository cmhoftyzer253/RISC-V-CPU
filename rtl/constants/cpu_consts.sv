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
        J_TYPE      = 7'h6F,
        ZICSR_TYPE  = 7'h73
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
        OP_SLT,
        OP_CSRRW
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

    typedef enum logic {
        ALU_BYPASS  = 1'b0,
        MEM_BYPASS  = 1'b1
    } bypass_avail_t;

    // register file writeback data source
    typedef enum logic[1:0] {
        ALU_SRC = 2'b00,
        MEM_SRC = 2'b01,
        IMM_SRC = 2'b10,
        PC_SRC  = 2'b11
    } rd_src_t;

    typedef enum logic [1:0] {
        RS1_OPERAND_A,
        PC_OPERAND_A,
        CSR_OPERAND_A           
    } alu_opr_a_sel_t;

    typedef enum logic [1:0] {
        RS2_OPERAND_B,
        IMM_OPERAND_B,          //invert for csr_en
        RS1_OPERAND_B           //always invert: only used for csr
    } alu_opr_b_sel_t;

    //  base R type instructions
    // {funct7[5], funct3}
    typedef enum logic [3:0] {
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
    // {1'b0, funct3}
    typedef enum logic [3:0] {
        MUL     = 4'h0,
        MULH    = 4'h1,
        MULHSU  = 4'h2,
        MULHU   = 4'h3,
        DIV     = 4'h4,
        DIVU    = 4'h5,
        REM     = 4'h6,
        REMU    = 4'h7
    } r_type_m_t;

    // I type instructions
    // {opcode[4], funct3}
    typedef enum logic [3:0] {
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
    typedef enum logic [2:0] {
        SB      = 3'h0,
        SH      = 3'h1,
        SW      = 3'h2,
        SD      = 3'h3
    } s_type_t;

    // B type instructions
    typedef enum logic [2:0] {
        BEQ     = 3'h0,
        BNE     = 3'h1,
        BLT     = 3'h4,
        BGE     = 3'h5,
        BLTU    = 3'h6,
        BGEU    = 3'h7
    } b_type_t;

    // U type instructions
    typedef enum logic [6:0] {
        AUIPC   = 7'h17,
        LUI     = 7'h37
    } u_type_t;

    // J type instructions
    typedef enum logic [5:0] {
        JAL     = 6'h3
    } j_type_t;

    // Zicsr type instructions
    typedef enum logic [2:0] {
        CSRRW   = 3'h1,
        CSRRS   = 3'h2,
        CSRRC   = 3'h3,
        CSRRWI  = 3'h5,
        CSRRSI  = 3'h6,
        CSRRCI  = 3'h7
    } zicsr_type_t;

    // control signals
    typedef struct packed {
        logic               pc_sel;
        alu_opr_a_sel_t     opa_sel;
        alu_opr_b_sel_t     opb_sel;
        logic [3:0]         exu_func_sel;
        rd_src_t            rd_src;
        logic               csr_en;
        logic               data_req;
        mem_access_size_t   data_byte;
        bypass_avail_t      bypass_avail;
        logic               data_wr;
        logic               zero_extnd;
        logic               rf_wr_en;
        logic               word_op;
        logic               alu_instr;
        logic               mul_instr;
        logic               div_instr;
    } control_t;

    typedef enum logic [2:0] {
        NONE            = 3'b000,
        ZERO_DIVISOR    = 3'b001,
        OVERFLOW        = 3'b010,
        ZERO_DIVIDEND   = 3'b011,
        SHORT_DIV       = 3'b100
    } div_status_t;

    typedef logic [1:0] bp_cnt_t;

    typedef enum logic [1:0] {
        BRANCH  = 2'b00,
        CALL    = 2'b01,
        RETURN  = 2'b10,
        JUMP    = 2'b11
    } btb_type_t;

    typedef struct packed {
        logic [50:0]    tag;
        logic [61:0]    target;
        btb_type_t      btb_type;
    } btb_entry_t;

    typedef enum logic [1:0] {
        S_FETCH_RUN,
        S_BROM_HOLD,
        S_FETCH_EXC_HOLD
    } fetch_state_t;

    typedef struct packed {
        logic           valid;
        logic [50:0]    tag;
    } i_cache_tag_t;

    typedef enum logic [2:0] {
        S_IC_RUN,          
        S_IC_LOAD_REQUEST,
        S_IC_LOAD_WAIT,
        S_IC_LOAD_1,
        S_IC_LOAD_2,
        S_IC_LOAD_3,
        S_IC_LOAD_DONE
    } i_cache_state_t;

    typedef enum logic {
        S_MEM_RUN,
        S_MEM_EXC_HOLD
    } memory_state_t;

    typedef struct packed {
        logic           valid;
        logic           dirty;
        logic [50:0]    tag;
    } d_cache_tag_t;

    typedef enum logic [3:0] {
        S_DC_RUN,
        S_DC_STORE_AW_WAIT,
        S_DC_STORE_1,
        S_DC_STORE_2,
        S_DC_STORE_3,
        S_DC_STORE_4,
        S_DC_STORE_DONE,
        S_DC_LOAD_REQUEST,
        S_DC_LOAD_1,
        S_DC_LOAD_2,
        S_DC_LOAD_3,
        S_DC_LOAD_4,
        S_DC_LOAD_DONE
    } d_cache_state_t;

    //multiplier states
    typedef enum logic [2:0] {
        S_MUL_IDLE,          
        S_MUL_RUN_1,
        S_MUL_RUN_2,
        S_MUL_RUN_3,
        S_MUL_RUN_4           
    } mul_state_t;

    //divide states
    typedef enum logic [1:0] {
        S_DIV_IDLE,
        S_DIV_RUN,
        S_DIV_OUT_SC,
        S_DIV_OUT_CC
    } div_state_t;

endpackage