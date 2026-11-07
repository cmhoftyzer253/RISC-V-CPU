module csr 
    import cpu_defines::*;
    import cpu_utils::*;
(
    input logic                 clk,
    input logic                 resetn,

    //csr rw interface
    input logic                 csr_wr_en_i,
    input logic [11:0]          csr_addr_i,
    input logic [63:0]          csr_wr_data_i,
    input logic [1:0]           csr_op_i,
    output logic [63:0]         csr_data_o,

    //trap control interface
    input logic                 trap_en_i,
    //[5]: 1'b1 - interrupt, 1'b0 - exception
    //[4:0] interrupt/exception code
    input logic                 trap_delegate_i,
    input logic [5:0]           trap_cause_i,
    input logic [63:0]          trap_xepc_i,
    input logic [63:0]          trap_xtval_i,

    input logic                 int_delegate_i,
    input logic [4:0]           int_cause_i,

    input logic                 mret_i,
    input logic                 sret_i,

    output logic                mstatus_mie_o,
    output logic                mstatus_sie_o,
    output logic [11:0]         mip_o,
    output logic [11:0]         mie_o,
    output logic [11:0]         mideleg_o,
    output logic [15:0]         medeleg_o,

    output logic [63:0]         trap_pc_o,
    output logic [63:0]         mepc_o,
    output logic [63:0]         sepc_o,

    //clint interface 
    input logic [63:0]          mtime_i,
    input logic                 mtip_i,
    input logic                 msip_i,

    //plic interface
    input logic                 meip_i,
    input logic                 seip_i,

    //pipeline module interface
    input logic                 retire_i,

    //export csr interface
    output logic [1:0]          priv_level_o,
    output logic [31:0]         scounteren_o,
    output logic [31:0]         mcounteren_o,
    output logic                mstatus_ube_o,
    output logic [1:0]          mstatus_mpp_o,
    output logic                mstatus_mprv_o,
    output logic                mstatus_tvm_o,
    output logic                mstatus_tw_o,
    output logic                mstatus_tsr_o,
    output logic                mstatus_sbe_o,
    output logic                mstatus_mbe_o,

    output logic [63:0]         pmpcfg0_o,
    output logic [63:0]         pmpcfg2_o,

    output logic [15:0][53:0]   pmpaddr_o,
    output logic [15:0][53:0]   pmpaddr_napot_mask_o
);

    logic [63:0]                csr_wr_data;

    logic                       s_mode_int_vectored;
    logic                       m_mode_int_vectored;

    logic [63:0]                interrupt_pc;
    logic [63:0]                exception_pc;

    logic                       write_mcycle;
    logic                       write_minstret;

    logic [63:0]                mstatus_wr_legal;
    
    logic [7:0]                 pmpcfg_raw;
    logic [63:0]                pmpcfg_wr_legal;

    logic [7:0][53:0]          pmpaddr_wr_data;
    
    logic                       MIP_MEIP;
    logic                       MIP_SEIP;
    logic                       MIP_MTIP;
    logic                       MIP_STIP;
    logic                       MIP_MSIP;
    logic                       MIP_SSIP;

    logic [11:0]                MIP_RD;

    logic [63:0]                PMPCFG0_WMASK;
    logic [7:0][53:0]           PMPADDR_WMASK;

    logic [1:0]                 priv_level;

    logic [63:0]                STVEC_REG;
    logic [31:0]                SCOUNTEREN_REG;
    logic                       SENVCFG_REG;
    logic [63:0]                SSCRATCH_REG;
    logic [63:0]                SEPC_REG;
    logic [63:0]                SCAUSE_REG;
    logic [63:0]                STVAL_REG;

    logic [63:0]                MSTATUS_REG;
    logic [15:0]                MEDELEG_REG;
    logic [11:0]                MIDELEG_REG;
    logic [11:0]                MIE_REG;
    logic [11:0]                MIP_REG;
    logic [63:0]                MTVEC_REG;
    logic [31:0]                MCOUNTEREN_REG;
    logic [63:0]                MENVCFG_REG;
    logic [31:0]                MCOUNTINHIBIT_REG;
    logic [63:0]                MSCRATCH_REG;
    logic [63:0]                MEPC_REG;
    logic [63:0]                MCAUSE_REG;
    logic [63:0]                MTVAL_REG;

    logic [7:0][7:0]           PMPCFG_REG;
    logic [7:0][53:0]          PMPADDR_REG;

    logic [7:0][53:0]          PMPADDR_NAPOT_MASK;

    logic [63:0]                MCYCLE_REG;
    logic [63:0]                MINSTRET_REG;

    always_ff @(posedge clk) begin
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
            PMPADDR_REG         <=  '0;
            PMPADDR_NAPOT_MASK  <=  '{default: 54'h1};
        end else begin
            if (trap_en_i) begin
                if (trap_delegate_i) begin
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
            if (mret_i) begin
                MSTATUS_REG[3]          <=  MSTATUS_REG[7];
                MSTATUS_REG[7]          <=  1'b1;
                MSTATUS_REG[12:11]      <=  2'b00;
                priv_level              <=  MSTATUS_REG[12:11];
            end
            if (sret_i) begin
                MSTATUS_REG[1]          <=  MSTATUS_REG[5];
                MSTATUS_REG[5]          <=  1'b1;
                MSTATUS_REG[8]          <=  1'b0;
                priv_level              <=  MSTATUS_REG[8] ? S_MODE : U_MODE;
            end
            if (csr_wr_en_i) begin
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
                    PMPADDR0_ADDR: begin
                        PMPADDR_REG[0]                      <=  pmpaddr_wr_data[0];
                        PMPADDR_NAPOT_MASK[0]               <=  napot_mask(pmpaddr_wr_data[0]);
                    end
                    PMPADDR1_ADDR: begin
                        PMPADDR_REG[1]                      <=  pmpaddr_wr_data[1];
                        PMPADDR_NAPOT_MASK[1]               <=  napot_mask(pmpaddr_wr_data[1]);
                    end
                    PMPADDR2_ADDR: begin
                        PMPADDR_REG[2]                      <=  pmpaddr_wr_data[2];
                        PMPADDR_NAPOT_MASK[2]               <=  napot_mask(pmpaddr_wr_data[2]);
                    end
                    PMPADDR3_ADDR: begin
                        PMPADDR_REG[3]                      <=  pmpaddr_wr_data[3];
                        PMPADDR_NAPOT_MASK[3]               <=  napot_mask(pmpaddr_wr_data[3]);
                    end
                    PMPADDR4_ADDR: begin
                        PMPADDR_REG[4]                      <=  pmpaddr_wr_data[4];
                        PMPADDR_NAPOT_MASK[4]               <=  napot_mask(pmpaddr_wr_data[4]);
                    end
                    PMPADDR5_ADDR: begin
                        PMPADDR_REG[5]                      <=  pmpaddr_wr_data[5];
                        PMPADDR_NAPOT_MASK[5]               <=  napot_mask(pmpaddr_wr_data[5]);
                    end
                    PMPADDR6_ADDR: begin
                        PMPADDR_REG[6]                      <=  pmpaddr_wr_data[6];
                        PMPADDR_NAPOT_MASK[6]               <=  napot_mask(pmpaddr_wr_data[6]);
                    end
                    PMPADDR7_ADDR: begin
                        PMPADDR_REG[7]                      <=  pmpaddr_wr_data[7];
                        PMPADDR_NAPOT_MASK[7]               <=  napot_mask(pmpaddr_wr_data[7]);
                    end
                    MCYCLE_ADDR: MCYCLE_REG                 <=  csr_wr_data;
                    MINSTRET_ADDR: MINSTRET_REG             <=  csr_wr_data;
                endcase
            end

            if (!write_mcycle && !MCOUNTINHIBIT_REG[0])
                MCYCLE_REG      <=  MCYCLE_REG + 64'd1;

            if (!write_minstret && !MCOUNTINHIBIT_REG[2])
                MINSTRET_REG    <=  MINSTRET_REG + 64'(retire_i);
        end
    end

    always_comb begin
        MIP_MEIP                =   meip_i;
        MIP_SEIP                =   seip_i || MIP_REG[9];
        MIP_MTIP                =   mtip_i;
        MIP_STIP                =   MIP_REG[5];
        MIP_MSIP                =   msip_i;
        MIP_SSIP                =   MIP_REG[1];
        MIP_RD                  =   {MIP_MEIP, 1'b0, MIP_SEIP, 1'b0, MIP_MTIP, 1'b0, MIP_STIP, 1'b0, MIP_MSIP, 1'b0, MIP_SSIP, 1'b0};
        
        mstatus_mie_o           =   MSTATUS_REG[3];
        mstatus_sie_o           =   MSTATUS_REG[1];
        mip_o                   =   MIP_RD;
        mie_o                   =   MIE_REG;
        mideleg_o               =   MIDELEG_REG;
        medeleg_o               =   MEDELEG_REG;

        priv_level_o            =   priv_level;

        mcounteren_o            =   MCOUNTEREN_REG;
        scounteren_o            =   SCOUNTEREN_REG; 

        mstatus_tsr_o           =   MSTATUS_REG[22];
        mstatus_tw_o            =   MSTATUS_REG[21];
        mstatus_tvm_o           =   MSTATUS_REG[20];
        mstatus_mpp_o           =   MSTATUS_REG[12:11];
        mstatus_mprv_o          =   MSTATUS_REG[17];
        mstatus_mbe_o           =   MSTATUS_REG[37];
        mstatus_sbe_o           =   MSTATUS_REG[36];
        mstatus_ube_o           =   MSTATUS_REG[6];

        pmpcfg0_o               =   PMPCFG_REG[7:0];
        pmpcfg2_o               =   64'h0;

        pmpaddr_o               =   {{8{54'h0}}, PMPADDR_REG};
        pmpaddr_napot_mask_o    =   {{8{54'h0}}, PMPADDR_NAPOT_MASK};

        s_mode_int_vectored     =   (STVEC_REG[1:0] == 2'b01);
        m_mode_int_vectored     =   (MTVEC_REG[1:0] == 2'b01);

        interrupt_pc            =   int_delegate_i ? 
                                    ({STVEC_REG[63:2], 2'b00} + (s_mode_int_vectored ? ({57'h0, int_cause_i[4:0], 2'b00}) : 64'h0)) : 
                                    ({MTVEC_REG[63:2], 2'b00} + (m_mode_int_vectored ? ({57'h0, int_cause_i[4:0], 2'b00}) : 64'h0));

        exception_pc            =   trap_delegate_i ? {STVEC_REG[63:2], 2'b00} : {MTVEC_REG[63:2], 2'b00};

        trap_pc_o               =   trap_cause_i[5] ? interrupt_pc : exception_pc;

        mepc_o                  =   MEPC_REG;
        sepc_o                  =   SEPC_REG;

        write_mcycle            =   csr_wr_en_i && (csr_addr_i == MCYCLE_ADDR);
        write_minstret          =   csr_wr_en_i && (csr_addr_i == MINSTRET_ADDR);

        for (int i=0; i<8; i++) begin
            PMPCFG0_WMASK[i*8 +: 8] = pmpcfg_wmask(PMPCFG_REG[i]);
        end

        for (int i=0; i<8; i++) begin
            PMPADDR_WMASK[i] = pmpaddr_wmask(PMPCFG_REG[i], (i<7 ? PMPCFG_REG[i+1] : 8'b0));
        end

        case (csr_addr_i)
            SSTATUS_ADDR: csr_data_o        =   MSTATUS_REG & SSTATUS_RDMASK;
            SIE_ADDR: csr_data_o            =   {52'h0, MIE_REG & MIDELEG_REG};
            STVEC_ADDR: csr_data_o          =   STVEC_REG;
            SCOUNTEREN_ADDR: csr_data_o     =   {32'h0, SCOUNTEREN_REG};
            SENVCFG_ADDR: csr_data_o        =   {63'h0, SENVCFG_REG};
            SSCRATCH_ADDR: csr_data_o       =   SSCRATCH_REG;
            SEPC_ADDR: csr_data_o           =   SEPC_REG;
            SCAUSE_ADDR: csr_data_o         =   SCAUSE_REG;
            STVAL_ADDR: csr_data_o          =   STVAL_REG;
            SIP_ADDR: csr_data_o            =   {52'h0, MIP_RD & MIDELEG_REG};
            MSTATUS_ADDR: csr_data_o        =   MSTATUS_REG;
            MISA_ADDR: csr_data_o           =   MISA_RO;
            MEDELEG_ADDR: csr_data_o        =   {48'h0, MEDELEG_REG};
            MIDELEG_ADDR: csr_data_o        =   {52'h0, MIDELEG_REG};
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
            PMPADDR0_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[0]};
            PMPADDR1_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[1]};
            PMPADDR2_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[2]};
            PMPADDR3_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[3]};
            PMPADDR4_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[4]};
            PMPADDR5_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[5]};
            PMPADDR6_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[6]};
            PMPADDR7_ADDR: csr_data_o       =   {10'h0, PMPADDR_REG[7]};
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

        for (int i=0; i<8; i++) begin
            pmpaddr_wr_data[i] = (csr_wr_data[53:0] & PMPADDR_WMASK[i]) | (PMPADDR_REG[i] & ~PMPADDR_WMASK[i]);
        end  

        mstatus_wr_legal    =   {csr_wr_data[63:13], mpp_wr_legal(csr_wr_data[12:11]), csr_wr_data[10:0]};

        for (int i=0; i<8; i++) begin
            pmpcfg_raw                  =   csr_wr_data[i*8 +: 8];
            pmpcfg_wr_legal[i*8 +: 8]   =   {pmpcfg_raw[7:2], pmpcfg_rw_legal(pmpcfg_raw[1:0])};
        end
    end

endmodule