package cpu_defines;

    localparam BOOT_ROM_ADDR_LOW        =   64'h0000_0000_0001_0000;
    localparam BOOT_ROM_ADDR_HIGH       =   64'h0000_0000_0001_1FFF;

    localparam DRAM_ADDR_LOW            =   64'h0000_0000_8000_0000;
    localparam DRAM_ADDR_HIGH           =   64'h0000_0000_9FFF_FFFF;

    localparam CLINT_ADDR_LOW           =   64'h0000_0000_0200_0000;
    localparam CLINT_ADDR_HIGH          =   64'h0000_0000_0200_FFFF;

    localparam PLIC_ADDR_LOW            =   64'h0000_0000_0C00_0000;
    localparam PLIC_ADDR_HIGH           =   64'h0000_0000_0FFF_FFFF;

    localparam MSIP_ADDR                =   64'h0000_0000_0200_0000;
    localparam MTIMECMP_ADDR            =   64'h0000_0000_0200_4000;
    localparam MTIMECMPH_ADDR           =   64'h0000_0000_0200_4004;
    localparam MTIME_ADDR               =   64'h0000_0000_0200_BFF8;
    localparam MTIMEH_ADDR              =   64'h0000_0000_0200_BFFC;

    localparam PRIORITY_IRQ1_ADDR       =   64'h0000_0000_0C00_0004;
    localparam PRIORITY_IRQ2_ADDR       =   64'h0000_0000_0C00_0008;
    localparam PRIORITY_IRQ3_ADDR       =   64'h0000_0000_0C00_000C;
    localparam PRIORITY_IRQ4_ADDR       =   64'h0000_0000_0C00_0010;
    localparam PRIORITY_IRQ5_ADDR       =   64'h0000_0000_0C00_0014;
    localparam PRIORITY_IRQ6_ADDR       =   64'h0000_0000_0C00_0018;
    localparam PRIORITY_IRQ7_ADDR       =   64'h0000_0000_0C00_001C;
    localparam PRIORITY_IRQ8_ADDR       =   64'h0000_0000_0C00_0020;
    localparam IP_ADDR                  =   64'h0000_0000_0C00_1000;
    localparam ENABLE_IRQ_ADDR          =   64'h0000_0000_0C00_2000;
    localparam PRIORITY_THRESHOLD_ADDR  =   64'h0000_0000_0C20_0000;
    localparam CLAIM_COMPLETE_ADDR      =   64'h0000_0000_0C20_0004;

    localparam MSTATUS_ADDR             =   12'h300;
    localparam MISA_ADDR                =   12'h301;
    localparam MIE_ADDR                 =   12'h304;
    localparam MTVEC_ADDR               =   12'h305;
    localparam MCOUNTINHIBIT_ADDR       =   12'h320;
    localparam MSCRATCH_ADDR            =   12'h340;
    localparam MEPC_ADDR                =   12'h341;
    localparam MCAUSE_ADDR              =   12'h342;
    localparam MTVAL_ADDR               =   12'h343;
    localparam MIP_ADDR                 =   12'h344;
    localparam MCOUNTOVF_ADDR           =   12'h7E8;
    localparam MCYCLE_ADDR              =   12'hB00;
    localparam MINSTRET_ADDR            =   12'hB02;
    localparam CYCLE_ADDR               =   12'hC00;
    localparam TIME_ADDR                =   12'hC01;
    localparam INSTRET_ADDR             =   12'hC02;
    localparam MVENDORID_ADDR           =   12'hF11;
    localparam MARCHID_ADDR             =   12'hF12;
    localparam MIMPID_ADDR              =   12'hF13;
    localparam MHARTID_ADDR             =   12'hF14;
    
    localparam MISA_Q                   =   64'h8000_0000_0000_1100;
    localparam MVENDORID_Q              =   64'h0000_0000_0000_0000;
    localparam MARCHID_Q                =   64'h0000_0000_0000_0000;
    localparam MIMPID_Q                 =   64'h0000_0000_0000_0000;
    localparam MHARTID_Q                =   64'h0000_0000_0000_0000;

endpackage : cpu_defines