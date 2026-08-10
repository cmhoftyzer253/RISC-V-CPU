import cpu_defines::*;

module i_pma (
    input logic [63:0]  pc_i,

    output logic        pma_cacheable_o,
    output logic        pma_fault_o
);

    logic brom_sel;
    logic dram_sel;
    logic pma_sel;

    always_comb begin
        brom_sel            =   &((pc_i ~^ BROM_ADDR_BASE) | BROM_PMA_ADDR_MASK);
        dram_sel            =   &((pc_i ~^ DRAM_ADDR_BASE) | DRAM_PMA_ADDR_MASK);
        pma_sel             =   brom_sel || dram_sel;

        pma_cacheable_o     =   pma_sel;
        pma_fault_o         =   !pma_sel;
    end

endmodule