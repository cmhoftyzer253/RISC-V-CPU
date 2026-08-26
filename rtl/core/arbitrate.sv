import cpu_defines::*;

module arbitrate (
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      lsu_araddr_i,
    input logic [7:0]       lsu_arlen_i,
    input logic [2:0]       lsu_arsize_i,
    input logic [1:0]       lsu_arburst_i,
    input logic             lsu_arlock_i,
    input logic [3:0]       lsu_arid_i,
    input logic [3:0]       lsu_arcache_i,
    input logic [2:0]       lsu_arprot_i,
    input logic [3:0]       lsu_arqos_i,
    input logic             lsu_arvalid_i,
    output logic            lsu_arready_o,

    input logic             lsu_rready_i,
    output logic            lsu_rvalid_o,
    output logic [3:0]      lsu_rid_o,
    output logic [63:0]     lsu_rdata_o,
    output logic [1:0]      lsu_rresp_o,
    output logic            lsu_rlast_o,

    input logic [63:0]      lsu_awaddr_i,
    input logic             lsu_awvalid_i,
    input logic [2:0]       lsu_awsize_i,
    input logic [7:0]       lsu_awlen_i,
    input logic [1:0]       lsu_awburst_i,
    input logic             lsu_awlock_i,
    input logic [3:0]       lsu_awid_i,
    input logic [3:0]       lsu_awcache_i,
    input logic [2:0]       lsu_awprot_i,
    input logic [3:0]       lsu_awqos_i,
    input logic [63:0]      lsu_wdata_i,
    input logic [7:0]       lsu_wstrb_i,
    input logic             lsu_wvalid_i,
    input logic             lsu_wlast_i,
    output logic            lsu_awready_o,
    output logic            lsu_wready_o,

    input logic             lsu_bready_i,
    output logic [1:0]      lsu_bresp_o,
    output logic            lsu_bvalid_o,
    output logic [3:0]      lsu_bid_o,

    input logic [63:0]      ifu_araddr_i,
    input logic [7:0]       ifu_arlen_i,
    input logic [2:0]       ifu_arsize_i,
    input logic [1:0]       ifu_arburst_i,
    input logic             ifu_arlock_i,
    input logic [3:0]       ifu_arid_i,
    input logic [3:0]       ifu_arcache_i,
    input logic [2:0]       ifu_arprot_i,
    input logic [3:0]       ifu_arqos_i,
    input logic             ifu_arvalid_i,
    output logic            ifu_arready_o,

    input logic             ifu_rready_i,
    output logic            ifu_rvalid_o,
    output logic [63:0]     ifu_rdata_o,
    output logic [1:0]      ifu_rresp_o,
    output logic            ifu_rlast_o,
    output logic [3:0]      ifu_rid_o,

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

    logic [2:0]             nxt_grant;
    logic [2:0]             grant_q;
    logic [2:0]             grant;

    logic                   load_done;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            grant_q         <=  GRANT_IDLE;
        end else begin
            if ((grant_q == GRANT_IDLE) || load_done)
                grant_q     <=  nxt_grant;
        end
    end

    always_comb begin
        awaddr_o        =   lsu_awaddr_i;
        awlen_o         =   lsu_awlen_i;
        awsize_o        =   lsu_awsize_i;
        awburst_o       =   lsu_awburst_i;
        awlock_o        =   lsu_awlock_i;
        awid_o          =   lsu_awid_i;
        awcache_o       =   lsu_awcache_i;
        awprot_o        =   lsu_awprot_i;
        awqos_o         =   lsu_awqos_i;
        awvalid_o       =   lsu_awvalid_i;
        lsu_awready_o   =   awready_i;

        wdata_o         =   lsu_wdata_i;
        wstrb_o         =   lsu_wstrb_i;
        wlast_o         =   lsu_wlast_i;
        wvalid_o        =   lsu_wvalid_i;
        lsu_wready_o    =   wready_i;

        bready_o        =   lsu_bready_i;
        lsu_bvalid_o    =   bvalid_i;
        lsu_bresp_o     =   bresp_i;
        lsu_bid_o       =   bid_i;

        nxt_grant       =   lsu_arvalid_i ? GRANT_LSU : (ifu_arvalid_i ? GRANT_IFU : GRANT_IDLE);
        grant           =   (grant_q == GRANT_IDLE) ? nxt_grant : grant_q;

        case (grant)
            GRANT_IFU: begin
                araddr_o        =   ifu_araddr_i;
                arlen_o         =   ifu_arlen_i;
                arsize_o        =   ifu_arsize_i;
                arburst_o       =   ifu_arburst_i;
                arlock_o        =   ifu_arlock_i;
                arid_o          =   ifu_arid_i;
                arcache_o       =   ifu_arcache_i;
                arprot_o        =   ifu_arprot_i;
                arqos_o         =   ifu_arqos_i;
                arvalid_o       =   ifu_arvalid_i;
                rready_o        =   ifu_rready_i;

                ifu_arready_o   =   arready_i;
                ifu_rvalid_o    =   rvalid_i;
                ifu_rid_o       =   rid_i;
                ifu_rdata_o     =   rdata_i;
                ifu_rresp_o     =   rresp_i;
                ifu_rlast_o     =   rlast_i;

                lsu_arready_o   =   1'b0;
                lsu_rvalid_o    =   1'b0;
                lsu_rdata_o     =   64'h0;
                lsu_rresp_o     =   2'b0;
                lsu_rlast_o     =   1'b0;
                lsu_rid_o       =   4'b0;
            end
            GRANT_LSU: begin
                araddr_o        =   lsu_araddr_i;
                arlen_o         =   lsu_arlen_i;
                arsize_o        =   lsu_arsize_i;
                arburst_o       =   lsu_arburst_i;
                arlock_o        =   lsu_arlock_i;
                arid_o          =   lsu_arid_i;
                arcache_o       =   lsu_arcache_i;
                arprot_o        =   lsu_arprot_i;
                arqos_o         =   lsu_arqos_i;
                arvalid_o       =   lsu_arvalid_i;
                rready_o        =   lsu_rready_i;

                lsu_arready_o   =   arready_i;
                lsu_rvalid_o    =   rvalid_i;
                lsu_rid_o       =   rid_i;
                lsu_rdata_o     =   rdata_i;
                lsu_rresp_o     =   rresp_i;
                lsu_rlast_o     =   rlast_i;

                ifu_arready_o   =   1'b0;
                ifu_rvalid_o    =   1'b0;
                ifu_rdata_o     =   64'h0;
                ifu_rresp_o     =   2'b0;
                ifu_rlast_o     =   1'b0;
                ifu_rid_o       =   4'b0;
            end
            default: begin
                araddr_o        =   64'h0;
                arlen_o         =   8'b0;
                arsize_o        =   3'b0;
                arburst_o       =   2'b0;
                arlock_o        =   4'b0;
                arid_o          =   4'b0;
                arcache_o       =   4'b0;
                arprot_o        =   3'b0;
                arqos_o         =   4'b0;
                arvalid_o       =   1'b0;
                rready_o        =   1'b0;

                lsu_arready_o   =   1'b0;
                lsu_rvalid_o    =   1'b0;
                lsu_rid_o       =   4'b0;
                lsu_rdata_o     =   64'h0;
                lsu_rresp_o     =   2'b0;
                lsu_rlast_o     =   1'b0;

                ifu_arready_o   =   1'b0;
                ifu_rvalid_o    =   1'b0;
                ifu_rid_o       =   4'b0;
                ifu_rdata_o     =   64'h0;
                ifu_rresp_o     =   2'b0;
                ifu_rlast_o     =   1'b0;
            end
        endcase

        load_done       =   rvalid_i && rready_o && rlast_i;
    end

endmodule