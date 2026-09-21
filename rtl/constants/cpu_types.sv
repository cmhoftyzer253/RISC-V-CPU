
package cpu_types;

    typedef enum logic [1:0] {
        IC_RUN,
        IC_REFILL_REQ,
        IC_REFILL,
        IC_REFILL_DONE
    } ic_state_t;

    typedef enum logic [1:0] {
        IFU_IC_RUN,
        IFU_MEM_REQ,
        IFU_MEM_WAIT,
        IFU_MEM_DONE
    } ifu_state_t;

    typedef enum logic [3:0] {
        DC_RUN,
        DC_WRITEBACK_REQ,
        DC_WRITEBACK,
        DC_WRITEBACK_DONE,
        DC_REFILL_REQ,
        DC_REFILL,
        DC_REFILL_DONE,
        DC_CLEAN,
        DC_CLEAN_WRITEBACK_REQ,
        DC_CLEAN_WRITEBACK,
        DC_CLEAN_WRITEBACK_DONE
    } dc_state_t;

    typedef enum logic [2:0] {
        LSU_DC_RUN,
        LSU_MEM_LOAD_REQ,
        LSU_MEM_LOAD,
        LSU_MEM_LOAD_DONE,
        LSU_MEM_STORE_REQ,
        LSU_MEM_STORE,
        LSU_MEM_STORE_DONE,
        LSU_AMO_STORE
    } lsu_state_t;

    typedef enum logic [2:0] {
        M_IDLE,
        M_RUN_1,
        M_RUN_2,
        M_RUN_3,
        M_RUN_4,
    } mul_state_t;

    typedef enum logic [1:0] {
        D_IDLE,
        D_SC_OUT,
        D_RUN
    } div_state_t;

    typedef enum logic [2:0] {
        UART_TX_IDLE,
        UART_TX_START,
        UART_TX_DATA,
        UART_TX_STOP,
        UART_TX_STOP_2
    } uart_tx_state_t;

    typedef enum logic [1:0] {
        UART_RX_IDLE,
        UART_RX_START,
        UART_RX_DATA,
        UART_RX_STOP
    } uart_rx_state_t;

    typedef enum logic [2:0] {
        SPI_IDLE,
        SPI_CSSCK,
        SPI_DATA,
        SPI_SCKCS,
        SPI_INTERCS,
        SPI_INTERXFR,
        SPI_HOLD
    } spi_state_t;

    typedef struct packed {
        logic [2:0]     pc_sel;
        logic [1:0]     opa_sel;
        logic           opb_sel;
        logic           rs1_used;
        logic           rs2_used;
        logic           word_op_sel;
        logic           alu_en;
        logic           md_en;
        logic [3:0]     exu_op;
        logic [2:0]     branch_op;
        logic           csr_wr_en;
        logic [1:0]     csr_op;
        logic           mctrl_en;
        logic [1:0]     mctrl_op;
        logic           lsu_en;
        logic [1:0]     lsu_ls;
        logic [1:0]     lsu_size;
        logic [4:0]     atomic_op;
        logic           lsu_se;
        logic           rf_wr_en;
        logic [2:0]     rf_sel;
    } control_t;
    
endpackage : cpu_types