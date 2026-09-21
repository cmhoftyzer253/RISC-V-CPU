import cpu_defines::*;

module csr_addr_decode (
    
    input logic [11:0]  csr_addr_i,
    input logic [2:0]   funct3_i,
    input logic [4:0]   rs1_i,

    input logic [1:0]   priv_level_i,
    input logic [31:0]  mcounteren_i,
    input logic [31:0]  scounteren_i,
    input logic         mstatus_tvm_i,
    input logic         menvcfg_stce_i,

    output logic        csr_addr_valid_o
);

    logic               addr_exists;
    logic               priv_ok;
    logic               ro;
    logic               write;

    logic               cntr_addr;
    logic [4:0]         cntr_bit;
    logic               cntr_ok;

    logic               satp_ok;

    always_comb begin
        case (csr_addr_i)
            SSTATUS_ADDR,
            SIE_ADDR,
            STVEC_ADDR,
            SCOUNTEREN_ADDR,
            SENVCFG_ADDR,
            SSCRATCH_ADDR,
            SEPC_ADDR,
            SCAUSE_ADDR,
            STVAL_ADDR,
            SIP_ADDR,
            SATP_ADDR,
            MSTATUS_ADDR,
            MISA_ADDR,
            MEDELEG_ADDR,
            MIDELEG_ADDR,
            MIE_ADDR,
            MTVEC_ADDR,
            MCOUNTEREN_ADDR,
            MENVCFG_ADDR,
            MCOUNTINHIBIT_ADDR,
            MHPMEVENT3_ADDR,
            MHPMEVENT4_ADDR,
            MHPMEVENT5_ADDR,
            MHPMEVENT6_ADDR,
            MHPMEVENT7_ADDR,
            MHPMEVENT8_ADDR,
            MHPMEVENT9_ADDR,
            MHPMEVENT10_ADDR,
            MHPMEVENT11_ADDR,
            MHPMEVENT12_ADDR,
            MHPMEVENT13_ADDR,
            MHPMEVENT14_ADDR,
            MHPMEVENT15_ADDR,
            MHPMEVENT16_ADDR,
            MHPMEVENT17_ADDR,
            MHPMEVENT18_ADDR,
            MHPMEVENT19_ADDR,
            MHPMEVENT20_ADDR,
            MHPMEVENT21_ADDR,
            MHPMEVENT22_ADDR,
            MHPMEVENT23_ADDR,
            MHPMEVENT24_ADDR,
            MHPMEVENT25_ADDR,
            MHPMEVENT26_ADDR,
            MHPMEVENT27_ADDR,
            MHPMEVENT28_ADDR,
            MHPMEVENT29_ADDR,
            MHPMEVENT30_ADDR,
            MHPMEVENT31_ADDR,
            MSCRATCH_ADDR,
            MEPC_ADDR,
            MCAUSE_ADDR,
            MTVAL_ADDR,
            MIP_ADDR,
            PMPCFG0_ADDR,
            PMPCFG2_ADDR,
            PMPADDR0_ADDR,
            PMPADDR1_ADDR,
            PMPADDR2_ADDR,
            PMPADDR3_ADDR,
            PMPADDR4_ADDR,
            PMPADDR5_ADDR,
            PMPADDR6_ADDR,
            PMPADDR7_ADDR,
            PMPADDR8_ADDR,
            PMPADDR9_ADDR,
            PMPADDR10_ADDR,
            PMPADDR11_ADDR,
            PMPADDR12_ADDR,
            PMPADDR13_ADDR,
            PMPADDR14_ADDR,
            PMPADDR15_ADDR,
            MCYCLE_ADDR,
            MINSTRET_ADDR,
            MHPMCOUNTER3_ADDR,
            MHPMCOUNTER4_ADDR,
            MHPMCOUNTER5_ADDR,
            MHPMCOUNTER6_ADDR,
            MHPMCOUNTER7_ADDR,
            MHPMCOUNTER8_ADDR,
            MHPMCOUNTER9_ADDR,
            MHPMCOUNTER10_ADDR,
            MHPMCOUNTER11_ADDR,
            MHPMCOUNTER12_ADDR,
            MHPMCOUNTER13_ADDR,
            MHPMCOUNTER14_ADDR,
            MHPMCOUNTER15_ADDR,
            MHPMCOUNTER16_ADDR,
            MHPMCOUNTER17_ADDR,
            MHPMCOUNTER18_ADDR,
            MHPMCOUNTER19_ADDR,
            MHPMCOUNTER20_ADDR,
            MHPMCOUNTER21_ADDR,
            MHPMCOUNTER22_ADDR,
            MHPMCOUNTER23_ADDR,
            MHPMCOUNTER24_ADDR,
            MHPMCOUNTER25_ADDR,
            MHPMCOUNTER26_ADDR,
            MHPMCOUNTER27_ADDR,
            MHPMCOUNTER28_ADDR,
            MHPMCOUNTER29_ADDR,
            MHPMCOUNTER30_ADDR,
            MHPMCOUNTER31_ADDR,
            CYCLE_ADDR,
            TIME_ADDR,
            INSTRET_ADDR,
            HPMCOUNTER3_ADDR,
            HPMCOUNTER4_ADDR,
            HPMCOUNTER5_ADDR,
            HPMCOUNTER6_ADDR,
            HPMCOUNTER7_ADDR,
            HPMCOUNTER8_ADDR,
            HPMCOUNTER9_ADDR,
            HPMCOUNTER10_ADDR,
            HPMCOUNTER11_ADDR,
            HPMCOUNTER12_ADDR,
            HPMCOUNTER13_ADDR,
            HPMCOUNTER14_ADDR,
            HPMCOUNTER15_ADDR,
            HPMCOUNTER16_ADDR,
            HPMCOUNTER17_ADDR,
            HPMCOUNTER18_ADDR,
            HPMCOUNTER19_ADDR,
            HPMCOUNTER20_ADDR,
            HPMCOUNTER21_ADDR,
            HPMCOUNTER22_ADDR,
            HPMCOUNTER23_ADDR,
            HPMCOUNTER24_ADDR,
            HPMCOUNTER25_ADDR,
            HPMCOUNTER26_ADDR,
            HPMCOUNTER27_ADDR,
            HPMCOUNTER28_ADDR,
            HPMCOUNTER29_ADDR,
            HPMCOUNTER30_ADDR,
            HPMCOUNTER31_ADDR,
            MVENDORID_ADDR,
            MARCHID_ADDR,
            MIMPID_ADDR,
            MHARTID_ADDR,
            MCONFIGPTR_ADDR: addr_exists    =   1'b1;
            default: addr_exists            =   1'b0;
        endcase

        priv_ok              =  (priv_level_i >= csr_addr_i[9:8]);

        ro                   =  &csr_addr_i[11:10];
        write                =  (funct3_i[1:0] == 2'b01) || |rs1_i;

        cntr_addr            =  (csr_addr_i == CYCLE_ADDR)      || 
                                (csr_addr_i == TIME_ADDR)       || 
                                (csr_addr_i == INSTRET_ADDR);

        cntr_bit             =   csr_addr_i[4:0];

        cntr_ok              =  !cntr_addr || 
                                (priv_level_i == M_MODE) || 
                                (mcounteren_i[cntr_bit] && ((priv_level_i == S_MODE) || scounteren_i[cntr_bit]));

        satp_ok              =   !((csr_addr_i == SATP_ADDR)  && (priv_level_i == S_MODE) && mstatus_tvm_i);

        csr_addr_valid_o     =   addr_exists && priv_ok && !(ro && write) && cntr_ok && satp_ok;
    end

endmodule