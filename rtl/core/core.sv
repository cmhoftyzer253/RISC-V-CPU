module core (
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      mtime_i,
    input logic             mtip_i,
    input logic             msip_i,
    input logic             meip_i,
    input logic             seip_i,

    input logic             arready_i,
    output logic [63:0]     araddr_o,
    output logic [7:0]      arlen_o,
    output logic [2:0]      arsize_o,
    output logic [1:0]      arburst_o,
    output logic            arlock_o,
    output logic [3:0]      arid_o,
    output logic [3:0]      arcache_o,
    output logic [2:0]      arprot_o,
    output logic [3:0]      arqos_o,
    output logic            arvalid_o,

    input logic             rvalid_i,
    input logic [63:0]      rdata_i,
    input logic [1:0]       rresp_i,
    input logic             rlast_i,
    input logic [3:0]       rid_i,
    output logic            rready_o,

    input logic             awready_i,
    input logic             wready_i,
    output logic [63:0]     awaddr_o,
    output logic            awvalid_o,
    output logic [2:0]      awsize_o,
    output logic [7:0]      awlen_o,
    output logic [1:0]      awburst_o,
    output logic            awlock_o,
    output logic [3:0]      awid_o,
    output logic [3:0]      awcache_o,
    output logic [2:0]      awprot_o,
    output logic [3:0]      awqos_o,
    output logic [63:0]     wdata_o,
    output logic [7:0]      wstrb_o,
    output logic            wvalid_o,
    output logic            wlast_o,

    input logic [1:0]       bresp_i,
    input logic             bvalid_i,
    input logic [3:0]       bid_i,
    output logic            bready_o
);

    logic                   ifu_ready;

    logic [63:0]            nxt_pcF;
    logic [63:0]            pcF;

    logic [31:0]            instrF;
    logic                   instr_validF;

    logic                   ic_invalidate;
    logic                   ic_invalidate_done;
    
    logic                   exc_validF;
    logic [4:0]             exc_codeF;

    logic [31:0]            instrD;

    logic [4:0]             rs1D;
    logic [4:0]             rs2D;
    logic [4:0]             rdD;

    logic [63:0]            immD;
    logic [11:0]            csr_addrD;

    logic [2:0]             pc_selD;
    logic [1:0]             opa_selD;
    logic                   opb_selD;

    logic                   rs1_usedD;
    logic                   rs2_usedD;

    logic                   word_opD;
    logic                   alu_enD;
    logic                   md_enD;

    logic [3:0]             exu_opD;
    logic [2:0]             branch_opD;

    logic                   csr_wr_enD;
    logic [1:0]             csr_opD;

    logic                   mctrl_enD;
    logic [1:0]             mctrl_opD;

    logic                   lsu_enD;
    logic [1:0]             lsu_lsD;
    logic [1:0]             lsu_sizeD;
    logic [4:0]             atomic_opD;
    logic                   lsu_seD;

    logic                   rf_wr_enD;
    logic [2:0]             rf_selD;

    logic                   exc_validD;
    logic [4:0]             exc_codeD;

    logic [63:0]            rs1_dataD;
    logic [63:0]            rs2_dataD;

    logic [63:0]            opr_aD;
    logic [63:0]            opr_bD;

    logic                   mdu_enD;
    logic [3:0]             mdu_exu_opD;
    logic                   mdu_word_opD;
    logic                   mdu_readyD;

    logic [63:0]            opr_aE;
    logic [63:0]            opr_bE;

    logic                   word_opE;
    logic                   branch_enE;
    logic [3:0]             exu_opE;
    logic [2:0]             branch_opE;

    logic [63:0]            alu_resE;
    logic                   branch_takenE;

    logic                   mdu_res_validE;
    logic [63:0]            mdu_resE;

    logic                   lsu_validE;
    logic [63:0]            lsu_dataE;
    logic [1:0]             lsu_lsE;
    logic [63:0]            lsu_addrE;
    logic [1:0]             lsu_sizeE;
    logic                   lsu_seE;
    logic                   lsu_readyE;
    logic [4:0]             atomic_opE;

    logic                   csr_wr_enM;
    logic [11:0]            csr_addrM;
    logic [63:0]            csr_wr_dataM;
    logic [1:0]             csr_opM;
    logic [63:0]            csr_dataM;

    logic [63:0]            rs2_dataM;

    logic [63:0]            lsu_ldataM;
    logic [63:0]            addrM;

    logic                   mretM;
    logic                   sretM;
    logic                   validM;

    logic                   dc_cleanM;
    logic                   dc_clean_doneM;

    logic                   exc_validM;
    logic [4:0]             exc_codeM;
    
    logic                   exc_valid;
    logic [4:0]             exc_code;
    logic [63:0]            exc_xtvalM;

    logic [63:0]            pcM;
    logic [63:0]            nxt_pcM;

    logic                   trap_en;
    logic [63:0]            trap_pc;
    logic [63:0]            mepc;
    logic [63:0]            sepc;

    logic                   wfi_wakeup;

    logic [1:0]             priv_level;
    
    logic [31:0]            mcounteren;
    logic [31:0]            scounteren;

    logic                   mstatus_ube;
    logic [1:0]             mstatus_mpp;
    logic                   mstatus_mprv;
    logic                   mstatus_tvm;
    logic                   mstatus_tw;
    logic                   mstatus_tsr;
    logic                   mstatus_sbe;
    logic                   mstatus_mbe;

    logic                   menvcfg_stce;

    logic [63:0]            pmpcfg0;
    logic [63:0]            pmpcfg2;

    logic [63:0]            pmpaddr0;
    logic [63:0]            pmpaddr1;
    logic [63:0]            pmpaddr2;
    logic [63:0]            pmpaddr3;
    logic [63:0]            pmpaddr4;
    logic [63:0]            pmpaddr5;
    logic [63:0]            pmpaddr6;
    logic [63:0]            pmpaddr7;
    logic [63:0]            pmpaddr8;
    logic [63:0]            pmpaddr9;
    logic [63:0]            pmpaddr10;
    logic [63:0]            pmpaddr11;
    logic [63:0]            pmpaddr12;
    logic [63:0]            pmpaddr13;
    logic [63:0]            pmpaddr14;
    logic [63:0]            pmpaddr15;

    logic [4:0]             rdW;
    logic                   rf_wr_enW;
    logic [63:0]            rf_wr_dataW;

    logic                   stallD;
    logic                   stallE;
    logic                   stallM;

    logic                   flushF;
    logic                   flushE;

    logic                   retire;

    logic                   ifu_arready;
    logic [63:0]            ifu_araddr;
    logic [7:0]             ifu_arlen;
    logic [2:0]             ifu_arsize;
    logic [1:0]             ifu_arburst;
    logic                   ifu_arlock;
    logic [3:0]             ifu_arid;
    logic [3:0]             ifu_arcache;
    logic [2:0]             ifu_arprot;
    logic [3:0]             ifu_arqos;
    logic                   ifu_arvalid;

    logic                   ifu_rvalid;
    logic [63:0]            ifu_rdata;
    logic [1:0]             ifu_rresp;
    logic                   ifu_rlast;
    logic [3:0]             ifu_rid;
    logic                   ifu_rready;

    logic                   lsu_arready;
    logic [63:0]            lsu_araddr;
    logic [7:0]             lsu_arlen;
    logic [2:0]             lsu_arsize;
    logic [1:0]             lsu_arburst;
    logic                   lsu_arlock;
    logic [3:0]             lsu_arid;
    logic [3:0]             lsu_arcache;
    logic [2:0]             lsu_arprot;
    logic [3:0]             lsu_arqos;
    logic                   lsu_arvalid;

    logic                   lsu_rvalid;
    logic [63:0]            lsu_rdata;
    logic [1:0]             lsu_rresp;
    logic                   lsu_rlast;
    logic [3:0]             lsu_rid;
    logic                   lsu_rready;

    logic                   lsu_awready;
    logic [63:0]            lsu_awaddr;
    logic                   lsu_awvalid;
    logic [2:0]             lsu_awsize;
    logic [7:0]             lsu_awlen;
    logic [1:0]             lsu_awburst;
    logic                   lsu_awlock;
    logic [3:0]             lsu_awid;
    logic [3:0]             lsu_awcache;
    logic [2:0]             lsu_awprot;
    logic [3:0]             lsu_awqos;

    logic                   lsu_wready;
    logic [63:0]            lsu_wdata;
    logic [7:0]             lsu_wstrb;
    logic                   lsu_wvalid;
    logic                   lsu_wlast;

    logic [1:0]             lsu_bresp;
    logic                   lsu_bvalid;
    logic [3:0]             lsu_bid;
    logic                   lsu_bready;

    pipeline u_pipeline (
        .clk                    (clk),
        .resetn                 (resetn),
        .ifu_ready_i            (ifu_ready),
        .nxt_pcF_o              (nxt_pcF),
        .instrF_i               (instrF),
        .instr_validF_i         (instr_validF),
        .ic_invalidateF_o       (ic_invalidate),
        .ic_invalidate_doneF_i  (ic_invalidate_done),
        .pcF_i                  (pcF),
        .exc_validF_i           (exc_validF),
        .exc_codeF_i            (exc_codeF),
        .instrD_o               (instrD),
        .rs1D_i                 (rs1D),
        .rs2D_i                 (rs2D),
        .rdD_i                  (rdD),
        .immD_i                 (immD),
        .csr_addrD_i            (csr_addrD),
        .pc_selD_i              (pc_selD),
        .opa_selD_i             (opa_selD),
        .opb_selD_i             (opb_selD),
        .rs1_usedD_i            (rs1_usedD),
        .rs2_usedD_i            (rs2_usedD),
        .word_opD_i             (word_opD),
        .alu_enD_i              (alu_enD),
        .md_enD_i               (md_enD),
        .exu_opD_i              (exu_opD),
        .branch_opD_i           (branch_opD),
        .csr_wr_enD_i           (csr_wr_enD),
        .csr_opD_i              (csr_opD),
        .mctrl_enD_i            (mctrl_enD),
        .mctrl_opD_i            (mctrl_opD),
        .lsu_enD_i              (lsu_enD),
        .lsu_lsD_i              (lsu_lsD),
        .lsu_sizeD_i            (lsu_sizeD),
        .atomic_opD_i           (atomic_opD),
        .lsu_seD_i              (lsu_seD),
        .rf_wr_enD_i            (rf_wr_enD),
        .rf_selD_i              (rf_selD),
        .exc_validD_i           (exc_validD),
        .exc_codeD_i            (exc_codeD),
        .rs1_dataD_i            (rs1_dataD),
        .rs2_dataD_i            (rs2_dataD),
        .opr_aD_o               (opr_aD),
        .opr_bD_o               (opr_bD),
        .md_enD_o               (mdu_enD),
        .exu_opD_o              (mdu_exu_opD),
        .word_opD_o             (mdu_word_opD),
        .mdu_readyD_i           (mdu_readyD),
        .opr_aE_o               (opr_aE),
        .opr_bE_o               (opr_bE),
        .word_opE_o             (word_opE),
        .branch_enE_o           (branch_enE),
        .exu_opE_o              (exu_opE),
        .branch_opE_o           (branch_opE),
        .alu_resE_i             (alu_resE),
        .branch_takenE_i        (branch_takenE),
        .mdu_res_validE_i       (mdu_res_validE),
        .mdu_resE_i             (mdu_resE),
        .lsu_validE_o           (lsu_validE),
        .lsu_dataE_o            (lsu_dataE),
        .lsu_lsE_o              (lsu_lsE),
        .lsu_addrE_o            (lsu_addrE),
        .lsu_sizeE_o            (lsu_sizeE),
        .lsu_seE_o              (lsu_seE),
        .lsu_readyE_i           (lsu_readyE),
        .atomic_opE_o           (atomic_opE),
        .csr_wr_enM_o           (csr_wr_enM),
        .csr_addrM_o            (csr_addrM),
        .csr_wr_dataM_o         (csr_wr_dataM),
        .csr_opM_o              (csr_opM),
        .csr_dataM_i            (csr_dataM),
        .rs2_dataM_o            (rs2_dataM),
        .lsu_ldataM_i           (lsu_ldataM),
        .addrM_i                (addrM),
        .mretM_o                (mretM),
        .sretM_o                (sretM),
        .validM_o               (validM),
        .dc_cleanM_o            (dc_cleanM),
        .dc_clean_doneM_i       (dc_clean_doneM),
        .exc_validM_i           (exc_validM),
        .exc_codeM_i            (exc_codeM),
        .exc_validM_o           (exc_valid),
        .exc_codeM_o            (exc_code),
        .pcM_o                  (pcM),
        .nxt_pcM_o              (nxt_pcM),
        .exc_xtvalM_o           (exc_xtvalM),
        .trap_en_i              (trap_en),
        .trap_pc_i              (trap_pc),
        .mepc_i                 (mepc),
        .sepc_i                 (sepc),
        .mstatus_tw_i           (mstatus_tw),
        .priv_level_i           (priv_level),
        .wfi_wakeup_i           (wfi_wakeup),
        .rdW_o                  (rdW),
        .rf_wr_enW_o            (rf_wr_enW),
        .rf_wr_dataW_o          (rf_wr_dataW),
        .stallD_o               (stallD),
        .stallE_o               (stallE),
        .stallM_o               (stallM),
        .flushF_o               (flushF),
        .flushE_o               (flushE),
        .retire_o               (retire)
    );

    ifu u_ifu (
        .clk                    (clk),
        .resetn                 (resetn),
        .pc_i                   (nxt_pcF),
        .ifu_ready_o            (ifu_ready),
        .stallD_i               (stallD),
        .instr_o                (instrF),
        .instr_valid_o          (instr_validF),
        .ic_invalidate_i        (ic_invalidate),
        .ic_invalidate_done_o   (ic_invalidate_done),
        .flushF_i               (flushF),
        .pcF_o                  (pcF),
        .exc_valid_o            (exc_validF),
        .exc_code_o             (exc_codeF),
        .priv_level_i           (priv_level),
        .pmpaddr0_i             (pmpaddr0),
        .pmpaddr1_i             (pmpaddr1),
        .pmpaddr2_i             (pmpaddr2),
        .pmpaddr3_i             (pmpaddr3),
        .pmpaddr4_i             (pmpaddr4),
        .pmpaddr5_i             (pmpaddr5),
        .pmpaddr6_i             (pmpaddr6),
        .pmpaddr7_i             (pmpaddr7),
        .pmpaddr8_i             (pmpaddr8),
        .pmpaddr9_i             (pmpaddr9),
        .pmpaddr10_i            (pmpaddr10),
        .pmpaddr11_i            (pmpaddr11),
        .pmpaddr12_i            (pmpaddr12),
        .pmpaddr13_i            (pmpaddr13),
        .pmpaddr14_i            (pmpaddr14),
        .pmpaddr15_i            (pmpaddr15),
        .pmpcfg0_i              (pmpcfg0),
        .pmpcfg2_i              (pmpcfg2),
        .arready_i              (ifu_arready),
        .araddr_o               (ifu_araddr),
        .arlen_o                (ifu_arlen),
        .arsize_o               (ifu_arsize),
        .arburst_o              (ifu_arburst),
        .arlock_o               (ifu_arlock),
        .arid_o                 (ifu_arid),
        .arcache_o              (ifu_arcache),
        .arprot_o               (ifu_arprot),
        .arqos_o                (ifu_arqos),
        .arvalid_o              (ifu_arvalid),
        .rvalid_i               (ifu_rvalid),
        .rdata_i                (ifu_rdata),
        .rresp_i                (ifu_rresp),
        .rlast_i                (ifu_rlast),
        .rid_i                  (ifu_rid),
        .rready_o               (ifu_rready)
    );

    decode u_decode (
        .instr_i                (instrD),
        .priv_level_i           (priv_level),
        .mcounteren_i           (mcounteren),
        .scounteren_i           (scounteren),
        .mstatus_tsr_i          (mstatus_tsr),
        .mstatus_tw_i           (mstatus_tw),
        .mstatus_tvm_i          (mstatus_tvm),
        .menvcfg_stce_i         (menvcfg_stce),
        .rs1_o                  (rs1D),
        .rs2_o                  (rs2D),
        .rd_o                   (rdD),
        .imm_o                  (immD),
        .csr_addr_o             (csr_addrD),
        .pc_sel_o               (pc_selD),
        .opa_sel_o              (opa_selD),
        .opb_sel_o              (opb_selD),
        .rs1_used_o             (rs1_usedD),
        .rs2_used_o             (rs2_usedD),
        .word_op_o              (word_opD),
        .alu_en_o               (alu_enD),
        .md_en_o                (md_enD),
        .exu_op_o               (exu_opD),
        .branch_op_o            (branch_opD),
        .csr_wr_en_o            (csr_wr_enD),
        .csr_op_o               (csr_opD),
        .mctrl_en_o             (mctrl_enD),
        .mctrl_op_o             (mctrl_opD),
        .lsu_en_o               (lsu_enD),
        .lsu_ls_o               (lsu_lsD),
        .lsu_size_o             (lsu_sizeD),
        .atomic_op_o            (atomic_opD),
        .lsu_se_o               (lsu_seD),
        .rf_wr_en_o             (rf_wr_enD),
        .rf_sel_o               (rf_selD),
        .exc_valid_o            (exc_validD),
        .exc_code_o             (exc_codeD)
    );

    register_file u_register_file (
        .rs1_addr_i             (rs1D),
        .rs2_addr_i             (rs2D),
        .rs1_data_o             (rs1_dataD),
        .rs2_data_o             (rs2_dataD),
        .rd_addr_i              (rdW),
        .wr_en_i                (rf_wr_enW),
        .wr_data_i              (rf_wr_dataW)
    );

    mdu u_mdu (
        .clk                    (clk),
        .resetn                 (resetn),
        .opr_a_i                (opr_aD),
        .opr_b_i                (opr_bD),
        .mdu_en_i               (mdu_enD),
        .exu_op_i               (mdu_exu_opD),
        .word_op_i              (mdu_word_opD),
        .mdu_ready_o            (mdu_readyD),
        .stallE_i               (stallE),
        .flushE_i               (flushE),
        .stallM_i               (stallM),
        .mdu_res_valid_o        (mdu_res_validE),
        .mdu_res_o              (mdu_resE)
    );

    alu u_alu (
        .opr_a_i                (opr_aE),
        .opr_b_i                (opr_bE),
        .alu_op_i               (exu_opE),
        .word_op_i              (word_opE),
        .alu_res_o              (alu_resE)
    );

    branch_control u_branch_control (
        .opr_a_i                (opr_aE),
        .opr_b_i                (opr_bE),
        .branch_en_i            (branch_enE),
        .branch_op_i            (branch_opE),
        .branch_taken_o         (branch_takenE)  
    );

    lsu u_lsu (
        .clk                    (clk),
        .resetn                 (resetn),
        .lsu_valid_i            (lsu_validE),
        .lsu_data_i             (lsu_dataE),
        .lsu_ls_i               (lsu_lsE),
        .lsu_addr_i             (lsu_addrE),
        .lsu_size_i             (lsu_sizeE),
        .lsu_se_i               (lsu_seE),
        .lsu_ready_o            (lsu_readyE),
        .atomic_op_i            (atomic_opE),
        .addrM_o                (addrM),
        .lsu_ldata_o            (lsu_ldataM),
        .priv_level_i           (priv_level),
        .mstatus_mpp_i          (mstatus_mpp),
        .mstatus_mprv_i         (mstatus_mprv),
        .mstatus_mbe_i          (mstatus_mbe),
        .mstatus_sbe_i          (mstatus_sbe),
        .mstatus_ube_i          (mstatus_ube),
        .rs2_dataM_i            (rs2_dataM),
        .dc_clean_i             (dc_cleanM),
        .dc_clean_done_o        (dc_clean_doneM),
        .trap_en_i              (trap_en),
        .exc_valid_o            (exc_validM),
        .exc_code_o             (exc_codeM),
        .pmpaddr0_i             (pmpaddr0),
        .pmpaddr1_i             (pmpaddr1),
        .pmpaddr2_i             (pmpaddr2),
        .pmpaddr3_i             (pmpaddr3),
        .pmpaddr4_i             (pmpaddr4),
        .pmpaddr5_i             (pmpaddr5),
        .pmpaddr6_i             (pmpaddr6),
        .pmpaddr7_i             (pmpaddr7),
        .pmpaddr8_i             (pmpaddr8),
        .pmpaddr9_i             (pmpaddr9),
        .pmpaddr10_i            (pmpaddr10),
        .pmpaddr11_i            (pmpaddr11),
        .pmpaddr12_i            (pmpaddr12),
        .pmpaddr13_i            (pmpaddr13),
        .pmpaddr14_i            (pmpaddr14),
        .pmpaddr15_i            (pmpaddr15),
        .pmpcfg0_i              (pmpcfg0),
        .pmpcfg2_i              (pmpcfg2),
        .arready_i              (lsu_arready),
        .araddr_o               (lsu_araddr),
        .arlen_o                (lsu_arlen),
        .arsize_o               (lsu_arsize),
        .arburst_o              (lsu_arburst),
        .arlock_o               (lsu_arlock),
        .arid_o                 (lsu_arid),
        .arcache_o              (lsu_arcache),
        .arprot_o               (lsu_arprot),
        .arqos_o                (lsu_arqos),
        .arvalid_o              (lsu_arvalid),
        .rvalid_i               (lsu_rvalid),
        .rdata_i                (lsu_rdata),
        .rresp_i                (lsu_rresp),
        .rlast_i                (lsu_rlast),
        .rid_i                  (lsu_rid),
        .rready_o               (lsu_rready),
        .awready_i              (lsu_awready),
        .wready_i               (lsu_wready),
        .awaddr_o               (lsu_awaddr),
        .awvalid_o              (lsu_awvalid),
        .awsize_o               (lsu_awsize),
        .awlen_o                (lsu_awlen),
        .awburst_o              (lsu_awburst),
        .awlock_o               (lsu_awlock),
        .awid_o                 (lsu_awid),
        .awcache_o              (lsu_awcache),
        .awprot_o               (lsu_awprot),
        .awqos_o                (lsu_awqos),
        .wdata_o                (lsu_wdata),
        .wstrb_o                (lsu_wstrb),
        .wvalid_o               (lsu_wvalid),
        .wlast_o                (lsu_wlast),
        .bresp_i                (lsu_bresp),
        .bvalid_i               (lsu_bvalid),
        .bid_i                  (lsu_bid),
        .bready_o               (lsu_bready)
    );

    privileged u_privileged (
        .clk                    (clk),
        .resetn                 (resetn),
        .csr_wr_en_i            (csr_wr_enM),
        .csr_addr_i             (csr_addrM),
        .csr_wr_data_i          (csr_wr_dataM),
        .csr_op_i               (csr_opM),
        .csr_data_o             (csr_dataM),
        .mret_i                 (mretM),                 
        .sret_i                 (sretM),
        .validM_i               (validM),
        .committedM_i           (lsu_committed),
        .retire_i               (retire),
        .exc_validM_i           (exc_valid),                 
        .exc_codeM_i            (exc_code),                
        .pcM_i                  (pcM),
        .nxt_pcM_i              (nxt_pcM),
        .exc_xtvalM_i           (exc_xtvalM),
        .trap_en_o              (trap_en),
        .trap_pc_o              (trap_pc),
        .mepc_o                 (mepc),
        .sepc_o                 (sepc),
        .wfi_wakeup_o           (wfi_wakeup),
        .mtime_i                (mtime_i),                 
        .mtip_i                 (mtip_i),
        .msip_i                 (msip_i),
        .meip_i                 (meip_i),
        .seip_i                 (seip_i),
        .priv_level_o           (priv_level),
        .scounteren_o           (scounteren),
        .mcounteren_o           (mcounteren),
        .mstatus_ube_o          (mstatus_ube),
        .mstatus_mpp_o          (mstatus_mpp),
        .mstatus_mprv_o         (mstatus_mprv),
        .mstatus_tvm_o          (mstatus_tvm),
        .mstatus_tw_o           (mstatus_tw),
        .mstatus_tsr_o          (mstatus_tsr),
        .mstatus_sbe_o          (mstatus_sbe),
        .mstatus_mbe_o          (mstatus_mbe),
        .menvcfg_stce_o         (menvcfg_stce),
        .pmpcfg0_o              (pmpcfg0),
        .pmpcfg2_o              (pmpcfg2),
        .pmpaddr0_o             (pmpaddr0),
        .pmpaddr1_o             (pmpaddr1),
        .pmpaddr2_o             (pmpaddr2),
        .pmpaddr3_o             (pmpaddr3),
        .pmpaddr4_o             (pmpaddr4),
        .pmpaddr5_o             (pmpaddr5),
        .pmpaddr6_o             (pmpaddr6),
        .pmpaddr7_o             (pmpaddr7),
        .pmpaddr8_o             (pmpaddr8),
        .pmpaddr9_o             (pmpaddr9),
        .pmpaddr10_o            (pmpaddr10),
        .pmpaddr11_o            (pmpaddr11),
        .pmpaddr12_o            (pmpaddr12),
        .pmpaddr13_o            (pmpaddr13),
        .pmpaddr14_o            (pmpaddr14),
        .pmpaddr15_o            (pmpaddr15)
    );

    arbitrate u_arbitrate (
        .clk                    (clk),
        .resetn                 (resetn),
        .lsu_araddr_i           (lsu_araddr),
        .lsu_arlen_i            (lsu_arlen),
        .lsu_arsize_i           (lsu_arsize),
        .lsu_arburst_i          (lsu_arburst),
        .lsu_arlock_i           (lsu_arlock),
        .lsu_arid_i             (lsu_arid),
        .lsu_arcache_i          (lsu_arcache),
        .lsu_arprot_i           (lsu_arprot),
        .lsu_arqos_i            (lsu_arqos),
        .lsu_arvalid_i          (lsu_arvalid),
        .lsu_arready_o          (lsu_arready),
        .lsu_rready_i           (lsu_rready),
        .lsu_rvalid_o           (lsu_rvalid),
        .lsu_rid_o              (lsu_rid),
        .lsu_rdata_o            (lsu_rdata),
        .lsu_rresp_o            (lsu_rresp),
        .lsu_rlast_o            (lsu_rlast),
        .lsu_awaddr_i           (lsu_awaddr),
        .lsu_awvalid_i          (lsu_awvalid),
        .lsu_awsize_i           (lsu_awsize),
        .lsu_awlen_i            (lsu_awlen),
        .lsu_awburst_i          (lsu_awburst),
        .lsu_awlock_i           (lsu_awlock),
        .lsu_awid_i             (lsu_awid),
        .lsu_awcache_i          (lsu_awcache),
        .lsu_awprot_i           (lsu_awprot),
        .lsu_awqos_i            (lsu_awqos),
        .lsu_wdata_i            (lsu_wdata),
        .lsu_wstrb_i            (lsu_wstrb),
        .lsu_wvalid_i           (lsu_wvalid),
        .lsu_wlast_i            (lsu_wlast),
        .lsu_awready_o          (lsu_awready),
        .lsu_wready_o           (lsu_wready),
        .lsu_bready_i           (lsu_bready),
        .lsu_bresp_o            (lsu_bresp),
        .lsu_bvalid_o           (lsu_bvalid),
        .lsu_bid_o              (lsu_bid),
        .ifu_araddr_i           (ifu_araddr),
        .ifu_arlen_i            (ifu_arlen),
        .ifu_arsize_i           (ifu_arsize),
        .ifu_arburst_i          (ifu_arburst),
        .ifu_arlock_i           (ifu_arlock),
        .ifu_arid_i             (ifu_arid),
        .ifu_arcache_i          (ifu_arcache),
        .ifu_arprot_i           (ifu_arprot),
        .ifu_arqos_i            (ifu_arqos),
        .ifu_arvalid_i          (ifu_arvalid),
        .ifu_arready_o          (ifu_arready),
        .ifu_rready_i           (ifu_rready),
        .ifu_rvalid_o           (ifu_rvalid),
        .ifu_rdata_o            (ifu_rdata),
        .ifu_rresp_o            (ifu_rresp),
        .ifu_rlast_o            (ifu_rlast),
        .ifu_rid_o              (ifu_rid),
        .arready_i              (arready_i),
        .araddr_o               (araddr_o),
        .arlen_o                (arlen_o),
        .arsize_o               (arsize_o),
        .arburst_o              (arburst_o),
        .arlock_o               (arlock_o),
        .arid_o                 (arid_o),
        .arcache_o              (arcache_o),
        .arprot_o               (arprot_o),
        .arqos_o                (arqos_o),
        .arvalid_o              (arvalid_o),
        .rvalid_i               (rvalid_i),
        .rdata_i                (rdata_i),
        .rresp_i                (rresp_i),
        .rlast_i                (rlast_i),
        .rid_i                  (rid_i),
        .rready_o               (rready_o),
        .awready_i              (awready_i),
        .wready_i               (wready_i),
        .awaddr_o               (awaddr_o),
        .awvalid_o              (awvalid_o),
        .awsize_o               (awsize_o),
        .awlen_o                (awlen_o),
        .awburst_o              (awburst_o),
        .awlock_o               (awlock_o),
        .awid_o                 (awid_o),
        .awcache_o              (awcache_o),
        .awprot_o               (awprot_o),
        .awqos_o                (awqos_o),
        .wdata_o                (wdata_o),
        .wstrb_o                (wstrb_o),
        .wvalid_o               (wvalid_o),
        .wlast_o                (wlast_o),
        .bresp_i                (bresp_i),
        .bvalid_i               (bvalid_i),
        .bid_i                  (bid_i),
        .bready_o               (bready_o)
    );

endmodule