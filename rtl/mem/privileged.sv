module privileged (
    input logic             clk,
    input logic             resetn, 
    
    input logic             csr_wr_en_i,
    input logic [11:0]      csr_addr_i,
    input logic [63:0]      csr_wr_data_i,
    input logic [1:0]       csr_op_i,
    output logic [63:0]     csr_data_o,

    input logic             mret_i,
    input logic             sret_i,

    input logic             validM_i,
    input logic             stallW_i,
    input logic             committedM_i,
    input logic             flushM_i,
    input logic             retire_i,

    input logic             exc_validM_i,
    input logic [4:0]       exc_codeM_i,
    input logic [63:0]      pcM_i,
    input logic [63:0]      nxt_pcM_i,
    input logic [63:0]      exc_xtvalM_i,

    output logic            trap_en_o,
    output logic [63:0]     trap_pc_o,
    output logic [63:0]     mepc_o,
    output logic [63:0]     sepc_o,

    input logic [63:0]      mtime_i,
    input logic             mtip_i,
    input logic             msip_i,

    input logic             meip_i,
    input logic             seip_i,

    output logic [1:0]      priv_level_o,
    output logic [31:0]     scounteren_o,
    output logic [31:0]     mcounteren_o,
    output logic            mstatus_ube_o,
    output logic [1:0]      mstatus_mpp_o,
    output logic            mstatus_tvm_o,
    output logic            mstatus_tw_o,
    output logic            mstatus_tsr_o,
    output logic            mstatus_sbe_o,
    output logic            mstatus_mbe_o,
    output logic            menvcfg_stce_o,

    output logic [63:0]     pmpcfg0_o,
    output logic [63:0]     pmpcfg2_o,
    output logic [53:0]     pmpaddr0_o,
    output logic [53:0]     pmpaddr1_o,
    output logic [53:0]     pmpaddr2_o,
    output logic [53:0]     pmpaddr3_o,
    output logic [53:0]     pmpaddr4_o,
    output logic [53:0]     pmpaddr5_o,
    output logic [53:0]     pmpaddr6_o,
    output logic [53:0]     pmpaddr7_o,
    output logic [53:0]     pmpaddr8_o,
    output logic [53:0]     pmpaddr9_o,
    output logic [53:0]     pmpaddr10_o,
    output logic [53:0]     pmpaddr11_o,
    output logic [53:0]     pmpaddr12_o,
    output logic [53:0]     pmpaddr13_o,
    output logic [53:0]     pmpaddr14_o,
    output logic [53:0]     pmpaddr15_o
);

    logic [1:0]             priv_level;

    logic                   trap_en;
    logic                   trap_delegate;
    logic [5:0]             trap_cause;
    logic [63:0]            trap_xepc;
    logic [63:0]            trap_xtval;

    logic [63:0]            trap_pc;
    logic [63:0]            mepc;
    logic [63:0]            sepc;

    logic                   mstatus_mie;
    logic                   mstatus_sie;
    logic [11:0]            mip;
    logic [11:0]            mie;
    logic [11:0]            mideleg;
    logic [11:0]            medeleg;

    csr u_csr (
        .clk                (clk),
        .resetn             (resetn),
        .csr_wr_en_i        (csr_wr_en_i),
        .csr_addr_i         (csr_addr_i),
        .csr_wr_data_i      (csr_wr_data_i),
        .csr_op_i           (csr_op_i),
        .csr_data_o         (csr_data_o),
        .trap_en_i          (trap_en),
        .trap_cause_i       (trap_cause),
        .trap_xepc_i        (trap_xepc),
        .trap_xtval_i       (trap_xtval),
        .trap_delegate_i    (trap_delegate),
        .mstatus_mie_o      (mstatus_mie),
        .mstatus_sie_o      (mstatus_sie),
        .mip_o              (mip),
        .mie_o              (mie),
        .mideleg_o          (mideleg),
        .medeleg_o          (medeleg),
        .trap_pc_o          (trap_pc),
        .mepc_o             (mepc),
        .sepc_o             (sepc),
        .mret_i             (mret_i),
        .sret_i             (sret_i),
        .mtime_i            (mtime_i),
        .mtip_i             (mtip_i),
        .msip_i             (msip_i),
        .flushM_i           (flushM_i),
        .retire_i           (retire_i),
        .priv_level_o       (priv_level),
        .scounteren_o       (scounteren_o),
        .mcounteren_o       (mcounteren_o),
        .mstatus_ube_o      (mstatus_ube_o),
        .mstatus_mpp_o      (mstatus_mpp_o),
        .mstatus_tvm_o      (mstatus_tvm_o),
        .mstatus_tw_o       (mstatus_tw_o),
        .mstatus_tsr_o      (mstatus_tsr_o),
        .mstatus_sbe_o      (mstatus_sbe_o),
        .mstatus_mbe_o      (mstatus_mbe_o),
        .menvcfg_stce_o     (menvcfg_stce_o),
        .pmpcfg0_o          (pmpcfg0_o),
        .pmpcfg2_o          (pmpcfg2_o),
        .pmpaddr0_o         (pmpaddr0_o),
        .pmpaddr1_o         (pmpaddr1_o),
        .pmpaddr2_o         (pmpaddr2_o),
        .pmpaddr3_o         (pmpaddr3_o),
        .pmpaddr4_o         (pmpaddr4_o),
        .pmpaddr5_o         (pmpaddr5_o),
        .pmpaddr6_o         (pmpaddr6_o),
        .pmpaddr7_o         (pmpaddr7_o),
        .pmpaddr8_o         (pmpaddr8_o),
        .pmpaddr9_o         (pmpaddr9_o),
        .pmpaddr10_o        (pmpaddr10_o),
        .pmpaddr11_o        (pmpaddr11_o),
        .pmpaddr12_o        (pmpaddr12_o),
        .pmpaddr13_o        (pmpaddr13_o),
        .pmpaddr14_o        (pmpaddr14_o),
        .pmpaddr15_o        (pmpaddr15_o)
    );

    trap_control u_trap_control (
        .priv_level_i       (priv_level),
        .trap_en_o          (trap_en),
        .trap_delegate_o    (trap_delegate),
        .trap_cause_o       (trap_cause),
        .trap_xepc_o        (trap_xepc),
        .trap_xtval_o       (trap_xtval),
        .mstatus_mie_i      (mstatus_mie),
        .mstatus_sie_i      (mstatus_sie),
        .mip_i              (mip),
        .mie_i              (mie),
        .mideleg_i          (mideleg),
        .medeleg_i          (medeleg),
        .validM_i           (validM_i),
        .stallW_i           (stallW_i),
        .committedM_i       (committedM_i),
        .flushM_i           (flushM_i),
        .exc_validM_i       (exc_validM_i),
        .exc_codeM_i        (exc_codeM_i),
        .pcM_i              (pcM_i),
        .nxt_pcM_i          (nxt_pcM_i),
        .exc_xtvalM_i       (exc_xtvalM_i)    
    );

    assign trap_en_o        =   trap_en;
    assign trap_pc_o        =   trap_pc;
    assign mepc_o           =   mepc;
    assign sepc_o           =   sepc;

    assign priv_level_o     =   priv_level;

endmodule