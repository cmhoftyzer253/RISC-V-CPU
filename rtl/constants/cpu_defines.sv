package cpu_defines;

    localparam logic [63:0] RESET_PC                =   64'h0000_0000_1000_0000;

    `include "cpu_axi_defines.svh"
    `include "cpu_csr_defines.svh"

    //exception codes
    localparam logic [4:0] I_ADDR_MISALIGNED        =   5'd0;
    localparam logic [4:0] I_ACC_FAULT              =   5'd1;
    localparam logic [4:0] ILLEGAL_INSTR            =   5'd2;
    localparam logic [4:0] EBREAK_EXC               =   5'd3;
    localparam logic [4:0] L_ADDR_MISALIGNED        =   5'd4;
    localparam logic [4:0] L_ACC_FAULT              =   5'd5;
    localparam logic [4:0] S_AMO_ADDR_MISALIGNED    =   5'd6;
    localparam logic [4:0] S_AMO_ACC_FAULT          =   5'd7;
    localparam logic [4:0] ECALL_UMODE              =   5'd8;
    localparam logic [4:0] ECALL_SMODE              =   5'd9;
    localparam logic [4:0] ECALL_MMODE              =   5'd11;
    
    //privilege modes
    localparam logic [1:0] U_MODE                   =   2'b00;
    localparam logic [1:0] S_MODE                   =   2'b01;
    localparam logic [1:0] M_MODE                   =   2'b11;

    //PMA constants
    localparam logic [63:0] BROM_ADDR_BASE          =   64'h0000_0000_0001_0000;
    localparam logic [63:0] BROM_PMA_ADDR_MASK      =   64'h0000_0000_0000_7FFF;

    localparam logic [63:0] CLINT_ADDR_BASE         =   64'h0000_0000_0200_0000;
    localparam logic [63:0] CLINT_PMA_ADDR_MASK     =   64'h0000_0000_0000_FFFF;

    localparam logic [63:0] PLIC_ADDR_BASE          =   64'h0000_0000_0C00_0000;
    localparam logic [63:0] PLIC_PMA_ADDR_MASK      =   64'h0000_0000_03FF_FFFF;

    localparam logic [63:0] UART_ADDR_BASE          =   64'h0000_0000_1001_0000;
    localparam logic [63:0] UART_PMA_ADDR_MASK      =   64'h0000_0000_0000_0FFF;

    localparam logic [63:0] QSPI_ADDR_BASE          =   64'h0000_0000_1004_0000;
    localparam logic [63:0] QSPI_PMA_ADDR_MASK      =   64'h0000_0000_0000_0FFF;

    localparam logic [63:0] GPIO_ADDR_BASE          =   64'h0000_0000_1006_0000;
    localparam logic [63:0] GPIO_PMA_ADDR_MASK      =   64'h0000_0000_0000_0FFF;

    localparam logic [63:0] DRAM_ADDR_LOW           =   64'h0000_0000_8000_0000;
    localparam logic [63:0] DRAM_PMA_ADDR_MASK      =   64'h0000_0000_1FFF_FFFF;

    //opcodes
    localparam logic [6:0] R_TYPE_0                 =   7'h33;
    localparam logic [6:0] R_TYPE_1                 =   7'h3B;
    localparam logic [6:0] I_TYPE_0                 =   7'h03;
    localparam logic [6:0] I_TYPE_1                 =   7'h13;
    localparam logic [6:0] I_TYPE_2                 =   7'h67;
    localparam logic [6:0] I_TYPE_3                 =   7'h1B;
    localparam logic [6:0] S_TYPE                   =   7'h23;
    localparam logic [6:0] U_TYPE_0                 =   7'h37;
    localparam logic [6:0] U_TYPE_1                 =   7'h17;
    localparam logic [6:0] J_TYPE                   =   7'h6F;
    localparam logic [6:0] FENCE                    =   7'h0F;
    localparam logic [6:0] PRIVILEGED               =   7'h73;
    localparam logic [6:0] A_TYPE                   =   7'h2F;

    localparam logic [6:0] LUI                      =   7'h37;
    localparam logic [6:0] AUIPC                    =   7'h17;

    //pc sources
    localparam logic [2:0] PC_INCR                  =   3'b000;
    localparam logic [2:0] ALU_RES                  =   3'b001;
    localparam logic [2:0] BRANCH                   =   3'b010;
    localparam logic [2:0] SEPC                     =   3'b011;
    localparam logic [2:0] MEPC                     =   3'b100;

    //operand A sources
    localparam logic [1:0] RS1                      =   2'b00;
    localparam logic [1:0] PC                       =   2'b01;
    localparam logic [1:0] ZERO                     =   2'b10;
    localparam logic [1:0] UIMM                     =   2'b11;

    //operand B sources
    localparam logic RS2                            =   1'b0;
    localparam logic IMM                            =   1'b1;

    //R type ops {funct7[5], funct3}
    localparam logic [3:0] ADD                      =   4'b0000;
    localparam logic [3:0] SUB                      =   4'b1000;
    localparam logic [3:0] SLL                      =   4'b0001;
    localparam logic [3:0] SLT                      =   4'b0010;
    localparam logic [3:0] SLTU                     =   4'b0011;
    localparam logic [3:0] XOR                      =   4'b0100;
    localparam logic [3:0] SRL                      =   4'b0101;
    localparam logic [3:0] SRA                      =   4'b1101;
    localparam logic [3:0] OR                       =   4'b0110;
    localparam logic [3:0] AND                      =   4'b0111;

    //I type ops - funct3
    localparam logic [2:0] ADDI                     =   3'b000;
    localparam logic [2:0] SLLI                     =   3'b001;
    localparam logic [2:0] SLTI                     =   3'b010;
    localparam logic [2:0] SLTIU                    =   3'b011;
    localparam logic [2:0] XORI                     =   3'b100;
    localparam logic [2:0] SRXI                     =   3'b101;
    localparam logic [2:0] ORI                      =   3'b110;
    localparam logic [2:0] ANDI                     =   3'b111;

    //M extension ops {1'b0, funct3}
    localparam logic [3:0] MUL                      =   4'b0000;
    localparam logic [3:0] MULH                     =   4'b0001;
    localparam logic [3:0] MULHSU                   =   4'b0010;
    localparam logic [3:0] MULHU                    =   4'b0011;
    localparam logic [3:0] DIV                      =   4'b0100;
    localparam logic [3:0] DIVU                     =   4'b0101;
    localparam logic [3:0] REM                      =   4'b0110;
    localparam logic [3:0] REMU                     =   4'b0111;

    //branch ops 
    localparam logic [2:0] BEQ                      =   3'b000;
    localparam logic [2:0] BNE                      =   3'b001;
    localparam logic [2:0] BLT                      =   3'b100;
    localparam logic [2:0] BGE                      =   3'b101;
    localparam logic [2:0] BLTU                     =   3'b110;
    localparam logic [2:0] BGEU                     =   3'b111;

    //load ops
    localparam logic [2:0] LB                       =   3'b000;
    localparam logic [2:0] LH                       =   3'b001;
    localparam logic [2:0] LW                       =   3'b010;
    localparam logic [2:0] LD                       =   3'b011;
    localparam logic [2:0] LBU                      =   3'b100;
    localparam logic [2:0] LHU                      =   3'b101;
    localparam logic [2:0] LWU                      =   3'b110;

    //Store ops
    localparam logic [2:0] SB                       =   3'b000;
    localparam logic [2:0] SH                       =   3'b001;
    localparam logic [2:0] SW                       =   3'b010;
    localparam logic [2:0] SD                       =   3'b011;

    //mctrl ops
    localparam logic [1:0] FENCE_I                  =   2'b00;
    localparam logic [1:0] MRET_OP                  =   2'b01;
    localparam logic [1:0] SRET_OP                  =   2'b10;
    localparam logic [1:0] WFI_OP                   =   2'b11;

    //CSR funct3 instructions
    localparam logic [2:0] CSRRW                    =   3'b001;
    localparam logic [2:0] CSRRS                    =   3'b010;
    localparam logic [2:0] CSRRC                    =   3'b011;
    localparam logic [2:0] CSRRWI                   =   3'b101;
    localparam logic [2:0] CSRRSI                   =   3'b110;
    localparam logic [2:0] CSRRCI                   =   3'b111;

    //CSR ops
    localparam logic [1:0] CSRRW_OP                 =   2'b01;
    localparam logic [1:0] CSRRS_OP                 =   2'b10;
    localparam logic [1:0] CSRRC_OP                 =   2'b11;

    //privileged ops
    localparam logic [11:0] ECALL                   =   12'h000;
    localparam logic [11:0] EBREAK                  =   12'h001;
    localparam logic [11:0] SRET                    =   12'h102;
    localparam logic [11:0] WFI                     =   12'h105;
    localparam logic [11:0] MRET                    =   12'h302;

    //lsu access types
    localparam logic [1:0] LSU_LOAD                 =   2'b00;
    localparam logic [1:0] LSU_STORE                =   2'b01;
    localparam logic [1:0] LSU_ATOMIC               =   2'b10;

    localparam logic DC_LOAD                        =   1'b0;
    localparam logic DC_STORE                       =   1'b1;

    //lsu access sizes
    localparam logic [1:0] BYTE                     =   2'b00;
    localparam logic [1:0] HALF_WORD                =   2'b01;
    localparam logic [1:0] WORD                     =   2'b10;
    localparam logic [1:0] DOUBLE_WORD              =   2'b11;

    //atomic operations
    localparam logic [4:0] LR                       =   5'b00010;
    localparam logic [4:0] SC                       =   5'b00011;
    localparam logic [4:0] AMOSWAP                  =   5'b00001;
    localparam logic [4:0] AMOADD                   =   5'b00000;
    localparam logic [4:0] AMOXOR                   =   5'b00100;
    localparam logic [4:0] AMOAND                   =   5'b01100;
    localparam logic [4:0] AMOOR                    =   5'b01000;
    localparam logic [4:0] AMOMIN                   =   5'b10000;
    localparam logic [4:0] AMOMAX                   =   5'b10100;
    localparam logic [4:0] AMOMINU                  =   5'b11000;
    localparam logic [4:0] AMOMAXU                  =   5'b11100;

    //register file sources
    localparam logic [2:0] RF_ALU_SRC               =   3'b000;
    localparam logic [2:0] RF_LSU_SRC               =   3'b001;
    localparam logic [2:0] RF_PC_INCR_SRC           =   3'b010;
    localparam logic [2:0] RF_MDU_SRC               =   3'b011;
    localparam logic [2:0] RF_CSR_SRC               =   3'b100;

    //pmpcfg adress types    
    localparam logic [1:0] OFF                      =   2'b00;
    localparam logic [1:0] TOR                      =   2'b01;
    localparam logic [1:0] NA4                      =   2'b10;
    localparam logic [1:0] NAPOT                    =   2'b11;

    //arbitrate unit grant
    localparam logic [1:0] GRANT_IDLE               =   2'b00;
    localparam logic [1:0] GRANT_LSU                =   2'b01;
    localparam logic [1:0] GRANT_IFU                =   2'b10;

    //clint addresses
    localparam logic [15:0] MSIP_OFFSET             =   16'h0000;
    localparam logic [15:0] MTIMECMP_OFFSET         =   16'h4000;
    localparam logic [15:0] MTIME_OFFSET            =   16'hBFF8;

    //plic addresses 
    localparam logic [25:0] UART_PRIORITY_OFFSET    =   26'h000_0004;
    localparam logic [25:0] SPI_PRIORITY_OFFSET     =   26'h000_0008;
    localparam logic [25:0] GPIO_PRIORITY_OFFSET    =   26'h000_000C;
    localparam logic [25:0] PENDING_OFFSET          =   26'h000_1000;
    localparam logic [25:0] M_ENABLE_OFFSET         =   26'h000_2000;
    localparam logic [25:0] S_ENABLE_OFFSET         =   26'h000_2080;
    localparam logic [25:0] M_THRESHOLD_OFFSET      =   26'h020_0000;
    localparam logic [25:0] M_CLAIM_COMPLETE_OFFSET =   26'h020_0004;
    localparam logic [25:0] S_THRESHOLD_OFFSET      =   26'h020_1000;
    localparam logic [25:0] S_CLAIM_COMPLETE_OFFSET =   26'h020_1004;

    //gpio addresses
    localparam logic [11:0] INPUT_VAL_OFFSET        =   12'h000;
    localparam logic [11:0] INPUT_EN_OFFSET         =   12'h004;
    localparam logic [11:0] OUTPUT_EN_OFFSET        =   12'h008;
    localparam logic [11:0] OUTPUT_VAL_OFFSET       =   12'h00C;
    localparam logic [11:0] RISE_IE_OFFSET          =   12'h018;
    localparam logic [11:0] RISE_IP_OFFSET          =   12'h01C;
    localparam logic [11:0] FALL_IE_OFFSET          =   12'h020;
    localparam logic [11:0] FALL_IP_OFFSET          =   12'h024;
    localparam logic [11:0] HIGH_IE_OFFSET          =   12'h028;
    localparam logic [11:0] HIGH_IP_OFFSET          =   12'h02C;
    localparam logic [11:0] LOW_IE_OFFSET           =   12'h030;
    localparam logic [11:0] LOW_IP_OFFSET           =   12'h034;
    localparam logic [11:0] IOF_EN_OFFSET           =   12'h038;
    localparam logic [11:0] IOF_SEL_OFFSET          =   12'h03C;
    localparam logic [11:0] OUT_XOR_OFFSET          =   12'h040;

    //uart addresses
    //TODO: rename to avoid name collisions
    localparam logic [11:0] TXDATA_OFFSET           =   12'h000;
    localparam logic [11:0] RXDATA_OFFSET           =   12'h004;
    localparam logic [11:0] TXCTRL_OFFSET           =   12'h008;
    localparam logic [11:0] RXCTRL_OFFSET           =   12'h00C;
    localparam logic [11:0] IE_OFFSET               =   12'h010;
    localparam logic [11:0] IP_OFFSET               =   12'h014;
    localparam logic [11:0] DIV_OFFSET              =   12'h018;

    localparam logic [18:0] TXCTRL_WMASK            =   19'h70003;
    localparam logic [18:0] TXCTRL_WMASK            =   19'h70001;

    //spi addresses
    //TODO: rename to avoid collisions
    localparam logic [11:0] SCKDIV_OFFSET           =   12'h000;
    localparam logic [11:0] SCKMODE_OFFSET          =   12'h004;
    localparam logic [11:0] CSID_OFFSET             =   12'h010;
    localparam logic [11:0] CSDEF_OFFSET            =   12'h014;
    localparam logic [11:0] CSMODE_OFFSET           =   12'h018;
    localparam logic [11:0] DELAY0_OFFSET           =   12'h028;
    localparam logic [11:0] DELAY1_OFFSET           =   12'h02C;
    localparam logic [11:0] FMT_OFFSET              =   12'h040;
    localparam logic [11:0] TXDATA_OFFSET           =   12'h048;
    localparam logic [11:0] RXDATA_OFFSET           =   12'h04C;
    localparam logic [11:0] TXMARK_OFFSET           =   12'h050;
    localparam logic [11:0] RXMARK_OFFSET           =   12'h054;

    localparam logic [23:0] DELAY0_WMASK            =   24'hFF00FF;
    localparam logic [23:0] DELAY1_WMASK            =   24'hFF00FF;
    localparam logic [19:0] FMT_WMASK               =   20'hF000C;

    //spi modes
    localparam logic [1:0] AUTO                     =   2'b00;
    localparam logic [1:0] HOLD                     =   2'b10;
    localparam logic [1:0] OFF                      =   2'b11;

endpackage : cpu_defines