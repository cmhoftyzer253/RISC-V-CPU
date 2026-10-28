module bus (
    input logic             clk,
    input logic             cpu_resetn,
    input logic             ddr_resetn, 
    input logic             resetn_raw,

    input logic             clk_100M_i,
    input logic             clk_200M_i,

    output logic            ui_clk_sync_rst_o,
    output logic            ui_clk_o,

    output logic [63:0]     mtime_o,
    output logic            mtip_o,
    output logic            msip_o,
    output logic            meip_o,
    output logic            seip_o,

    input logic [63:0]      araddr_i,
    input logic [7:0]       arlen_i,
    input logic [2:0]       arsize_i,
    input logic [1:0]       arburst_i,
    input logic             arlock_i,
    input logic [3:0]       arid_i,
    input logic [3:0]       arcache_i,
    input logic [2:0]       arprot_i,
    input logic [3:0]       arqos_i,
    input logic             arvalid_i,
    output logic            arready_o,

    input logic             rready_i,
    output logic            rvalid_o,
    output logic [63:0]     rdata_o,
    output logic [1:0]      rresp_o,
    output logic            rlast_o,
    output logic [3:0]      rid_o,

    input logic [63:0]      awaddr_i,
    input logic             awvalid_i,
    input logic [2:0]       awsize_i,
    input logic [7:0]       awlen_i,
    input logic [1:0]       awburst_i,
    input logic             awlock_i,
    input logic [3:0]       awid_i,
    input logic [3:0]       awcache_i,
    input logic [2:0]       awprot_i,
    input logic [3:0]       awqos_i,
    input logic [63:0]      wdata_i,
    input logic [7:0]       wstrb_i,
    input logic             wvalid_i,
    input logic             wlast_i,
    output logic            awready_o,
    output logic            wready_o,

    input logic             bready_i,
    output logic [1:0]      bresp_o,
    output logic            bvalid_o,
    output logic [3:0]      bid_o,

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
    output logic            ddr3_odt,

    output logic            init_calib_complete_o,
    output logic            mmcm_locked_o,
    
    input logic             uart_rx_i,
    output logic            uart_tx_o,

    inout logic [31:0]      gpio_io
);

    logic                   ui_clk;
    logic                   ui_clk_sync_rst;
    logic                   init_calib_complete;
    logic                   mmcm_locked;

    logic                   ahb_arready;
    logic                   ahb_rvalid;
    logic [63:0]            ahb_rdata;
    logic [1:0]             ahb_rresp;
    logic                   ahb_rlast;
    logic [3:0]             ahb_rid;
    logic                   ahb_awready;
    logic                   ahb_wready;
    logic [1:0]             ahb_bresp;
    logic                   ahb_bvalid;
    logic [3:0]             ahb_bid;
    logic                   ahb_arvalid;
    logic                   ahb_rready;
    logic                   ahb_awvalid;
    logic                   ahb_wvalid;
    logic                   ahb_bready;

    logic                   ddr_arready;
    logic                   ddr_rvalid;
    logic [63:0]            ddr_rdata;
    logic [1:0]             ddr_rresp;
    logic                   ddr_rlast;
    logic [3:0]             ddr_rid;
    logic                   ddr_awready;
    logic                   ddr_wready;
    logic [1:0]             ddr_bresp;
    logic                   ddr_bvalid;
    logic [3:0]             ddr_bid;
    logic                   ddr_arvalid;
    logic                   ddr_rready;
    logic                   ddr_awvalid;
    logic                   ddr_wvalid;
    logic                   ddr_bready;

    logic [3:0]             m_ddr_awid;
    logic [63:0]            m_ddr_awaddr;
    logic [7:0]             m_ddr_awlen;
    logic [2:0]             m_ddr_awsize;
    logic [1:0]             m_ddr_awburst;
    logic                   m_ddr_awlock;
    logic [3:0]             m_ddr_awcache;
    logic [2:0]             m_ddr_awprot;
    logic [3:0]             m_ddr_awqos;
    logic                   m_ddr_awvalid;
    logic                   m_ddr_awready;

    logic [63:0]            m_ddr_wdata;
    logic [7:0]             m_ddr_wstrb;
    logic                   m_ddr_wlast;
    logic                   m_ddr_wvalid;
    logic                   m_ddr_wready;

    logic [3:0]             m_ddr_bid;
    logic [1:0]             m_ddr_bresp;
    logic                   m_ddr_bvalid;
    logic                   m_ddr_bready;

    logic [3:0]             m_ddr_arid;
    logic [63:0]            m_ddr_araddr;
    logic [7:0]             m_ddr_arlen;
    logic [2:0]             m_ddr_arsize;
    logic [1:0]             m_ddr_arburst;
    logic                   m_ddr_arlock;
    logic [3:0]             m_ddr_arcache;
    logic [2:0]             m_ddr_arprot;
    logic [3:0]             m_ddr_arqos;
    logic                   m_ddr_arvalid;
    logic                   m_ddr_arready;

    logic [3:0]             m_ddr_rid;
    logic [63:0]            m_ddr_rdata;
    logic [1:0]             m_ddr_rresp;
    logic                   m_ddr_rlast;
    logic                   m_ddr_rvalid;
    logic                   m_ddr_rready;

    logic [63:0]            haddr;
    logic                   hwrite;
    logic [2:0]             hsize;
    logic [2:0]             hburst;
    logic [3:0]             hprot;
    logic [1:0]             htrans;
    logic [63:0]            hwdata;
    logic                   hready;
    logic [63:0]            hrdata;
    logic                   hresp;

    logic [5:0]             hsel;
    logic [5:0]             hready_out;
    logic [5:0]             hresp_out;
    logic [63:0]            hrdata_out [5:0];

    logic                   uart_interrupt;
    logic                   spi_interrupt;
    logic                   gpio_interrupt;

    logic [31:0]            gpio_in;
    logic [31:0]            gpio_out;
    logic [31:0]            gpio_out_en;
    logic [31:0]            iof_en;
    logic [31:0]            iof_sel;

    logic                   spi_sck;
    logic                   spi_sdo;
    logic                   spi_sdi;
    logic [3:0]             spi_cs;

    axi_ctrl u_axi_ctrl (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .araddr_i               (araddr_i),
        .awaddr_i               (awaddr_i),
        .arvalid_i              (arvalid_i),      
        .rready_i               (rready_i),
        .awvalid_i              (awvalid_i),
        .wvalid_i               (wvalid_i),
        .bready_i               (bready_i),
        .arready_o              (arready_o),
        .rvalid_o               (rvalid_o),
        .rdata_o                (rdata_o),
        .rresp_o                (rresp_o),
        .rlast_o                (rlast_o),
        .rid_o                  (rid_o),
        .awready_o              (awready_o),
        .wready_o               (wready_o),
        .bresp_o                (bresp_o),
        .bvalid_o               (bvalid_o),
        .bid_o                  (bid_o),
        .ahb_arready_i          (ahb_arready),
        .ahb_rvalid_i           (ahb_rvalid),
        .ahb_rdata_i            (ahb_rdata),
        .ahb_rresp_i            (ahb_rresp),
        .ahb_rlast_i            (ahb_rlast),
        .ahb_rid_i              (ahb_rid),
        .ahb_awready_i          (ahb_awready),
        .ahb_wready_i           (ahb_wready),
        .ahb_bresp_i            (ahb_bresp),
        .ahb_bvalid_i           (ahb_bvalid),
        .ahb_bid_i              (ahb_bid),
        .ahb_arvalid_o          (ahb_arvalid),
        .ahb_rready_o           (ahb_rready),
        .ahb_awvalid_o          (ahb_awvalid),
        .ahb_wvalid_o           (ahb_wvalid),
        .ahb_bready_o           (ahb_bready),
        .ddr_arready_i          (ddr_arready),
        .ddr_rvalid_i           (ddr_rvalid),
        .ddr_rdata_i            (ddr_rdata),
        .ddr_rresp_i            (ddr_rresp),
        .ddr_rlast_i            (ddr_rlast),
        .ddr_rid_i              (ddr_rid),
        .ddr_awready_i          (ddr_awready),
        .ddr_wready_i           (ddr_wready),
        .ddr_bresp_i            (ddr_bresp),
        .ddr_bvalid_i           (ddr_bvalid),
        .ddr_bid_i              (ddr_bid),
        .ddr_arvalid_o          (ddr_arvalid),
        .ddr_rready_o           (ddr_rready),
        .ddr_awvalid_o          (ddr_awvalid),
        .ddr_wvalid_o           (ddr_wvalid),
        .ddr_bready_o           (ddr_bready)
    );

    //S: CPU clock domain
    //M: MIG DDR clock domain
    axi_clock_converter_0 u_axi_clock_converter (
        .s_axi_aclk             (clk),
        .s_axi_aresetn          (cpu_resetn),
        .s_axi_awid             (awid_i),
        .s_axi_awaddr           (awaddr_i),
        .s_axi_awlen            (awlen_i),
        .s_axi_awsize           (awsize_i),
        .s_axi_awburst          (awburst_i),
        .s_axi_awlock           (awlock_i),
        .s_axi_awcache          (awcache_i),
        .s_axi_awprot           (awprot_i),
        .s_axi_awregion         (4'b0000),
        .s_axi_awqos            (awqos_i),
        .s_axi_awvalid          (ddr_awvalid),
        .s_axi_awready          (ddr_awready),
        .s_axi_wdata            (wdata_i),
        .s_axi_wstrb            (wstrb_i),
        .s_axi_wlast            (wlast_i),
        .s_axi_wvalid           (ddr_wvalid),
        .s_axi_wready           (ddr_wready),
        .s_axi_bid              (ddr_bid),
        .s_axi_bresp            (ddr_bresp),
        .s_axi_bvalid           (ddr_bvalid),
        .s_axi_bready           (ddr_bready),
        .s_axi_arid             (arid_i),
        .s_axi_araddr           (araddr_i),
        .s_axi_arlen            (arlen_i),
        .s_axi_arsize           (arsize_i),
        .s_axi_arburst          (arburst_i),
        .s_axi_arlock           (arlock_i),
        .s_axi_arcache          (arcache_i),
        .s_axi_arprot           (arprot_i),
        .s_axi_arregion         (4'b0000),
        .s_axi_arqos            (arqos_i),
        .s_axi_arvalid          (ddr_arvalid),
        .s_axi_arready          (ddr_arready),
        .s_axi_rid              (ddr_rid),
        .s_axi_rdata            (ddr_rdata),
        .s_axi_rresp            (ddr_rresp),
        .s_axi_rlast            (ddr_rlast),
        .s_axi_rvalid           (ddr_rvalid),
        .s_axi_rready           (ddr_rready),
        .m_axi_aclk             (ui_clk),
        .m_axi_aresetn          (ddr_resetn),
        .m_axi_awid             (m_ddr_awid),
        .m_axi_awaddr           (m_ddr_awaddr),
        .m_axi_awlen            (m_ddr_awlen),
        .m_axi_awsize           (m_ddr_awsize),
        .m_axi_awburst          (m_ddr_awburst),
        .m_axi_awlock           (m_ddr_awlock),
        .m_axi_awcache          (m_ddr_awcache),
        .m_axi_awprot           (m_ddr_awprot),
        .m_axi_awregion         (),
        .m_axi_awqos            (m_ddr_awqos),
        .m_axi_awvalid          (m_ddr_awvalid),
        .m_axi_awready          (m_ddr_awready),
        .m_axi_wdata            (m_ddr_wdata),
        .m_axi_wstrb            (m_ddr_wstrb),
        .m_axi_wlast            (m_ddr_wlast),
        .m_axi_wvalid           (m_ddr_wvalid),
        .m_axi_wready           (m_ddr_wready),
        .m_axi_bid              (m_ddr_bid),
        .m_axi_bresp            (m_ddr_bresp),
        .m_axi_bvalid           (m_ddr_bvalid),
        .m_axi_bready           (m_ddr_bready),
        .m_axi_arid             (m_ddr_arid),
        .m_axi_araddr           (m_ddr_araddr),
        .m_axi_arlen            (m_ddr_arlen),
        .m_axi_arsize           (m_ddr_arsize),
        .m_axi_arburst          (m_ddr_arburst),
        .m_axi_arlock           (m_ddr_arlock),
        .m_axi_arcache          (m_ddr_arcache),
        .m_axi_arprot           (m_ddr_arprot),
        .m_axi_arregion         (),
        .m_axi_arqos            (m_ddr_arqos),
        .m_axi_arvalid          (m_ddr_arvalid),
        .m_axi_arready          (m_ddr_arready),
        .m_axi_rid              (m_ddr_rid),
        .m_axi_rdata            (m_ddr_rdata),
        .m_axi_rresp            (m_ddr_rresp),
        .m_axi_rlast            (m_ddr_rlast),
        .m_axi_rvalid           (m_ddr_rvalid),
        .m_axi_rready           (m_ddr_rready)
    );

    ddr_mig_controller u_ddr_mig_controller (
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
        .init_calib_complete    (init_calib_complete),
        .ddr3_dm                (ddr3_dm),
        .ddr3_odt               (ddr3_odt),
        .ui_clk                 (ui_clk),
        .ui_clk_sync_rst        (ui_clk_sync_rst),
        .mmcm_locked            (mmcm_locked),
        .aresetn                (ddr_resetn),
        .app_sr_req             (1'b0),
        .app_ref_req            (1'b0),
        .app_zq_req             (1'b0),
        .app_sr_active          (),
        .app_ref_ack            (),
        .app_zq_ack             (),
        .s_axi_awid             (m_ddr_awid),
        .s_axi_awaddr           (m_ddr_awaddr),
        .s_axi_awlen            (m_ddr_awlen),
        .s_axi_awsize           (m_ddr_awsize),
        .s_axi_awburst          (m_ddr_awburst),
        .s_axi_awlock           (m_ddr_awlock),
        .s_axi_awcache          (m_ddr_awcache),
        .s_axi_awprot           (m_ddr_awprot),
        .s_axi_awqos            (m_ddr_awqos),
        .s_axi_awvalid          (m_ddr_awvalid),
        .s_axi_awready          (m_ddr_awready),
        .s_axi_wdata            (m_ddr_wdata),
        .s_axi_wstrb            (m_ddr_wstrb),
        .s_axi_wlast            (m_ddr_wlast),
        .s_axi_wvalid           (m_ddr_wvalid),
        .s_axi_wready           (m_ddr_wready),
        .s_axi_bid              (m_ddr_bid),
        .s_axi_bresp            (m_ddr_bresp),
        .s_axi_bvalid           (m_ddr_bvalid),
        .s_axi_bready           (m_ddr_bready),
        .s_axi_arid             (m_ddr_arid),
        .s_axi_araddr           (m_ddr_araddr),
        .s_axi_arlen            (m_ddr_arlen),
        .s_axi_arsize           (m_ddr_arsize),
        .s_axi_arburst          (m_ddr_arburst),
        .s_axi_arlock           (m_ddr_arlock),
        .s_axi_arcache          (m_ddr_arcache),
        .s_axi_arprot           (m_ddr_arprot),
        .s_axi_arqos            (m_ddr_arqos),
        .s_axi_arvalid          (m_ddr_arvalid),
        .s_axi_arready          (m_ddr_arready),
        .s_axi_rid              (m_ddr_rid),
        .s_axi_rdata            (m_ddr_rdata),
        .s_axi_rresp            (m_ddr_rresp),
        .s_axi_rlast            (m_ddr_rlast),
        .s_axi_rvalid           (m_ddr_rvalid),
        .s_axi_rready           (m_ddr_rready),
        .sys_clk_i              (clk_100M_i),
        .clk_ref_i              (clk_200M_i),
        .sys_rst                (resetn_raw)
    );

    assign ui_clk_o                 =   ui_clk;
    assign ui_clk_sync_rst_o        =   ui_clk_sync_rst;
    assign init_calib_complete_o    =   init_calib_complete;
    assign mmcm_locked_o            =   mmcm_locked;

    axi_ahblite_bridge_0 u_axi_ahblite_bridge (
        .s_axi_aclk             (clk),
        .s_axi_aresetn          (cpu_resetn),
        .s_axi_awid             (awid_i),
        .s_axi_awlen            (awlen_i),
        .s_axi_awsize           (awsize_i),
        .s_axi_awburst          (awburst_i),
        .s_axi_awcache          (awcache_i),
        .s_axi_awaddr           (awaddr_i),
        .s_axi_awprot           (awprot_i),
        .s_axi_awvalid          (ahb_awvalid),
        .s_axi_awready          (ahb_awready),
        .s_axi_awlock           (awlock_i),
        .s_axi_wdata            (wdata_i),
        .s_axi_wstrb            (wstrb_i),
        .s_axi_wlast            (wlast_i),
        .s_axi_wvalid           (ahb_wvalid),
        .s_axi_wready           (ahb_wready),
        .s_axi_bid              (ahb_bid),
        .s_axi_bresp            (ahb_bresp),
        .s_axi_bvalid           (ahb_bvalid),
        .s_axi_bready           (ahb_bready),
        .s_axi_arid             (arid_i),
        .s_axi_araddr           (araddr_i),
        .s_axi_arprot           (arprot_i),
        .s_axi_arcache          (arcache_i),
        .s_axi_arvalid          (ahb_arvalid),
        .s_axi_arlen            (arlen_i),
        .s_axi_arsize           (arsize_i),
        .s_axi_arburst          (arburst_i),
        .s_axi_arlock           (arlock_i),
        .s_axi_arready          (ahb_arready),
        .s_axi_rid              (ahb_rid),
        .s_axi_rdata            (ahb_rdata),
        .s_axi_rresp            (ahb_rresp),
        .s_axi_rvalid           (ahb_rvalid),
        .s_axi_rlast            (ahb_rlast),
        .s_axi_rready           (ahb_rready),
        .m_ahb_haddr            (haddr),
        .m_ahb_hwrite           (hwrite),
        .m_ahb_hsize            (hsize),
        .m_ahb_hburst           (hburst),
        .m_ahb_hprot            (hprot),
        .m_ahb_htrans           (htrans),
        .m_ahb_hmastlock        (),
        .m_ahb_hwdata           (hwdata),
        .m_ahb_hready           (hready),
        .m_ahb_hrdata           (hrdata),
        .m_ahb_hresp            (hresp)
    );

    ahb_ctrl u_ahb_ctrl (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .haddr_i                (haddr),
        .hreadyout_i            (hready_out),
        .hrdata_i               (hrdata_out),
        .hresp_i                (hresp_out),
        .hsel_o                 (hsel),
        .hready_o               (hready),
        .hrdata_o               (hrdata),
        .hresp_o                (hresp)
    );

    ahb_boot_rom u_ahb_boot_rom (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .hsel_i                 (hsel[0]),
        .hready_i               (hready),
        .haddr_i                (haddr),
        .htrans_i               (htrans),
        .hwrite_i               (hwrite),
        .hsize_i                (hsize),
        .hburst_i               (hburst),
        .hwdata_i               (hwdata),
        .hrdata_o               (hrdata_out[0]),
        .hreadyout_o            (hready_out[0]),
        .hresp_o                (hresp_out[0])
    );

    clint u_clint (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .mtime_o                (mtime_o),
        .mtip_o                 (mtip_o),
        .msip_o                 (msip_o),
        .hsel_i                 (hsel[1]),
        .hready_i               (hready),
        .haddr_i                (haddr),
        .htrans_i               (htrans),
        .hwrite_i               (hwrite),
        .hsize_i                (hsize),
        .hburst_i               (hburst),
        .hwdata_i               (hwdata),
        .hrdata_o               (hrdata_out[1]),
        .hreadyout_o            (hready_out[1]),
        .hresp_o                (hresp_out[1])
    );

    plic u_plic (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .hsel_i                 (hsel[2]),
        .hready_i               (hready),
        .haddr_i                (haddr),
        .htrans_i               (htrans),
        .hwrite_i               (hwrite),
        .hsize_i                (hsize),
        .hburst_i               (hburst),
        .hwdata_i               (hwdata),
        .hrdata_o               (hrdata_out[2]),
        .hreadyout_o            (hready_out[2]),
        .hresp_o                (hresp_out[2]),
        .uart_interrupt_i       (uart_interrupt),
        .spi_interrupt_i        (spi_interrupt),
        .gpio_interrupt_i       (gpio_interrupt),
        .meip_o                 (meip_o),
        .seip_o                 (seip_o)
    );

    uart u_uart (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .hsel_i                 (hsel[3]),
        .hready_i               (hready),
        .haddr_i                (haddr),
        .htrans_i               (htrans),
        .hwrite_i               (hwrite),
        .hsize_i                (hsize),
        .hburst_i               (hburst),
        .hwdata_i               (hwdata),
        .hrdata_o               (hrdata_out[3]),
        .hreadyout_o            (hready_out[3]),
        .hresp_o                (hresp_out[3]),
        .rx_i                   (uart_rx_i),
        .tx_o                   (uart_tx_o),
        .uart_interrupt_o       (uart_interrupt)
    );

    spi u_spi (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .hsel_i                 (hsel[4]),
        .hready_i               (hready),
        .haddr_i                (haddr),
        .htrans_i               (htrans),
        .hwrite_i               (hwrite),
        .hsize_i                (hsize),
        .hburst_i               (hburst),
        .hwdata_i               (hwdata),
        .hrdata_o               (hrdata_out[4]),
        .hreadyout_o            (hready_out[4]),
        .hresp_o                (hresp_out[4]),
        .sck_o                  (spi_sck),
        .sdo_o                  (spi_sdo),
        .sdi_i                  (spi_sdi),
        .cs_o                   (spi_cs),
        .spi_interrupt_o        (spi_interrupt)
    );

    gpio u_gpio (
        .clk                    (clk),
        .resetn                 (cpu_resetn),
        .gpio_in_i              (gpio_in),
        .gpio_out_o             (gpio_out),
        .gpio_out_en_o          (gpio_out_en),
        .hsel_i                 (hsel[5]),
        .hready_i               (hready),
        .haddr_i                (haddr),
        .htrans_i               (htrans),
        .hwrite_i               (hwrite),
        .hsize_i                (hsize),
        .hburst_i               (hburst),
        .hwdata_i               (hwdata),
        .hrdata_o               (hrdata_out[5]),
        .hreadyout_o            (hready_out[5]),
        .hresp_o                (hresp_out[5]),
        .iof_en_o               (iof_en),
        .iof_sel_o              (iof_sel),
        .gpio_interrupt_o       (gpio_interrupt)
    );

    pin_arbitrate u_pin_arbitrate (
        .gpio_io                (gpio_io),
        .iof_en_i               (iof_en),
        .iof_sel_i              (iof_sel),
        .gpio_out_en_i          (gpio_out_en),
        .gpio_out_i             (gpio_out),
        .gpio_in_o              (gpio_in),
        .spi_sck_i              (spi_sck),
        .spi_sdo_i              (spi_sdo),
        .spi_sdi_o              (spi_sdi),
        .spi_cs_i               (spi_cs)
    );

endmodule