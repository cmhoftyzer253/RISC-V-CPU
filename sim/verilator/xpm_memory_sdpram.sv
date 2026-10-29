/* verilator lint_off UNUSEDPARAM */
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */

module xpm_memory_sdpram #(
    parameter int    MEMORY_SIZE             = 2048,
    parameter string MEMORY_PRIMITIVE        = "auto",
    parameter string CLOCKING_MODE           = "common_clock",
    parameter int    WRITE_DATA_WIDTH_A      = 32,
    parameter int    ADDR_WIDTH_A            = 6,
    parameter int    BYTE_WRITE_WIDTH_A      = 32,
    parameter int    READ_DATA_WIDTH_B       = 32,
    parameter int    ADDR_WIDTH_B            = 6,
    parameter int    READ_LATENCY_B          = 2,
    parameter string READ_RESET_VALUE_B      = "0",
    parameter string WRITE_MODE_B            = "no_change",
    parameter string MEMORY_INIT_FILE        = "none",
    parameter int    USE_MEM_INIT            = 1,
    parameter string ECC_MODE                = "no_ecc",

    parameter int    AUTO_SLEEP_TIME         = 0,
    parameter int    CASCADE_HEIGHT          = 0,
    parameter string MEMORY_INIT_PARAM       = "0",
    parameter string MEMORY_OPTIMIZATION     = "true",
    parameter int    MESSAGE_CONTROL         = 0,
    parameter string RST_MODE_A              = "SYNC",
    parameter string RST_MODE_B              = "SYNC",
    parameter int    SIM_ASSERT_CHK          = 0,
    parameter int    USE_EMBEDDED_CONSTRAINT = 0,
    parameter int    USE_MEM_INIT_MMI        = 0,
    parameter string WAKEUP_TIME             = "disable_sleep",
    parameter string WRITE_PROTECT           = "true"
) (
    input  logic                                             clka,
    input  logic                                             ena,
    input  logic [WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-1:0] wea,
    input  logic [ADDR_WIDTH_A-1:0]                          addra,
    input  logic [WRITE_DATA_WIDTH_A-1:0]                    dina,
 
    input  logic                                             clkb,
    input  logic                                             enb,
    input  logic [ADDR_WIDTH_B-1:0]                          addrb,
    output logic [READ_DATA_WIDTH_B-1:0]                     doutb,
    input  logic                                             rstb,
    input  logic                                             regceb,
 
    input  logic                                             sleep,
    input  logic                                             injectsbiterra,
    input  logic                                             injectdbiterra,
    output logic                                             sbiterrb,
    output logic                                             dbiterrb
);
endmodule
