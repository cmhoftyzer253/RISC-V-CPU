module xpm_memory_sprom #(
    parameter int MEMORY_SIZE               =   2048,
    parameter string MEMORY_PRIMITIVE       =   "auto",
    parameter int ADDR_WIDTH_A              =   6,
    parameter int READ_DATA_WIDTH_A         =   32,
    parameter int READ_LATENCY_A            =   1,
    parameter string READ_RESET_VALUE_A     =   "0",
    parameter string MEMORY_INIT_FILE       =   "none",
    parameter string MEMORY_INIT_PARAM      =   "0",
    parameter int USE_MEM_INIT              =   1,
    parameter string ECC_MODE               =   "no_ecc",
    parameter string WAKEUP_TIME            =   "disable_sleep",

    parameter int AUTO_SLEEP_TIME           =   0,
    parameter int CASCADE_HEIGHT            =   0,
    parameter string ECC_BIT_RANGE          =   "7:0",
    parameter string ECC_TYPE               =   "none",
    parameter int IGNORE_INIT_SYNTH         =   0,
    parameter string MEMORY_OPTIMIZATION    =   "true",
    parameter int MESSAGE_CONTROL           =   0,
    parameter string RAM_DECOMP             =   "auto",
    parameter string RST_MODE_A             =   "SYNC",
    parameter int SIM_ASSERT_CHK            =   0,
    parameter int USE_MEM_INIT_MMI          =   0
) (
    input logic                             clka,
    input logic                             ena,
    input logic [ADDR_WIDTH_A-1:0]          addra,
    output logic [READ_DATA_WIDTH_A-1:0]    douta,
    input logic                             rsta,
    input logic                             regcea,
    
    input logic                             sleep,
    input logic                             injectsbiterra,
    input logic                             injectdbiterra,
    output logic                            sbiterra,
    output logic                            dbiterra
);
endmodule