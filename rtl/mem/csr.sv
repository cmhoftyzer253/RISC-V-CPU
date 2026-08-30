import cpu_defines::*;

module csr (
    input logic             clk,
    input logic             resetn,

    //csr rw interface
    input logic             csr_wr_en_i,
    input logic [11:0]      csr_addr_i,
    input logic [63:0]      csr_wr_data_i,
    input logic [1:0]       csr_op_i,
    output logic [63:0]     csr_data_o,

    //trap control interface
    input logic             trap_en_i,
    //[5]: 1'b1 - interrupt, 1'b0 - exception
    //[4:0] interrupt/exception code
    input logic             trap_delegate_i,
    input logic [5:0]       trap_cause_i,
    input logic [63:0]      trap_xepc_i,
    input logic [63:0]      trap_xtval_i,

    input logic             mret_i,
    input logic             sret_i,

    output logic            mstatus_mie_o,
    output logic            mstatus_sie_o,
    output logic [11:0]     mip_o,
    output logic [11:0]     mie_o,
    output logic [11:0]     mideleg_o,
    output logic [15:0]     medeleg_o,

    output logic [63:0]     trap_pc_o,
    output logic [63:0]     mepc_o,
    output logic [63:0]     sepc_o,

    //clint interface 
    input logic [63:0]      mtime_i,
    input logic             mtip_i,
    input logic             msip_i,

    //plic interface
    input logic             meip_i,
    input logic             seip_i,

    //pipeline module interface
    input logic             flushM_i,
    input logic             retire_i,

    //export csr interface
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

    logic [63:0]        csr_wr_data;

    logic               s_mode_vectored;
    logic               m_mode_vectored;

    logic               write_mcycle;
    logic               write_minstret;

    logic [63:0]        mstatus_wr_legal;
    
    logic [7:0]         pmpcfg_raw;
    logic [63:0]        pmpcfg_wr_legal;
    
    logic               MIP_MEIP;
    logic               MIP_SEIP;
    logic               MIP_MTIP;
    logic               MIP_STIP;
    logic               MIP_MSIP;
    logic               MIP_SSIP;

    logic [11:0]        MIP_RD;

    logic [63:0]        PMPCFG0_WMASK;
    logic [63:0]        PMPCFG2_WMASK;
    logic [15:0][53:0]  PMPADDR_WMASK;

    logic [1:0]         priv_level;

    logic [63:0]        STVEC_REG;
    logic [31:0]        SCOUNTEREN_REG;
    logic               SENVCFG_REG;
    logic [63:0]        SSCRATCH_REG;
    logic [63:0]        SEPC_REG;
    logic [63:0]        SCAUSE_REG;
    logic [63:0]        STVAL_REG;

    logic [63:0]        MSTATUS_REG;
    logic [15:0]        MEDELEG_REG;
    logic [11:0]        MIDELEG_REG;
    logic [11:0]        MIE_REG;
    logic [11:0]        MIP_REG;
    logic [63:0]        MTVEC_REG;
    logic [31:0]        MCOUNTEREN_REG;
    logic [63:0]        MENVCFG_REG;
    logic [31:0]        MCOUNTINHIBIT_REG;
    logic [63:0]        MSCRATCH_REG;
    logic [63:0]        MEPC_REG;
    logic [63:0]        MCAUSE_REG;
    logic [63:0]        MTVAL_REG;

    logic [15:0][7:0]   PMPCFG_REG;
    logic [53:0]        PMPADDR0_REG;
    logic [53:0]        PMPADDR1_REG;
    logic [53:0]        PMPADDR2_REG;
    logic [53:0]        PMPADDR3_REG;
    logic [53:0]        PMPADDR4_REG;
    logic [53:0]        PMPADDR5_REG;
    logic [53:0]        PMPADDR6_REG;
    logic [53:0]        PMPADDR7_REG;
    logic [53:0]        PMPADDR8_REG;
    logic [53:0]        PMPADDR9_REG;
    logic [53:0]        PMPADDR10_REG;
    logic [53:0]        PMPADDR11_REG;
    logic [53:0]        PMPADDR12_REG;
    logic [53:0]        PMPADDR13_REG;
    logic [53:0]        PMPADDR14_REG;
    logic [53:0]        PMPADDR15_REG;

    logic [63:0]        MCYCLE_REG;
    logic [63:0]        MINSTRET_REG;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            priv_level <= M_MODE;

            STVEC_REG           <=  64'h0;
            SCOUNTEREN_REG      <=  32'h0;
            SENVCFG_REG         <=  1'b0;
            SSCRATCH_REG        <=  64'h0;
            SEPC_REG            <=  64'h0;
            SCAUSE_REG          <=  64'h0;
            STVAL_REG           <=  64'h0;

            MSTATUS_REG         <=  MSTATUS_RESET;
            MEDELEG_REG         <=  16'h0;
            MIDELEG_REG         <=  12'h0;
            MIE_REG             <=  12'h0;
            MTVEC_REG           <=  MTVEC_RESET;
            MCOUNTEREN_REG      <=  32'h0;
            MENVCFG_REG         <=  64'h0;
            MCOUNTINHIBIT_REG   <=  32'h0;
            MSCRATCH_REG        <=  64'h0;
            MEPC_REG            <=  64'h0;
            MCAUSE_REG          <=  64'h0;
            MTVAL_REG           <=  64'h0;
            MIP_REG             <=  12'h0;

            PMPCFG_REG          <=  '0;
            PMPADDR0_REG        <=  54'h0;
            PMPADDR1_REG        <=  54'h0;
            PMPADDR2_REG        <=  54'h0;
            PMPADDR3_REG        <=  54'h0;
            PMPADDR4_REG        <=  54'h0;
            PMPADDR5_REG        <=  54'h0;
            PMPADDR6_REG        <=  54'h0;
            PMPADDR7_REG        <=  54'h0;
            PMPADDR8_REG        <=  54'h0;
            PMPADDR9_REG        <=  54'h0;
            PMPADDR10_REG       <=  54'h0;
            PMPADDR11_REG       <=  54'h0;
            PMPADDR12_REG       <=  54'h0;
            PMPADDR13_REG       <=  54'h0;
            PMPADDR14_REG       <=  54'h0;
            PMPADDR15_REG       <=  54'h0;
            MCYCLE_REG          <=  64'h0;
            MINSTRET_REG        <=  64'h0;
        end else begin
            if (trap_en_i) begin
                if (trap_delegate_i) begin
                    //TODO: fix - SSTATUS doesn't exist
                    MSTATUS_REG[1]      <=  1'b0;
                    MSTATUS_REG[5]      <=  MSTATUS_REG[1]; 
                    MSTATUS_REG[8]      <=  priv_level[0];
                    STVAL_REG           <=  trap_xtval_i;
                    SCAUSE_REG          <=  {trap_cause_i[5], 58'h0, trap_cause_i[4:0]};
                    SEPC_REG            <=  trap_xepc_i;
                    priv_level          <=  S_MODE;
                end else begin
                    MSTATUS_REG[3]      <=  1'b0;
                    MSTATUS_REG[7]      <=  MSTATUS_REG[3];
                    MSTATUS_REG[12:11]  <=  priv_level;
                    MTVAL_REG           <=  trap_xtval_i;
                    MCAUSE_REG          <=  {trap_cause_i[5], 58'h0, trap_cause_i[4:0]};
                    MEPC_REG            <=  trap_xepc_i;
                    priv_level          <=  M_MODE;
                end
            end
            if (mret_i && !flushM_i) begin
                MSTATUS_REG[3]          <=  MSTATUS_REG[7];
                MSTATUS_REG[7]          <=  1'b1;
                MSTATUS_REG[12:11]      <=  2'b00;
                priv_level              <=  MSTATUS_REG[12:11];
            end
            if (sret_i && !flushM_i) begin
                MSTATUS_REG[1]          <=  MSTATUS_REG[5];
                MSTATUS_REG[5]          <=  1'b1;
                MSTATUS_REG[8]          <=  1'b0;
                priv_level              <=  MSTATUS_REG[8] ? S_MODE : U_MODE;
            end
            if (csr_wr_en_i && !flushM_i) begin
                case (csr_addr_i)
                    SSTATUS_ADDR: MSTATUS_REG               <=  (csr_wr_data & SSTATUS_WMASK) | (MSTATUS_REG & ~SSTATUS_WMASK);
                    SIE_ADDR: MIE_REG                       <=  (csr_wr_data[11:0] & MIE_WMASK & MIDELEG_REG) | (MIE_REG & ~(MIE_WMASK & MIDELEG_REG));
                    STVEC_ADDR: STVEC_REG                   <=  csr_wr_data & STVEC_WMASK;
                    SCOUNTEREN_ADDR: SCOUNTEREN_REG         <=  csr_wr_data[31:0];
                    SENVCFG_ADDR: SENVCFG_REG               <=  csr_wr_data[0];
                    SSCRATCH_ADDR: SSCRATCH_REG             <=  csr_wr_data;
                    SEPC_ADDR: SEPC_REG                     <=  csr_wr_data & SEPC_WMASK;
                    SCAUSE_ADDR: SCAUSE_REG                 <=  csr_wr_data & SCAUSE_WMASK;
                    STVAL_ADDR: STVAL_REG                   <=  csr_wr_data;
                    SIP_ADDR: MIP_REG                       <=  (csr_wr_data[11:0] & SIP_WMASK & MIDELEG_REG) | (MIP_REG & ~(SIP_WMASK & MIDELEG_REG));
                    MSTATUS_ADDR: MSTATUS_REG               <=  (mstatus_wr_legal & MSTATUS_WMASK) | MSTATUS_HMASK;
                    MEDELEG_ADDR: MEDELEG_REG               <=  csr_wr_data[15:0] & MEDELEG_WMASK;
                    MIDELEG_ADDR: MIDELEG_REG               <=  csr_wr_data[11:0] & MIDELEG_WMASK;
                    MIE_ADDR: MIE_REG                       <=  csr_wr_data[11:0] & MIE_WMASK;
                    MTVEC_ADDR: MTVEC_REG                   <=  csr_wr_data & MTVEC_WMASK;
                    MCOUNTEREN_ADDR: MCOUNTEREN_REG         <=  csr_wr_data[31:0];
                    MENVCFG_ADDR: MENVCFG_REG               <=  csr_wr_data & MENVCFG_WMASK;
                    MCOUNTINHIBIT_ADDR: MCOUNTINHIBIT_REG   <=  csr_wr_data[31:0] & MCOUNTINHIBIT_WMASK;
                    MSCRATCH_ADDR: MSCRATCH_REG             <=  csr_wr_data;
                    MEPC_ADDR: MEPC_REG                     <=  csr_wr_data & MEPC_WMASK;
                    MCAUSE_ADDR: MCAUSE_REG                 <=  csr_wr_data & MCAUSE_WMASK;
                    MTVAL_ADDR: MTVAL_REG                   <=  csr_wr_data;
                    MIP_ADDR: MIP_REG                       <=  csr_wr_data[11:0] & MIP_WMASK;
                    PMPCFG0_ADDR: PMPCFG_REG[7:0]           <=  (pmpcfg_wr_legal & PMPCFG0_WMASK) | (PMPCFG_REG[7:0] & ~PMPCFG0_WMASK);         
                    PMPCFG2_ADDR: PMPCFG_REG[15:8]          <=  (pmpcfg_wr_legal & PMPCFG2_WMASK) | (PMPCFG_REG[15:8] & ~PMPCFG2_WMASK);        
                    PMPADDR0_ADDR: PMPADDR0_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[0])  | (PMPADDR0_REG  & ~PMPADDR_WMASK[0]); 
                    PMPADDR1_ADDR: PMPADDR1_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[1])  | (PMPADDR1_REG  & ~PMPADDR_WMASK[1]);
                    PMPADDR2_ADDR: PMPADDR2_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[2])  | (PMPADDR2_REG  & ~PMPADDR_WMASK[2]);
                    PMPADDR3_ADDR: PMPADDR3_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[3])  | (PMPADDR3_REG  & ~PMPADDR_WMASK[3]);
                    PMPADDR4_ADDR: PMPADDR4_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[4])  | (PMPADDR4_REG  & ~PMPADDR_WMASK[4]);
                    PMPADDR5_ADDR: PMPADDR5_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[5])  | (PMPADDR5_REG  & ~PMPADDR_WMASK[5]);
                    PMPADDR6_ADDR: PMPADDR6_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[6])  | (PMPADDR6_REG  & ~PMPADDR_WMASK[6]);
                    PMPADDR7_ADDR: PMPADDR7_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[7])  | (PMPADDR7_REG  & ~PMPADDR_WMASK[7]);
                    PMPADDR8_ADDR: PMPADDR8_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[8])  | (PMPADDR8_REG  & ~PMPADDR_WMASK[8]);
                    PMPADDR9_ADDR: PMPADDR9_REG             <=  (csr_wr_data[53:0] & PMPADDR_WMASK[9])  | (PMPADDR9_REG  & ~PMPADDR_WMASK[9]);
                    PMPADDR10_ADDR: PMPADDR10_REG           <=  (csr_wr_data[53:0] & PMPADDR_WMASK[10]) | (PMPADDR10_REG & ~PMPADDR_WMASK[10]);
                    PMPADDR11_ADDR: PMPADDR11_REG           <=  (csr_wr_data[53:0] & PMPADDR_WMASK[11]) | (PMPADDR11_REG & ~PMPADDR_WMASK[11]);
                    PMPADDR12_ADDR: PMPADDR12_REG           <=  (csr_wr_data[53:0] & PMPADDR_WMASK[12]) | (PMPADDR12_REG & ~PMPADDR_WMASK[12]);
                    PMPADDR13_ADDR: PMPADDR13_REG           <=  (csr_wr_data[53:0] & PMPADDR_WMASK[13]) | (PMPADDR13_REG & ~PMPADDR_WMASK[13]);
                    PMPADDR14_ADDR: PMPADDR14_REG           <=  (csr_wr_data[53:0] & PMPADDR_WMASK[14]) | (PMPADDR14_REG & ~PMPADDR_WMASK[14]);
                    PMPADDR15_ADDR: PMPADDR15_REG           <=  (csr_wr_data[53:0] & PMPADDR_WMASK[15]) | (PMPADDR15_REG & ~PMPADDR_WMASK[15]);
                    MCYCLE_ADDR: MCYCLE_REG                 <=  csr_wr_data;
                    MINSTRET_ADDR: MINSTRET_REG             <=  csr_wr_data;
                endcase
            end

            if (!write_mcycle && !MCOUNTINHIBIT_REG[0])
                MCYCLE_REG      <=  MCYCLE_REG + 64'd1;

            if (!write_minstret && !MCOUNTINHIBIT_REG[2])
                MINSTRET_REG    <=  MINSTRET_REG + retire_i;
        end
    end

    always_comb begin
        MIP_MEIP = meip_i;
        MIP_SEIP = seip_i || MIP_REG[9];
        MIP_MTIP = mtip_i;
        MIP_STIP = MIP_REG[5];
        MIP_MSIP = msip_i;
        MIP_SSIP = MIP_REG[1];
        MIP_RD = {MIP_MEIP, 1'b0, MIP_SEIP, 1'b0, MIP_MTIP, 1'b0, MIP_STIP, 1'b0, MIP_MSIP, 1'b0, MIP_SSIP, 1'b0};
        
        mstatus_mie_o       =   MSTATUS_REG[3];
        mstatus_sie_o       =   MSTATUS_REG[1];
        mip_o               =   MIP_RD;
        mie_o               =   MIE_REG;
        mideleg_o           =   MIDELEG_REG;
        medeleg_o           =   MEDELEG_REG;

        priv_level_o        =   priv_level;

        mcounteren_o        =   MCOUNTEREN_REG;
        scounteren_o        =   SCOUNTEREN_REG; 

        mstatus_tsr_o       =   MSTATUS_REG[22];
        mstatus_tw_o        =   MSTATUS_REG[21];
        mstatus_tvm_o       =   MSTATUS_REG[20];
        mstatus_mpp_o       =   MSTATUS_REG[12:11];
        mstatus_mbe_o       =   MSTATUS_REG[37];
        mstatus_sbe_o       =   MSTATUS_REG[36];
        mstatus_ube_o       =   MSTATUS_REG[6];
        
        menvcfg_stce_o      =   MENVCFG_REG[63];

        pmpcfg0_o           =   PMPCFG_REG[7:0];
        pmpcfg2_o           =   PMPCFG_REG[15:8];
        pmpaddr0_o          =   PMPADDR0_REG;
        pmpaddr1_o          =   PMPADDR1_REG;
        pmpaddr2_o          =   PMPADDR2_REG;
        pmpaddr3_o          =   PMPADDR3_REG;
        pmpaddr4_o          =   PMPADDR4_REG;
        pmpaddr5_o          =   PMPADDR5_REG;
        pmpaddr6_o          =   PMPADDR6_REG;
        pmpaddr7_o          =   PMPADDR7_REG;
        pmpaddr8_o          =   PMPADDR8_REG;
        pmpaddr9_o          =   PMPADDR9_REG;
        pmpaddr10_o         =   PMPADDR10_REG;
        pmpaddr11_o         =   PMPADDR11_REG;
        pmpaddr12_o         =   PMPADDR12_REG;
        pmpaddr13_o         =   PMPADDR13_REG;
        pmpaddr14_o         =   PMPADDR14_REG;
        pmpaddr15_o         =   PMPADDR15_REG;

        s_mode_vectored     =   trap_cause_i[5] && (STVEC_REG[1:0] == 2'b01);
        m_mode_vectored     =   trap_cause_i[5] && (MTVEC_REG[1:0] == 2'b01);

        trap_pc_o           =   trap_delegate_i ? 
                                ({STVEC_REG[63:2], 2'b00} + (s_mode_vectored ? ({59'h0, trap_cause_i[4:0]} << 2) : 64'h0)) :  
                                ({MTVEC_REG[63:2], 2'b00} + (m_mode_vectored ? ({59'h0, trap_cause_i[4:0]} << 2) : 64'h0));

        mepc_o              =   MEPC_REG;
        sepc_o              =   SEPC_REG;

        write_mcycle        =   csr_wr_en_i && !flushM_i && (csr_addr_i == MCYCLE_ADDR);
        write_minstret      =   csr_wr_en_i && !flushM_i && (csr_addr_i == MINSTRET_ADDR);

        PMPCFG0_WMASK       =   pmpcfg_wmask(PMPCFG_REG[7:0]);
        PMPCFG2_WMASK       =   pmpcfg_wmask(PMPCFG_REG[15:8]);

        for (int i=0; i<16; i++) begin
            PMPADDR_WMASK[i] = pmpaddr_wmask(PMPCFG_REG[i], (i<15 ? PMPCFG_REG[i+1] : 8'b0));
        end

        case (csr_addr_i)
            SSTATUS_ADDR: csr_data_o        =   MSTATUS_REG & SSTATUS_RDMASK;
            SIE_ADDR: csr_data_o            =   MIE_REG & MIDELEG_REG;
            STVEC_ADDR: csr_data_o          =   STVEC_REG;
            SCOUNTEREN_ADDR: csr_data_o     =   SCOUNTEREN_REG;
            SENVCFG_ADDR: csr_data_o        =   {63'h0, SENVCFG_REG};
            SSCRATCH_ADDR: csr_data_o       =   SSCRATCH_REG;
            SEPC_ADDR: csr_data_o           =   SEPC_REG;
            SCAUSE_ADDR: csr_data_o         =   SCAUSE_REG;
            STVAL_ADDR: csr_data_o          =   STVAL_REG;
            SIP_ADDR: csr_data_o            =   {52'h0, MIP_RD & MIDELEG_REG};
            MSTATUS_ADDR: csr_data_o        =   MSTATUS_REG;
            MISA_ADDR: csr_data_o           =   MISA_RO;
            MEDELEG_ADDR: csr_data_o        =   {48'h0, MEDELEG_REG};
            MIDELEG_ADDR: csr_data_o        =   {48'h0, MIDELEG_REG};
            MIE_ADDR: csr_data_o            =   {52'h0, MIE_REG};
            MTVEC_ADDR: csr_data_o          =   MTVEC_REG;
            MCOUNTEREN_ADDR: csr_data_o     =   {32'h0, MCOUNTEREN_REG};
            MENVCFG_ADDR: csr_data_o        =   MENVCFG_REG;
            MCOUNTINHIBIT_ADDR: csr_data_o  =   {32'h0, MCOUNTINHIBIT_REG};
            MSCRATCH_ADDR: csr_data_o       =   MSCRATCH_REG;
            MEPC_ADDR: csr_data_o           =   MEPC_REG;
            MCAUSE_ADDR: csr_data_o         =   MCAUSE_REG;
            MTVAL_ADDR: csr_data_o          =   MTVAL_REG;
            MIP_ADDR: csr_data_o            =   {52'h0, MIP_RD};
            PMPCFG0_ADDR: csr_data_o        =   PMPCFG_REG[7:0];
            PMPCFG2_ADDR: csr_data_o        =   PMPCFG_REG[15:8];
            PMPADDR0_ADDR: csr_data_o       =   {10'h0, PMPADDR0_REG};
            PMPADDR1_ADDR: csr_data_o       =   {10'h0, PMPADDR1_REG};
            PMPADDR2_ADDR: csr_data_o       =   {10'h0, PMPADDR2_REG};
            PMPADDR3_ADDR: csr_data_o       =   {10'h0, PMPADDR3_REG};
            PMPADDR4_ADDR: csr_data_o       =   {10'h0, PMPADDR4_REG};
            PMPADDR5_ADDR: csr_data_o       =   {10'h0, PMPADDR5_REG};
            PMPADDR6_ADDR: csr_data_o       =   {10'h0, PMPADDR6_REG};
            PMPADDR7_ADDR: csr_data_o       =   {10'h0, PMPADDR7_REG};
            PMPADDR8_ADDR: csr_data_o       =   {10'h0, PMPADDR8_REG};
            PMPADDR9_ADDR: csr_data_o       =   {10'h0, PMPADDR9_REG};
            PMPADDR10_ADDR: csr_data_o      =   {10'h0, PMPADDR10_REG};
            PMPADDR11_ADDR: csr_data_o      =   {10'h0, PMPADDR11_REG};
            PMPADDR12_ADDR: csr_data_o      =   {10'h0, PMPADDR12_REG};
            PMPADDR13_ADDR: csr_data_o      =   {10'h0, PMPADDR13_REG};
            PMPADDR14_ADDR: csr_data_o      =   {10'h0, PMPADDR14_REG};
            PMPADDR15_ADDR: csr_data_o      =   {10'h0, PMPADDR15_REG};
            MCYCLE_ADDR: csr_data_o         =   MCYCLE_REG;
            MINSTRET_ADDR: csr_data_o       =   MINSTRET_REG;
            CYCLE_ADDR: csr_data_o          =   MCYCLE_REG;
            TIME_ADDR: csr_data_o           =   mtime_i;
            INSTRET_ADDR: csr_data_o        =   MINSTRET_REG;
            default: csr_data_o             =   64'h0;
        endcase

        case (csr_op_i)
            CSRRW_OP: csr_wr_data   =   csr_wr_data_i;
            CSRRS_OP: csr_wr_data   =   csr_data_o | csr_wr_data_i;
            CSRRC_OP: csr_wr_data   =   csr_data_o & ~csr_wr_data_i;
            default: csr_wr_data    =   64'h0;
        endcase

        mstatus_wr_legal    =   {csr_wr_data[63:13], mpp_wr_legal(csr_wr_data[12:11]), csr_wr_data[10:0]};

        for (int i=0; i<8; i++) begin
            pmpcfg_raw                  =   csr_wr_data[i*8 +: 8];
            pmpcfg_wr_legal[i*8 +: 8]   =   {pmpcfg_raw[7:2], pmpcfg_rw_legal(pmpcfg_raw[1:0])};
        end
    end

endmodule