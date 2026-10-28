module axi_ctrl
    import cpu_defines::*;
(
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      araddr_i,
    input logic [63:0]      awaddr_i,

    //CPU interface  
    input logic             arvalid_i,
    input logic             rready_i,
    input logic             awvalid_i,
    input logic             wvalid_i,
    input logic             bready_i,

    output logic            arready_o,
    output logic            rvalid_o,
    output logic [63:0]     rdata_o,
    output logic [1:0]      rresp_o,
    output logic            rlast_o,
    output logic [3:0]      rid_o,
    output logic            awready_o,
    output logic            wready_o,
    output logic [1:0]      bresp_o,
    output logic            bvalid_o,
    output logic [3:0]      bid_o,

    //AHB bridge interface
    input logic             ahb_arready_i,
    input logic             ahb_rvalid_i,
    input logic [63:0]      ahb_rdata_i,
    input logic [1:0]       ahb_rresp_i,
    input logic             ahb_rlast_i,
    input logic [3:0]       ahb_rid_i,
    input logic             ahb_awready_i,
    input logic             ahb_wready_i,
    input logic [1:0]       ahb_bresp_i,
    input logic             ahb_valid_i,
    input logic [3:0]       ahb_bid_i,

    output logic            ahb_arvalid_o,
    output logic            ahb_rready_o,
    output logic            ahb_awvalid_o,
    output logic            ahb_wvalid_o,
    output logic            ahb_bready_o,

    //MIG DDR controller interface
    input logic             ddr_arready_i,
    input logic             ddr_rvalid_i,
    input logic [63:0]      ddr_rdata_i,
    input logic [1:0]       ddr_rresp_i,
    input logic             ddr_rlast_i,
    input logic [3:0]       ddr_rid_i,
    input logic             ddr_awready_i,
    input logic             ddr_wready_i,
    input logic [1:0]       ddr_bresp_i,
    input logic             ddr_bvalid_i,
    input logic [3:0]       ddr_bid_i,

    output logic            ddr_arvalid_o,
    output logic            ddr_rready_o,
    output logic            ddr_awvalid_o,
    output logic            ddr_wvalid_o,
    output logic            ddr_bready_o
);

    logic [1:0]             load_grant_q;
    logic [1:0]             store_grant_q;

    logic [1:0]             nxt_load_grant;
    logic [1:0]             nxt_store_grant;

    logic [1:0]             load_grant;
    logic [1:0]             store_grant;

    logic                   set_load_grant;
    logic                   set_store_grant;

    logic                   clear_load_grant;
    logic                   clear_store_grant;

    logic                   ddr_load_addr;
    logic                   ddr_store_addr;

    logic                   ddr_load_sel;
    logic                   ddr_store_sel;

    logic                   ahb_load_sel;
    logic                   ahb_store_sel;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            load_grant_q    <=  BUS_IDLE;
            store_grant_q   <=  BUS_IDLE;
        end else begin
            if (set_load_grant) begin
                load_grant_q    <=  nxt_load_grant;
            end else if (clear_load_grant) begin
                load_grant_q    <=  BUS_IDLE;
            end

            if (set_store_grant) begin
                store_grant_q   <=  nxt_store_grant;
            end else if (clear_store_grant) begin
                store_grant_q   <=  BUS_IDLE;
            end
        end
    end

    always_comb begin
        ddr_store_addr      =   (awaddr_i[63:29] == 35'h0_0000_0004);
        ddr_load_addr       =   (araddr_i[63:29] == 35'h0_0000_0004);

        ddr_load_sel        =   arvalid_i && ddr_load_addr;
        ddr_store_sel       =   awvalid_i && ddr_store_addr;

        ahb_load_sel        =   arvalid_i && !ahb_load_addr;
        ahb_store_sel       =   awvalid_i && !ahb_store_addr;

        nxt_load_grant      =   ddr_load_sel ? GRANT_DDR : (ahb_load_sel ? GRANT_AHB : BUS_IDLE);
        nxt_store_grant     =   ddr_store_sel ? GRANT_DDR : (ahb_store_sel ? GRANT_AHB : BUS_IDLE);

        set_load_grant      =   (load_grant_q == BUS_IDLE) && arvalid_i && arready_o;
        set_store_grant     =   (store_grant_q == BUS_IDLE) && awvalid_i && awready_o;

        clear_load_grant    =   rready_i && rvalid_o && rlast_o;
        clear_store_grant   =   bvalid_o && bready_i;

        load_grant          =   (load_grant_q == BUS_IDLE) ? nxt_load_grant : load_grant_q;
        store_grant         =   (store_grant_q == BUS_IDLE) ? nxt_store_grant : store_grant_q;

        ahb_arvalid_o = 1'b0;
        ahb_rready_o = 1'b0;
        ahb_awvalid_o = 1'b0;
        ahb_wvalid_o = 1'b0;
        ahb_bready_o = 1'b0;

        ddr_arvalid_o = 1'b0;
        ddr_rready_o = 1'b0;
        ddr_awvalid_o = 1'b0;
        ddr_wvalid_o = 1'b0;
        ddr_bready_o = 1'b0;

        arready_o = 1'b0;
        rvalid_o = 1'b0;
        rdata_o = 64'h0;
        rresp_o = 2'b0;
        rlast_o = 1'b0;
        rid_o = 4'b0;

        awready_o = 1'b0;
        wready_o = 1'b0;
        bresp_o = 2'b0;
        bvalid_o = 1'b0;
        bid_o = 4'b0;

        case (load_grant)
            GRANT_DDR: begin
                ddr_arvalid_o   =   arvalid_i;
                ddr_rready_o    =   rready_i;
                arready_o       =   ddr_arready_i;
                rvalid_o        =   ddr_rvalid_i;
                rdata_o         =   ddr_rdata_i;
                rresp_o         =   ddr_rresp_i;
                rlast_o         =   ddr_rlast_i;
                rid_o           =   ddr_rid_i;
            end
            GRANT_AHB: begin
                ahb_arvalid_o   =   arvalid_i;
                ahb_rready_o    =   rready_i;
                arready_o       =   ahb_arready_i;
                rvalid_o        =   ahb_rvalid_i;
                rdata_o         =   ahb_rdata_i;
                rresp_o         =   ahb_rresp_i;
                rlast_o         =   ahb_rlast_i;
                rid_o           =   ahb_rid_i;
            end
        endcase

        case (store_grant)
            GRANT_DDR: begin
                ddr_awvalid_o = awvalid_i;
                ddr_wvalid_o = wvalid_i;
                ddr_bready_o = bready_i;
                awready_o = ddr_awready_i;
                wready_o = ddr_wready_i;
                bresp_o = ddr_bresp_i;
                bvalid_o = ddr_bvalid_i;
                bid_o = ddr_bid_i;
            end
            GRANT_AHB: begin
                ahb_awvalid_o = awvalid_i;
                ahb_wvalid_o = wvalid_i;
                ahb_bready_o = bready_i;
                awready_o = ahb_awready_i;
                wready_o = ahb_wready_i;
                bresp_o = ahb_bresp_i;
                bvalid_o = ahb_valid_i;
                bid_o = ahb_bid_i;
            end
        endcase

    end

endmodule