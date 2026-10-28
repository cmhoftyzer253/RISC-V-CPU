module top (
    input logic             clk_100M_i,
    input logic             resetn_i,

    input logic             uart_rx_i,
    output logic            uart_tx_o,
    inout logic [31:0]      gpio_io,

    output logic [14:0]     ddr3_addr,
    output logic [2:0]      ddr3_ba, 
    output logic            ddr3_cas_n,
    output logic            ddr3_ck_n,
    output logic            ddr3_ck_p,
    output logic            ddr3_cke,
    output logic            ddr3_ras_n,
    output logic            ddr3_reset_n,
    output logic            ddr3_we_n,
    inout logic [15:0]      ddr3_dq,
    inout logic [1:0]       ddr3_dqs_n,
    inout logic [1:0]       ddr3_dqs_p,
    output logic [1:0]      ddr3_dm,
    output logic            ddr3_odt
);

    logic                   clk_100M;
    logic                   clk_200M;
    logic                   clk_cpu;
    logic                   clk_locked;
    logic                   ui_clk;

    logic                   reset_raw;
    logic                   mig_resetn_raw;
    logic                   cpu_resetn;
    logic                   ddr_resetn;

    logic                   ui_clk_sync_rst;
    logic                   init_calib_complete;
    logic                   mmcm_locked;

    logic [63:0]            mtime;
    logic                   mtip;
    logic                   msip;
    logic                   meip;
    logic                   seip;

    logic [63:0]            araddr;
    logic [7:0]             arlen;
    logic [2:0]             arsize;
    logic [1:0]             arburst;
    logic                   arlock;
    logic [3:0]             arid;
    logic [3:0]             arcache;
    logic [2:0]             arprot;
    logic [3:0]             arqos;
    logic                   arvalid;
    logic                   arready;

    logic                   rready;
    logic                   rvalid;
    logic [63:0]            rdata;
    logic [1:0]             rresp;
    logic                   rlast;
    logic [3:0]             rid;

    logic [63:0]            awaddr;
    logic                   awvalid;
    logic [2:0]             awsize;
    logic [7:0]             awlen;
    logic [1:0]             awburst;
    logic                   awlock;
    logic [3:0]             awid;
    logic [3:0]             awcache;
    logic [2:0]             awprot;
    logic [3:0]             awqos;
    logic [63:0]            wdata;
    logic [7:0]             wstrb;
    logic                   wvalid;
    logic                   wlast;
    logic                   awready;
    logic                   wready;

    logic                   bready;
    logic [1:0]             bresp;
    logic                   bvalid;
    logic [3:0]             bid;

    //reset generation
    assign reset_raw        =   !resetn_i || !clk_locked || ui_clk_sync_rst || !init_calib_complete || !mmcm_locked;
    assign mig_resetn_raw   =   resetn_i && clk_locked;

    resetn_sync u_resetn_sync_cpu (
        .clk                    (clk_cpu),
        .aresetn_i              (!reset_raw),
        .resetn_o               (cpu_resetn)
    );

    resetn_sync u_resetn_sync_ddr (
        .clk                    (ui_clk),
        .aresetn_i              (!reset_raw),
        .resetn_o               (ddr_resetn)
    );

    //clock generation
    clk_wiz_0 u_clk_wiz (
        .clk_100M               (clk_100M),
        .clk_200M               (clk_200M),
        .clk_cpu                (clk_cpu),
        .locked                 (clk_locked),
        .clk_in1                (clk_100M_i)
    );

    core u_core (
        .clk                    (clk_cpu),
        .resetn                 (cpu_resetn),
        .mtime_i                (mtime),
        .mtip_i                 (mtip),
        .msip_i                 (msip),
        .meip_i                 (meip),
        .seip_i                 (seip),
        .arready_i              (arready),
        .araddr_o               (araddr),
        .arlen_o                (arlen),
        .arsize_o               (arsize),
        .arburst_o              (arburst),
        .arlock_o               (arlock),
        .arid_o                 (arid),
        .arcache_o              (arcache),
        .arprot_o               (arprot),
        .arqos_o                (arqos),
        .arvalid_o              (arvalid),
        .rvalid_i               (rvalid),
        .rdata_i                (rdata),
        .rresp_i                (rresp),
        .rlast_i                (rlast),
        .rid_i                  (rid),
        .rready_o               (rready),
        .awready_i              (awready),
        .wready_i               (wready),
        .awaddr_o               (awaddr),
        .awvalid_o              (awvalid),
        .awsize_o               (awsize),
        .awlen_o                (awlen),
        .awburst_o              (awburst),
        .awlock_o               (awlock),
        .awid_o                 (awid),
        .awcache_o              (awcache),
        .awprot_o               (awprot),
        .awqos_o                (awqos),
        .wdata_o                (wdata),
        .wstrb_o                (wstrb),
        .wvalid_o               (wvalid),
        .wlast_o                (wlast),
        .bresp_i                (bresp),
        .bvalid_i               (bvalid),
        .bid_i                  (bid),
        .bready_o               (bready)
    );

    bus u_bus (
        .clk                    (clk_cpu),
        .cpu_resetn             (cpu_resetn),
        .ddr_resetn             (ddr_resetn),
        .resetn_raw             (mig_resetn_raw),
        .clk_100M_i             (clk_100M),
        .clk_200M_i             (clk_200M),
        .ui_clk_sync_rst_o      (ui_clk_sync_rst),
        .ui_clk_o               (ui_clk),
        .mtime_o                (mtime),
        .mtip_o                 (mtip),
        .msip_o                 (msip),
        .meip_o                 (meip),
        .seip_o                 (seip),
        .araddr_i               (araddr),
        .arlen_i                (arlen),
        .arsize_i               (arsize),
        .arburst_i              (arburst),
        .arlock_i               (arlock),
        .arid_i                 (arid),
        .arcache_i              (arcache),
        .arprot_i               (arprot),
        .arqos_i                (arqos),
        .arvalid_i              (arvalid),
        .arready_o              (arready),
        .rready_i               (rready),
        .rvalid_o               (rvalid),
        .rdata_o                (rdata),
        .rresp_o                (rresp),
        .rlast_o                (rlast),
        .rid_o                  (rid),
        .awaddr_i               (awaddr),
        .awvalid_i              (awvalid),
        .awsize_i               (awsize),
        .awlen_i                (awlen),
        .awburst_i              (awburst),
        .awlock_i               (awlock),
        .awid_i                 (awid),
        .awcache_i              (awcache),
        .awprot_i               (awprot),
        .awqos_i                (awqos),
        .wdata_i                (wdata),
        .wstrb_i                (wstrb),
        .wvalid_i               (wvalid),
        .wlast_i                (wlast),
        .awready_o              (awready),
        .wready_o               (wready),
        .bready_i               (bready),
        .bresp_o                (bresp),
        .bvalid_o               (bvalid),
        .bid_o                  (bid),
        .ddr3_addr              (ddr3_addr),
        .ddr3_ba                (ddr3_ba),
        .ddr3_cas_n             (ddr3_cas_n),
        .ddr3_ck_n              (ddr3_ck_n),
        .ddr3_ck_p              (ddr3_ck_p),
        .ddr3_cke               (ddr3_cke),
        .ddr3_ras_n             (ddr3_ras_n),
        .ddr3_reset_n           (ddr3_reset_n),
        .ddr3_we_n              (ddr3_we_n),
        .ddr3_dq                (ddr3_dq),
        .ddr3_dqs_n             (ddr3_dqs_n),
        .ddr3_dqs_p             (ddr3_dqs_p),
        .ddr3_dm                (ddr3_dm),
        .ddr3_odt               (ddr3_odt),
        .init_calib_complete_o  (init_calib_complete),
        .mmcm_locked_o          (mmcm_locked),
        .uart_rx_i              (uart_rx_i),
        .uart_tx_o              (uart_tx_o),
        .gpio_io                (gpio_io)
    );

endmodule