import cpu_defines::*;

module d_pma (
    input logic         lsu_valid_i,

    input logic [63:0]  lsu_addr_i,
    input logic [1:0]   lsu_ls_i,
    input logic [1:0]   lsu_size_i,

    output logic        pma_cacheable_o,
    output logic        pma_idempotent_o,
    output logic        pma_fault_o
);
    logic               brom_sel;
    logic               clint_sel;
    logic               plic_sel;
    logic               uart_sel;
    logic               qspi_sel;
    logic               gpio_sel;
    logic               dram_sel;
    logic               brom_valid
    logic               clint_valid;
    logic               plic_valid;
    logic               uart_valid;
    logic               qspi_valid;
    logic               gpio_valid;
    logic               dram_valid;

    always_comb begin
        brom_sel            =   &((lsu_addr_i ~^ BROM_ADDR_BASE)  | BROM_PMA_ADDR_MASK);
        clint_sel           =   &((lsu_addr_i ~^ CLINT_ADDR_BASE) | CLINT_PMA_ADDR_MASK);
        plic_sel            =   &((lsu_addr_i ~^ PLIC_ADDR_BASE)  | PLIC_PMA_ADDR_MASK);
        uart_sel            =   &((lsu_addr_i ~^ UART_ADDR_BASE)  | UART_PMA_ADDR_MASK);
        qspi_sel            =   &((lsu_addr_i ~^ QSPI_ADDR_BASE)  | QSPI_PMA_ADDR_MASK);
        gpio_sel            =   &((lsu_addr_i ~^ GPIO_ADDR_BASE)  | GPIO_PMA_ADDR_MASK);
        dram_sel            =   &((lsu_addr_i ~^ DRAM_ADDR_BASE)  | DRAM_PMA_ADDR_MASK);

        brom_valid          =   brom_sel && (lsu_ls_i == LOAD);
        clint_valid         =   clint_sel && ((lsu_ls_i == LOAD) || (lsu_ls_i == STORE)) && ((lsu_size_i == WORD) || (lsu_size_i == DOUBLE_WORD));
        plic_valid          =   plic_sel && ((lsu_ls_i == LOAD) || (lsu_ls_i == STORE)) && (lsu_size_i == WORD);
        uart_valid          =   uart_sel && ((lsu_ls_i == LOAD) || (lsu_ls_i == STORE)) && (lsu_size_i == BYTE);
        qspi_valid          =   qspi_sel && ((lsu_ls_i == LOAD) || (lsu_ls_i == STORE)) && (lsu_size_i == WORD);
        gpio_valid          =   gpio_sel && ((lsu_ls_i == LOAD) || (lsu_ls_i == STORE)) && (lsu_size_i == WORD);
        dram_valid          =   dram_sel;

        pma_cacheable_o     =   lsu_valid_i && (brom_valid || dram_valid);
        pma_idempotent_o    =   lsu_valid_i && (brom_valid || clint_valid || dram_valid);
        pma_fault_o         =   lsu_valid_i && !(brom_valid || clint_valid || plic_valid || uart_valid || qspi_valid || gpio_valid || dram_valid);
    end

endmodule