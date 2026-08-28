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

    logic           addr_exists;
    logic           priv_ok;
    logic           ro;
    logic           write;

    logic           cntr_addr;
    logic [4:0]     cntr_bit;
    logic           cntr_ok;

    logic           satp_ok;

    always_comb begin
        case (csr_addr_i)
            CYCLE_ADDR,
            TIME_ADDR,
            INSTRET_ADDR,
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
            MVENDORID_ADDR,
            MARCHID_ADDR,
            MIMPID_ADDR,
            MHARTID_ADDR,
            MCONFIGPTR_ADDR,
            MSTATUS_ADDR,
            MISA_ADDR,
            MEDELEG_ADDR,
            MIDELEG_ADDR,
            MIE_ADDR,
            MTVEC_ADDR,
            MCOUNTEREN_ADDR,
            MSCRATCH_ADDR,
            MEPC_ADDR,
            MCAUSE_ADDR,
            MTVAL_ADDR,
            MIP_ADDR,
            MENVCFG_ADDR,
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
            MCOUNTINHIBIT_ADDR: addr_exists     =   1'b1;
            default: addr_exists                =   1'b0;
        endcase
    end

    assign priv_ok              =   (priv_level_i >= csr_addr_i[9:8]);

    assign ro                   =   &csr_addr_i[11:10];
    assign write                =   (funct3_i[1:0] == 2'b01) || |rs1_i;

    assign cntr_addr            =   (csr_addr_i == CYCLE_ADDR)  || 
                                    (csr_addr_i == TIME_ADDR)   || 
                                    (csr_addr_i == INSTRET_ADDR);

    assign cntr_bit             =   csr_addr_i[4:0];

    assign cntr_ok              =   !cntr_addr || 
                                    (priv_level_i == M_MODE) || 
                                    (mcounteren_i[cntr_bit] && ((priv_level_i == S_MODE) || scounteren_i[cntr_bit]));

    assign satp_ok              =   !((csr_addr_i == SATP_ADDR)  && (priv_level_i == S_MODE) && mstatus_tvm_i);

    assign csr_addr_valid_o     =   addr_exists && priv_ok && !(ro && write) && cntr_ok && satp_ok;

endmodule