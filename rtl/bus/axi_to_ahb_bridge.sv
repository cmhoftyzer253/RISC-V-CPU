//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
axi_ahblite_bridge_0 your_instance_name (
  .s_axi_aclk(s_axi_aclk),            // input wire s_axi_aclk
  .s_axi_aresetn(s_axi_aresetn),      // input wire s_axi_aresetn
  .s_axi_awid(s_axi_awid),            // input wire [3 : 0] s_axi_awid
  .s_axi_awlen(s_axi_awlen),          // input wire [7 : 0] s_axi_awlen
  .s_axi_awsize(s_axi_awsize),        // input wire [2 : 0] s_axi_awsize
  .s_axi_awburst(s_axi_awburst),      // input wire [1 : 0] s_axi_awburst
  .s_axi_awcache(s_axi_awcache),      // input wire [3 : 0] s_axi_awcache
  .s_axi_awaddr(s_axi_awaddr),        // input wire [63 : 0] s_axi_awaddr
  .s_axi_awprot(s_axi_awprot),        // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid(s_axi_awvalid),      // input wire s_axi_awvalid
  .s_axi_awready(s_axi_awready),      // output wire s_axi_awready
  .s_axi_awlock(s_axi_awlock),        // input wire s_axi_awlock
  .s_axi_wdata(s_axi_wdata),          // input wire [63 : 0] s_axi_wdata
  .s_axi_wstrb(s_axi_wstrb),          // input wire [7 : 0] s_axi_wstrb
  .s_axi_wlast(s_axi_wlast),          // input wire s_axi_wlast
  .s_axi_wvalid(s_axi_wvalid),        // input wire s_axi_wvalid
  .s_axi_wready(s_axi_wready),        // output wire s_axi_wready
  .s_axi_bid(s_axi_bid),              // output wire [3 : 0] s_axi_bid
  .s_axi_bresp(s_axi_bresp),          // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(s_axi_bvalid),        // output wire s_axi_bvalid
  .s_axi_bready(s_axi_bready),        // input wire s_axi_bready
  .s_axi_arid(s_axi_arid),            // input wire [3 : 0] s_axi_arid
  .s_axi_araddr(s_axi_araddr),        // input wire [63 : 0] s_axi_araddr
  .s_axi_arprot(s_axi_arprot),        // input wire [2 : 0] s_axi_arprot
  .s_axi_arcache(s_axi_arcache),      // input wire [3 : 0] s_axi_arcache
  .s_axi_arvalid(s_axi_arvalid),      // input wire s_axi_arvalid
  .s_axi_arlen(s_axi_arlen),          // input wire [7 : 0] s_axi_arlen
  .s_axi_arsize(s_axi_arsize),        // input wire [2 : 0] s_axi_arsize
  .s_axi_arburst(s_axi_arburst),      // input wire [1 : 0] s_axi_arburst
  .s_axi_arlock(s_axi_arlock),        // input wire s_axi_arlock
  .s_axi_arready(s_axi_arready),      // output wire s_axi_arready
  .s_axi_rid(s_axi_rid),              // output wire [3 : 0] s_axi_rid
  .s_axi_rdata(s_axi_rdata),          // output wire [63 : 0] s_axi_rdata
  .s_axi_rresp(s_axi_rresp),          // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid(s_axi_rvalid),        // output wire s_axi_rvalid
  .s_axi_rlast(s_axi_rlast),          // output wire s_axi_rlast
  .s_axi_rready(s_axi_rready),        // input wire s_axi_rready
  .m_ahb_haddr(m_ahb_haddr),          // output wire [63 : 0] m_ahb_haddr
  .m_ahb_hwrite(m_ahb_hwrite),        // output wire m_ahb_hwrite
  .m_ahb_hsize(m_ahb_hsize),          // output wire [2 : 0] m_ahb_hsize
  .m_ahb_hburst(m_ahb_hburst),        // output wire [2 : 0] m_ahb_hburst
  .m_ahb_hprot(m_ahb_hprot),          // output wire [3 : 0] m_ahb_hprot
  .m_ahb_htrans(m_ahb_htrans),        // output wire [1 : 0] m_ahb_htrans
  .m_ahb_hmastlock(m_ahb_hmastlock),  // output wire m_ahb_hmastlock
  .m_ahb_hwdata(m_ahb_hwdata),        // output wire [63 : 0] m_ahb_hwdata
  .m_ahb_hready(m_ahb_hready),        // input wire m_ahb_hready
  .m_ahb_hrdata(m_ahb_hrdata),        // input wire [63 : 0] m_ahb_hrdata
  .m_ahb_hresp(m_ahb_hresp)          // input wire m_ahb_hresp
);
// INST_TAG_END ------ End INSTANTIATION Template ---------