module lsu (
    input logic             clk,
    input logic             resetn,

    input logic             lsu_valid_i,
    input logic [63:0]      lsu_data_i,
    input logic [1:0]       lsu_ls_i,
    input logic [63:0]      lsu_addr_i,
    input logic [1:0]       lsu_size_i,
    input logic             lsu_se_i,
    output logic            lsu_stall_o,

    input logic [3:0]       atomic_op_i,

    input logic             stallW_i,
    output logic            lsu_rvalid_o,
    output logic [63:0]     lsu_ldata_o,

    input logic [1:0]       priv_level_i,
    input logic [1:0]       mstatus_mpp_i,
    input logic             mstatus_mprv_i, 
    input logic             mstatus_mbe_i,
    input logic             mstatus_sbe_i,
    input logic             mstatus_ube_i,

    input logic [63:0]      rs2_ldM_i,

    input logic             dc_clean_i,
    output logic            dc_clean_done_o,

    input logic             trap_en_i,
    input logic             flushM_i,

    output logic            lsu_committed_o,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o,

    input logic [63:0]      pmpaddr0_i,
    input logic [63:0]      pmpaddr1_i,
    input logic [63:0]      pmpaddr2_i,
    input logic [63:0]      pmpaddr3_i,
    input logic [63:0]      pmpaddr4_i,
    input logic [63:0]      pmpaddr5_i,
    input logic [63:0]      pmpaddr6_i,
    input logic [63:0]      pmpaddr7_i,
    input logic [63:0]      pmpaddr8_i,
    input logic [63:0]      pmpaddr9_i,
    input logic [63:0]      pmpaddr10_i,
    input logic [63:0]      pmpaddr11_i,
    input logic [63:0]      pmpaddr12_i,
    input logic [63:0]      pmpaddr13_i,
    input logic [63:0]      pmpaddr14_i,
    input logic [63:0]      pmpaddr15_i,
    input logic [63:0]      pmpcfg0_i,
    input logic [63:0]      pmpcfg1_i,

    //AXI interface
    //load address -> bus (AR channel)
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
    
    //load data -> lsu (R channel)
    input logic             rvalid_i,
    input logic [63:0]      rdata_i,
    input logic [1:0]       rresp_i,
    input logic             rlast_i,
    input logic [3:0]       rid_i,
    output logic            rready_o,

    //store request (AW, W channels)
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

    //store response (B channel)
    input logic [1:0]       bresp_i,
    input logic             bvalid_i,
    input logic [3:0]       bid_i,
    output logic            bready_o
);

    d_pma u_d_pma (
        .lsu_valid_i        (validM),
        .lsu_addr_i         (addrM),
        .lsu_ls_i           (lsM),
        .lsu_size_i         (sizeM),
        .pma_cacheable_o    (pma_cacheable),
        .pma_idempotent_o   (pma_idempotent),
        .pma_fault_o        (pma_fault)
    );

    d_pmp u_d_pmp (
        .lsu_valid_i        (validM),
        .lsu_addr_i         (addrM),
        .lsu_ls_i           (lsM),
        .lsu_size_i         (sizeM),
        .priv_level_i       (priv_level_i),
        .mstatus_mpp_i      (mstatus_mpp_i),
        .mstatus_mprv_i     (mstatus_mprv_i),
        .pmpaddr0_i         (pmpaddr0_i),
        .pmpaddr1_i         (pmpaddr1_i),
        .pmpaddr2_i         (pmpaddr2_i),
        .pmpaddr3_i         (pmpaddr3_i),
        .pmpaddr4_i         (pmpaddr4_i),
        .pmpaddr5_i         (pmpaddr5_i),
        .pmpaddr6_i         (pmpaddr6_i),
        .pmpaddr7_i         (pmpaddr7_i),
        .pmpaddr8_i         (pmpaddr8_i),
        .pmpaddr9_i         (pmpaddr9_i),
        .pmpaddr10_i        (pmpaddr10_i),
        .pmpaddr11_i        (pmpaddr11_i),
        .pmpaddr12_i        (pmpaddr12_i),
        .pmpaddr13_i        (pmpaddr13_i),
        .pmpaddr14_i        (pmpaddr14_i),
        .pmpaddr15_i        (pmpaddr15_i),
        .pmpcfg0_i          (pmpcfg0_i),
        .pmpcfg1_i          (pmpcfg1_i),
        .pmp_fault_o        (pmp_fault)
    );

    amo_alu u_amo_alu (
        .lsu_ld_i           (load_data),
        .rs2_ld_i           (rs2_ldM_i),
        .atomic_op_i        (atomic_opM),
        .amo_word_op_i      (amo_word_opM),
        .amo_res_o          (amo_res)
    );

    store_es_algn u_store_es_algn (
        .raw_data_i         (store_raw_data), 
        .addr_algn_i        (store_addr_algn), 
        .store_size_i       (store_size), 
        .priv_level_i       (priv_level_i),
        .mstatus_mpp_i      (mstatus_mpp_i),
        .mstatus_mbe_i      (mstatus_mbe_i),
        .mstatus_sbe_i      (mstatus_sbe_i),
        .mstatus_ube_i      (mstatus_ube_i),
        .store_mask_o       (dc_mask),
        .store_data_o       (dc_data)
    );

    load_es_algn u_load_es_algn (
        .raw_data_i         (load_raw_data),
        .addr_algn_i        (addrM[2:0]),
        .load_size_i        (sizeM),
        .load_se_i          (seM),
        .priv_level_i       (priv_level_i),
        .mstatus_mpp_i      (mstatus_mpp_i),
        .mstatus_mprv_i     (mstatus_mprv_i),
        .mstatus_mbe_i      (mstatus_mbe_i),
        .mstatus_sbe_i      (mstatus_sbe_i),
        .mstatus_ube_i      (mstatus_ube_i),
        .load_data_o        (load_data)
    );

    d_cache u_d_cache (
        .clk                (clk),
        .resetn             (resetn),
        .dc_data_i          (dc_data),
        .dc_ls_i            (dc_ls),
        .dc_valid_i         (dc_valid),
        .dc_addr_i          (dc_addr),
        .dc_mask_i          (dc_mask),
        .dc_ready_o         (dc_ready),
        .lsu_ready_i        (lsu_ready),
        .dc_rvalid_o        (dc_resp_valid),
        .dc_ldata_o         (dc_ldata),
        .validM_o           (validM),
        .dataM_o            (dataM),
        .addrM_o            (addrM),
        .maskM_o            (maskM),
        .arready_i          (arready_i),
        .araddr_o           (dc_araddr),
        .arlen_o            (dc_arlen),
        .arsize_o           (dc_arsize),
        .arburst_o          (dc_arburst),
        .arlock_o           (dc_arlock),
        .arid_o             (dc_arid),
        .arcache_o          (dc_arcache),
        .arprot_o           (dc_arprot),
        .arqos_o            (dc_arqos),
        .arvalid_o          (dc_arvalid),
        .rid_i              (rid_i),
        .rdata_i            (rdata_i),
        .rresp_i            (rresp_i),
        .rlast_i            (rlast_i),
        .rvalid_i           (rvalid_i),
        .rready_o           (dc_rready),
        .awready_i          (awready_i),
        .wready_i           (wready_i),
        .awaddr_o           (dc_awaddr),
        .awvalid_o          (dc_awvalid),
        .awsize_o           (dc_awsize),
        .awlen_o            (dc_awlen),
        .awburst_o          (dc_awburst),
        .awlock_o           (dc_awlock),
        .awid_o             (dc_awid),
        .awcache_o          (dc_awcache),
        .awprot_o           (dc_awprot),
        .awqos_o            (dc_awqos),
        .wdata_o            (dc_wdata),
        .wstrb_o            (dc_wstrb),
        .wvalid_o           (dc_wvalid),
        .wlast_o            (dc_wlast),
        .bresp_i            (bresp_i),
        .bvalid_i           (bvalid_i),
        .bid_i              (bid_i),
        .bready_o           (dc_bready),
        .flushM_i           (flushM_i),
        .stop_cacheop_i     (stop_cacheop),
        .clean_i            (dc_clean_i),
        .clean_done_o       (dc_clean_done_o),
        .exc_valid_o        (dc_exc_valid)
    );

    logic [1:0]     sizeM;
    logic           seM;
    logic [3:0]     atomic_opM;
    logic [1:0]     lsM;

    logic           dc_ready;
    logic           dc_resp_valid;
    logic [63:0]    dc_ldata;
    logic           dc_exc_valid;

    logic           validM;
    logic [63:0]    dataM;
    logic [63:0]    addrM;
    logic [7:0]     maskM;

    logic           dc_valid;
    logic           dc_ls;
    logic [63:0]    dc_addr;
    logic [63:0]    dc_data;
    logic [7:0]     dc_mask;
    logic           lsu_ready;

    logic           stop_cacheop;

    logic [63:0]    dc_araddr;
    logic [7:0]     dc_arlen;
    logic [2:0]     dc_arsize;
    logic [1:0]     dc_arburst;
    logic           dc_arlock;
    logic [3:0]     dc_arid;
    logic [3:0]     dc_arcache;
    logic [2:0]     dc_arprot;
    logic [3:0]     dc_arqos;
    logic           dc_arvalid;
    logic           dc_rready;
    logic [63:0]    dc_awaddr;
    logic           dc_awvalid;
    logic [2:0]     dc_awsize;
    logic [7:0]     dc_awlen;
    logic [1:0]     dc_awburst;
    logic           dc_awlock;
    logic [3:0]     dc_awid;
    logic [3:0]     dc_awcache;
    logic [2:0]     dc_awprot;
    logic [3:0]     dc_awqos;
    logic [63:0]    dc_wdata;
    logic [7:0]     dc_wstrb;
    logic           dc_wvalid;
    logic           dc_wlast;
    logic           dc_bready;

    logic           pma_cacheable;
    logic           pma_idempotent;
    logic           pma_fault;
    logic           pmp_fault;

    logic [63:0]    store_raw_data;
    logic [2:0]     store_addr_algn;
    logic [1:0]     store_size;
    logic [63:0]    load_raw_data;
    logic [63:0]    load_data;

    logic [63:0]    amo_res;
    logic           amo_word_opM;
    logic           amo_store;
    logic           amo_store_ready;
    logic           amo_load_fault;
    logic           amo_load;
    logic [63:0]    amo_load_data;

    logic           LR_valid;
    logic [63:0]    LR_addr;
    logic [1:0]     LR_size;
    
    logic           LR_set;
    logic           LR_invalidate;

    logic           lrM;
    logic           scM;

    logic           sc_lr_miss;
    logic           sc_fail;

    logic           lr_addr_match;

    logic           lsu_store;

    logic           misaligned_addr;
    logic           misaligned_exc;
    logic           exc;

    logic           uncacheable_load;
    logic           uncacheable_store;

    logic [63:0]    mem_load_data;
    
    logic           aw_done;
    logic           w_done;

    logic           store_req_done;

    logic           exc_load;
    logic           exc_store;
    logic           exc_ff;

    logic           flush;
    logic           flush_ff;

    lsu_state_t     state;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            sizeM           <=  2'b0;
            seM             <=  1'b0;
            lsM             <=  2'b0;
            atomic_opM      <=  4'b0;

            amo_load        <=  1'b0;
            amo_load_data   <=  64'h0;
            mem_load_data   <=  64'h0;

            LR_valid        <=  1'b0;
            LR_addr         <=  64'h0;
            LR_size         <=  2'b0;

            aw_done         <=  1'b0;
            w_done          <=  1'b0;

            exc_ff          <=  1'b0;
            flush_ff        <=  1'b0;

            state           <=  LSU_DC_RUN;
        end else begin
            case (state)
                LSU_DC_RUN: begin
                    if (dc_ready) begin
                        sizeM       <=  lsu_size_i;
                        seM         <=  lsu_se_i;
                        atomic_opM  <=  atomic_op_i;
                        lsM         <=  lsu_ls_i;

                        amo_load    <=  1'b0;
                    end
                    if (LR_invalidate) begin
                        LR_valid    <=  1'b0;
                    end else if (LR_set) begin
                        LR_size     <=  sizeM;
                        LR_addr     <=  addrM;
                        LR_valid    <=  1'b1;
                    end

                    if (uncacheable_load) begin
                        state       <=  LSU_MEM_LOAD_REQ;
                    end else if (uncacheable_store) begin
                        state       <=  LSU_MEM_STORE_REQ;
                    end else if (amo_store) begin
                        state       <=  LSU_AMO_STORE;
                    end
                end
                LSU_MEM_LOAD_REQ: begin
                    flush_ff        <=  flush_ff || flushM_i;

                    if (trap_en_i)
                        LR_valid    <=  1'b0;

                    if (arready_i)
                        state       <=  LSU_MEM_LOAD;
                end
                LSU_MEM_LOAD: begin
                    flush_ff        <=  flush_ff || flushM_i;
                    exc_ff          <=  exc_load;

                    if (trap_en_i)
                        LR_valid    <=  1'b0;

                    if (rvalid_i) begin
                        mem_load_data   <=  rdata_i;

                        state           <=  LSU_MEM_LOAD_DONE;
                    end
                end
                LSU_MEM_LOAD_DONE: begin
                    flush_ff        <=  flush_ff || flushM_i;

                    if (trap_en_i)
                        LR_valid    <=  1'b0;

                    if (!stallW_i || flush) begin
                        flush_ff        <=  1'b0;
                        exc_ff          <=  1'b0;
                        mem_load_data   <=  64'h0;

                        sizeM           <=  lsu_size_i;
                        seM             <=  lsu_se_i;
                        atomic_opM      <=  atomic_op_i;
                        lsM             <=  lsu_ls_i;

                        state           <=  LSU_DC_RUN;
                    end
                end
                LSU_MEM_STORE_REQ: begin
                    aw_done         <=  aw_done || awready_i;
                    w_done          <=  w_done || wready_i;

                    if (store_req_done) begin
                        aw_done     <=  1'b0;
                        w_done      <=  1'b0;

                        state       <=  LSU_MEM_STORE;
                    end
                end
                LSU_MEM_STORE: begin
                    exc_ff          <=  exc_store;

                    if (bvalid_i)
                        state       <=  LSU_MEM_STORE_DONE;
                end
                LSU_MEM_STORE_DONE: begin
                    if (!stallW_i) begin
                        sizeM       <=  lsu_size_i;
                        seM         <=  lsu_se_i;
                        atomic_opM  <=  atomic_op_i;
                        lsM         <=  lsu_ls_i;

                        exc_ff      <=  1'b0;

                        state       <=  LSU_DC_RUN;
                    end
                end
                LSU_AMO_STORE: begin
                    if (LR_invalidate)
                        LR_valid    <=  1'b0;
                    
                    if (amo_store_ready || amo_load_fault || flushM_i) begin
                        amo_load_data   <=  load_data; 
                        amo_load        <=  !amo_load_fault && !flushM_i;

                        state       <=  LSU_DC_RUN;
                    end
                end
            endcase
        end
    end

    always_comb begin
        lsu_stall_o         =   !dc_ready;
        lsu_ready           =   1'b0;
        lsu_rvalid_o        =   1'b0;
        lsu_ldata_o         =   load_data;

        lsu_committed_o     =   1'b0;

        dc_valid            =   lsu_valid_i;
        dc_addr             =   lsu_addr_i;

        arvalid_o           =   1'b0;
        araddr_o            =   dc_araddr;
        arlen_o             =   dc_arlen;
        arsize_o            =   dc_arsize;
        arburst_o           =   dc_arburst;
        arlock_o            =   dc_arlock;
        arid_o              =   dc_arid;
        arcache_o           =   dc_arcache;
        arprot_o            =   dc_arprot;
        arqos_o             =   dc_arqos;

        rready_o            =   1'b0;

        awvalid_o           =   1'b0;
        awaddr_o            =   dc_awaddr;
        awsize_o            =   dc_awsize;
        awlen_o             =   dc_awlen;
        awburst_o           =   dc_awburst;
        awlock_o            =   dc_awlock;
        awid_o              =   dc_awid;
        awcache_o           =   dc_awcache;
        awprot_o            =   dc_awprot;
        awqos_o             =   dc_awqos;

        wvalid_o            =   1'b0;
        wdata_o             =   dc_wdata;
        wstrb_o             =   dc_wstrb;
        wlast_o             =   dc_wlast;

        bready_o            =   1'b0;

        exc_valid_o         =   1'b0;
        exc_code_o          =   5'd0;

        exc_load            =   rvalid_i && ((rid_i != ID_LSU) || (rresp_i != 2'b00) || !rlast_i);
        exc_store           =   bvalid_i && ((bresp_i != 2'b00) || (bid_i != ID_LSU));

        flush               =   flush_ff || flushM_i;

        dc_ls               =   (lsu_ls_i == LSU_STORE) || ((lsu_ls_i == LSU_ATOMIC) && (atomic_op_i == SC));

        store_raw_data      =   lsu_data_i;
        store_addr_algn     =   lsu_addr_i[2:0];
        store_size          =   lsu_size_i;

        load_raw_data       =   dc_ldata;

        amo_word_opM        =   (sizeM == WORD);

        case (sizeM)
            BYTE: misaligned_addr           =   1'b0;
            HALF_WORD: misaligned_addr      =   addrM[0];
            WORD: misaligned_addr           =   |addrM[1:0];
            DOUBLE_WORD: misaligned_addr    =   |addrM[2:0];
        endcase

        exc                 =   validM && !flushM_i && (pma_fault || pmp_fault || misaligned_addr);

        scM                 =   validM && !flushM_i && !exc && (lsM == LSU_ATOMIC) && (atomic_opM == SC);
        sc_lr_miss          =   !LR_valid || (LR_addr != addrM) || (LR_size != sizeM);
        sc_fail             =   scM && sc_lr_miss;

        stop_cacheop        =   !pma_cacheable || sc_fail || exc;

        uncacheable_load    =   1'b0;
        uncacheable_store   =   1'b0;
        amo_store           =   1'b0;
        amo_store_ready     =   1'b0;
        amo_load_fault      =   1'b0;
        store_req_done      =   1'b0;
        LR_set              =   1'b0;
        LR_invalidate       =   1'b0;

        lrM                 =   1'b0;
        lr_addr_match       =   1'b0;

        lsu_store           =   (lsM == LSU_STORE) || ((lsM == LSU_ATOMIC) && (atomic_opM != LR));
        misaligned_exc      =   misaligned_addr && (lsM != LSU_ATOMIC);

        case (state)
            LSU_DC_RUN: begin
                arvalid_o           =   dc_arvalid;
                rready_o            =   dc_rready;
                awvalid_o           =   dc_awvalid;
                wvalid_o            =   dc_wvalid;
                bready_o            =   dc_bready;

                exc_valid_o         =   exc || dc_exc_valid;
                exc_code_o          =   misaligned_exc ? (lsu_store ? S_AMO_ADDR_MISALIGNED : L_ADDR_MISALIGNED) : (lsu_store ? S_AMO_ACC_FAULT : L_ACC_FAULT);

                lsu_rvalid_o        =   dc_resp_valid || sc_fail || exc;
                lsu_ldata_o         =   amo_load ? amo_load_data : (scM ? {63'h0, sc_lr_miss} : load_data);

                uncacheable_load    =   validM && !flushM_i && !pma_cacheable && !exc && (lsM == LSU_LOAD);
                uncacheable_store   =   validM && !flushM_i && !pma_cacheable && !exc && (lsM == LSU_STORE);
                amo_store           =   lsu_valid_i && (lsu_ls_i == LSU_ATOMIC) && !((atomic_op_i == SC) || (atomic_op_i == LR)) && dc_ready;

                lrM                 =   validM && !flushM_i && !exc && (lsM == LSU_ATOMIC) && (atomic_opM == LR);

                lr_addr_match       =   validM && !flushM_i && (lsM == LSU_STORE) && (addrM[63:3] == LR_addr[63:3]);

                LR_set              =   lrM && dc_resp_valid && !dc_exc_valid;
                LR_invalidate       =   trap_en_i || (validM && (scM || lr_addr_match));
            end
            LSU_MEM_LOAD_REQ: begin
                lsu_committed_o     =   !pma_idempotent;

                arvalid_o           =   1'b1;
                araddr_o            =   addrM;
                arlen_o             =   8'd0;
                arsize_o            =   {1'b0, sizeM};
                arburst_o           =   INCR;
                arlock_o            =   1'b0;
                arid_o              =   ID_LSU;
                arcache_o           =   CACHE_DEV_NONBUF;
                arprot_o            =   PROT_LSU;
                arqos_o             =   4'b0000;
            end
            LSU_MEM_LOAD: begin
                lsu_committed_o     =   !pma_idempotent;
                
                rready_o            =   1'b1;
            end
            LSU_MEM_LOAD_DONE: begin
                lsu_committed_o     =   1'b0;

                load_raw_data       =   mem_load_data;

                lsu_ready           =   !stallW_i || flush;
                lsu_rvalid_o        =   !flush;
                
                exc_valid_o         =   exc_ff && !flush;
                exc_code_o          =   L_ACC_FAULT;
            end
            LSU_MEM_STORE_REQ: begin
                lsu_committed_o     =   1'b1;

                awvalid_o           =   !aw_done;
                awaddr_o            =   addrM;
                awsize_o            =   {1'b0, sizeM};
                awlen_o             =   8'd0;
                awburst_o           =   INCR;
                awlock_o            =   1'b0;
                awid_o              =   ID_LSU;
                awcache_o           =   CACHE_DEV_NONBUF;
                awprot_o            =   PROT_LSU;
                awqos_o             =   4'b0000;

                wvalid_o            =   !w_done;
                wdata_o             =   dataM;
                wstrb_o             =   maskM;
                wlast_o             =   1'b1;

                store_req_done      =   (aw_done || awready_i) && (w_done || wready_i);
            end
            LSU_MEM_STORE: begin
                lsu_committed_o     =   1'b1;

                bready_o            =   1'b1;
            end
            LSU_MEM_STORE_DONE: begin
                lsu_ready           =   !stallW_i;
                lsu_rvalid_o        =   1'b1;

                exc_valid_o         =   exc_ff;
                exc_code_o          =   S_AMO_ACC_FAULT;
            end
            LSU_AMO_STORE: begin
                arvalid_o           =   dc_arvalid;
                rready_o            =   dc_rready;
                awvalid_o           =   dc_awvalid;
                wvalid_o            =   dc_wvalid;
                bready_o            =   dc_bready;

                lsu_ready           =   !stallW_i;
                lsu_stall_o         =   1'b1;
                
                store_raw_data      =   amo_res;
                store_addr_algn     =   addrM[2:0];
                store_size          =   sizeM;

                dc_ls               =   DC_STORE;
                dc_valid            =   !exc && !flushM_i;
                dc_addr             =   addrM;

                LR_invalidate       =   trap_en_i || (addrM[63:3] == LR_addr[63:3]);

                amo_store_ready     =   dc_resp_valid && dc_ready && !stallW_i;
                amo_load_fault      =   exc && !stallW_i;
            end
        endcase
    end

endmodule