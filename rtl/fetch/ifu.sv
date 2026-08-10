import cpu_defines::*;
import cpu_types::*;

module ifu (
    input logic             clk,
    input logic             resetn,

    input logic             resetn_q_i,

    input logic [63:0]      pc_i,
    input logic [63:0]      nxt_pc_i,
    output logic            stall_ifu_o,

    input logic             stallD_i,
    output logic [31:0]     instr_o,
    output logic            instr_valid_o,

    input logic             ic_invalidate_i,
    output logic            ic_invalidate_done_o,
    
    input logic             flushF_i,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o,

    input logic [1:0]       priv_level_i,

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
    input logic [63:0]      pmpcfg2_i,

    //AXI interface
    //read address -> bus (AR channel)
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

    //read data -> cache (R channel)
    input logic             rvalid_i,
    input logic [63:0]      rdata_i,
    input logic [1:0]       rresp_i,
    input logic             rlast_i,
    input logic [3:0]       rid_i,
    output logic            rready_o
);

    logic [63:0]    ifu_pc;
    
    logic           ifu_ready;
    logic           uncacheable;
    logic           stop_fillline;

    logic           flush;
    logic           flush_ff;
    logic           exc_ff;

    logic           ifu_bus;

    logic [31:0]    instr_hold;

    logic           pma_cacheable;
    logic           pma_fault;
    logic           pmp_fault;

    logic           ic_ready;
    logic           ic_instr_valid;
    logic [31:0]    ic_instr;

    logic [63:0]    pcF;

    logic           ic_exc_valid;
    logic [4:0]     ic_exc_code;

    logic [63:0]    ic_araddr;
    logic [7:0]     ic_arlen;
    logic [2:0]     ic_arsize;
    logic [1:0]     ic_arburst;
    logic           ic_arlock;
    logic [3:0]     ic_arid;
    logic [3:0]     ic_arcache;
    logic [2:0]     ic_arprot;
    logic [3:0]     ic_arqos;
    logic           ic_arvalid;
    logic           ic_arready;

    logic           ic_rvalid;
    logic [63:0]    ic_rdata;
    logic [1:0]     ic_rresp;
    logic           ic_rlast;
    logic [3:0]     ic_rid;
    logic           ic_rready;

    ifu_state_t     state;

    i_pma u_i_pma (
        .pc_i               (pcF),
        .pma_cacheable_o    (pma_cacheable),
        .pma_fault_o        (pma_fault)
    );

    i_pmp u_i_pmp (
        .pc_i               (pcF),
        .priv_level_i       (priv_level_i),
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
        .pmpcfg2_i          (pmpcfg2_i),
        .pmp_fault_o        (pmp_fault)
    );

    i_cache u_i_cache (
        .clk                (clk),
        .resetn             (resetn),
        .resetn_q_i         (resetn_q_i),
        .ic_ready_o         (ic_ready),
        .pc_i               (ifu_pc),
        .ifu_ready_i        (ifu_ready),
        .instr_valid_o      (ic_instr_valid),
        .instr_o            (ic_instr),
        .pcF_o              (pcF),
        .arready_i          (ic_arready),
        .araddr_o           (ic_araddr),
        .arlen_o            (ic_arlen),
        .arsize_o           (ic_arsize),
        .arburst_o          (ic_arburst),
        .arlock_o           (ic_arlock),
        .arid_o             (ic_arid),
        .arcache_o          (ic_arcache),
        .arprot_o           (ic_arprot),
        .arqos_o            (ic_arqos),
        .arvalid_o          (ic_arvalid),
        .rid_i              (ic_rid),
        .rdata_i            (ic_rdata),
        .rresp_i            (ic_rresp),
        .rlast_i            (ic_rlast),
        .rvalid_i           (ic_rvalid),
        .rready_o           (ic_rready),
        .flush_i            (flushF_i),
        .stop_fillline_i    (stop_fillline),
        .invalidate_i       (ic_invalidate_i),
        .invalidate_done_o  (ic_invalidate_done_o),
        .exc_valid_o        (ic_exc_valid),
        .exc_code_o         (ic_exc_code)
    );

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            instr_hold  <=  32'h0;

            flush_ff    <=  1'b0;
            exc_ff      <=  1'b0;

            state       <=  IFU_IC_RUN;
        end else begin
            case (state)
                IFU_IC_RUN: begin
                    if (uncacheable)
                        state   <=  IFU_MEM_REQ;
                end
                IFU_MEM_REQ: begin
                    if (arready_i)
                        state   <=  IFU_MEM_WAIT;

                    flush_ff    <=  flush_ff || flushF_i;
                end
                IFU_MEM_WAIT: begin
                    if (rvalid_i) begin
                        instr_hold  <=  pcF[2] ? rdata_i[63:32] : rdata_i[31:0];
                        state       <=  IFU_MEM_DONE;
                    end

                    flush_ff        <=  flush_ff || flushF_i;
                    exc_ff          <=  rvalid_i && (((rresp_i != 2'b00) || (rid_i != ID_IFU)) || !rlast_i);
                end
                IFU_MEM_DONE: begin
                    if (!stallD_i || flush) begin
                        flush_ff    <=  1'b0;
                        exc_ff      <=  1'b0;
                        instr_hold  <=  32'h0;

                        state       <=  IFU_IC_RUN;
                    end else begin
                        flush_ff    <=  flush_ff || flushF_i;
                    end
                end
            endcase
        end
    end

    always_comb begin
        stall_ifu_o     =   1'b0;
        instr_o         =   32'h0;
        instr_valid_o   =   1'b0;
        ifu_ready       =   1'b0;

        uncacheable     =   1'b0;
        flush           =   1'b0;

        ifu_pc          =   resetn_q_i ? nxt_pc_i : pc_i;

        stop_fillline   =   !pma_cacheable || pma_fault || pmp_fault;

        ifu_bus         =   (state == IFU_MEM_REQ) || (state == IFU_MEM_WAIT);

        araddr_o        =   ic_araddr;
        arlen_o         =   ic_arlen;
        arsize_o        =   ic_arsize;
        arburst_o       =   ic_arburst;
        arlock_o        =   ic_arlock;
        arid_o          =   ic_arid;
        arcache_o       =   ic_arcache;
        arprot_o        =   ic_arprot;
        arqos_o         =   ic_arqos;
        arvalid_o       =   ic_arvalid;

        ic_arready      =   ifu_bus ? 1'b0 : arready_i;
        ic_rvalid       =   ifu_bus ? 1'b0 : rvalid_i;
        ic_rdata        =   rdata_i;
        ic_rresp        =   rresp_i;
        ic_rlast        =   rlast_i;
        ic_rid          =   rid_i;

        rready_o        =   ic_rready;

        exc_valid_o     =   1'b0;
        exc_code_o      =   5'd0;

        case (state)
            IFU_IC_RUN: begin
                uncacheable     =   !pma_cacheable && !pma_fault && !pmp_fault && !flushF_i && resetn_q_i;

                stall_ifu_o     =   !ic_ready;
                instr_o         =   ic_instr;
                instr_valid_o   =   ((ic_instr_valid && pma_cacheable) || pma_fault || pmp_fault) && !flushF_i && resetn_q_i;
                ifu_ready       =   !stallD_i && !uncacheable;

                exc_valid_o     =   (pma_fault || pmp_fault || ic_exc_valid) && !flushF_i && resetn_q_i;
                exc_code_o      =   I_ACC_FAULT;
            end
            IFU_MEM_REQ: begin
                stall_ifu_o     =   !ic_ready;
                instr_o         =   32'h0;
                instr_valid_o   =   1'b0;
                ifu_ready       =   1'b0;

                araddr_o        =   pcF;
                arlen_o         =   8'd0;
                arsize_o        =   SIZE_4B;
                arburst_o       =   INCR;
                arlock_o        =   1'b0;
                arid_o          =   ID_IFU;
                arcache_o       =   CACHE_NONCACHEABLE;
                arprot_o        =   PROT_IFU;
                arqos_o         =   4'b0000;
                arvalid_o       =   1'b1;

                rready_o        =   1'b0;
            end
            IFU_MEM_WAIT: begin
                stall_ifu_o     =   !ic_ready;
                instr_o         =   32'h0;
                instr_valid_o   =   1'b0;
                ifu_ready       =   1'b0;

                arvalid_o       =   1'b0;
                rready_o        =   1'b1;
            end 
            IFU_MEM_DONE: begin
                flush           =   flush_ff || flushF_i;

                stall_ifu_o     =   !ic_ready;
                instr_o         =   instr_hold;
                instr_valid_o   =   !flush;
                ifu_ready       =   !stallD_i || flush;

                exc_valid_o     =   exc_ff && !flush;
                exc_code_o      =   I_ACC_FAULT;
            end
        endcase
    end

endmodule