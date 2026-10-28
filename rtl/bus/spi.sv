module spi 
    import cpu_defines::*;
(
    input logic             clk,
    input logic             resetn,

    input logic             hsel_i,
    input logic             hready_i,

    input logic [63:0]      haddr_i,
    input logic [1:0]       htrans_i,
    input logic             hwrite_i,
    input logic [2:0]       hsize_i,
    input logic [2:0]       hburst_i,

    input logic [63:0]      hwdata_i,

    output logic [63:0]     hrdata_o,
    output logic            hreadyout_o,
    output logic            hresp_o,

    //spi output interface
    output logic            sck_o,
    output logic            sdo_o,
    input logic             sdi_i,
    output logic [3:0]      cs_o,

    output logic            spi_interrupt_o
);

    logic                   ahb_advance;
    logic                   hvalid_d;
    logic                   hwrite_en;

    logic [3:0]             txmark;
    logic [3:0]             rxmark;
    logic                   tx_wm_ip;
    logic                   rx_wm_ip;
    
    logic                   hsel_d;
    logic [11:0]            haddr_d;
    logic [1:0]             htrans_d;
    logic                   hwrite_d;

    logic [7:0]             cssck;
    logic [7:0]             sckcs;
    logic [7:0]             intercs;
    logic [7:0]             interxfr;
    logic                   endian;
    logic                   dir;
    logic [3:0]             len;

    logic                   tx_fifo_push;
    logic [7:0]             tx_fifo_push_data;
    logic                   tx_fifo_pop;
    logic [7:0]             tx_fifo_pop_data;
    logic                   tx_fifo_full;
    logic                   tx_fifo_empty;
    logic [3:0]             tx_fifo_count;

    logic                   rx_fifo_push;
    logic [7:0]             rx_fifo_push_data;
    logic                   rx_fifo_pop;
    logic [7:0]             rx_fifo_pop_data;
    logic                   rx_fifo_empty;
    logic [3:0]             rx_fifo_count;

    logic [11:0]            SCKDIV_REG;
    logic [1:0]             SCKMODE_REG;
    logic [1:0]             CSID_REG;
    logic [3:0]             CSDEF_REG;
    logic [1:0]             CSMODE_REG;
    logic [23:0]            DELAY0_REG;
    logic [23:0]            DELAY1_REG;
    logic [19:0]            FMT_REG;
    logic [2:0]             TXMARK_REG;
    logic [2:0]             RXMARK_REG;
    logic [1:0]             IE_REG;

    logic [31:0]            SCKDIV_RD;
    logic [31:0]            SCKMODE_RD;
    logic [31:0]            CSID_RD;
    logic [31:0]            CSDEF_RD;
    logic [31:0]            CSMODE_RD;
    logic [31:0]            DELAY0_RD;
    logic [31:0]            DELAY1_RD;
    logic [31:0]            FMT_RD;
    logic [31:0]            TXDATA_RD;
    logic [31:0]            RXDATA_RD;
    logic [31:0]            TXMARK_RD;
    logic [31:0]            RXMARK_RD;
    logic [31:0]            IE_RD;
    logic [31:0]            IP_RD;

    fifo #(
        .WIDTH                  (8),
        .DEPTH                  (8)
    ) u_tx_fifo (
        .clk                    (clk),
        .resetn                 (resetn),
        .wr_en_i                (tx_fifo_push),
        .wr_data_i              (tx_fifo_push_data),
        .rd_en_i                (tx_fifo_pop),
        .rd_data_o              (tx_fifo_pop_data),
        .full_o                 (tx_fifo_full),
        .empty_o                (tx_fifo_empty),
        .count_o                (tx_fifo_count)
    );

    fifo #(
        .WIDTH                  (8),
        .DEPTH                  (8)
    ) u_rx_fifo (
        .clk                    (clk),
        .resetn                 (resetn),
        .wr_en_i                (rx_fifo_push),
        .wr_data_i              (rx_fifo_push_data),
        .rd_en_i                (rx_fifo_pop),
        .rd_data_o              (rx_fifo_pop_data),
        .full_o                 (),
        .empty_o                (rx_fifo_empty),
        .count_o                (rx_fifo_count)
    );

    spi_tx u_spi_tx (
        .clk                    (clk),
        .resetn                 (resetn),
        .div_i                  (SCKDIV_REG),
        .sckmode_i              (SCKMODE_REG),
        .csid_i                 (CSID_REG),
        .csdef_i                (CSDEF_REG),
        .csmode_i               (CSMODE_REG),
        .cssck_i                (cssck),
        .sckcs_i                (sckcs),
        .intercs_i              (intercs),
        .interxfr_i             (interxfr),
        .endian_i               (endian),
        .dir_i                  (dir),
        .len_i                  (len),
        .rx_fifo_push_o         (rx_fifo_push),
        .rx_fifo_push_data_o    (rx_fifo_push_data),
        .tx_fifo_empty_i        (tx_fifo_empty),
        .tx_fifo_pop_o          (tx_fifo_pop),
        .tx_fifo_pop_data_i     (tx_fifo_pop_data),
        .sck_o                  (sck_o),
        .sdo_o                  (sdo_o),
        .sdi_i                  (sdi_i),
        .cs_o                   (cs_o)
    );

    //register writes
    always_ff @(posedge clk) begin
        if (!resetn) begin
            SPI_SCKDIV_REG      <=  12'h003;
            SPI_SCKMODE_REG     <=  2'b0;
            SPI_CSID_REG        <=  2'b0;
            SPI_CSDEF_REG       <=  4'hF;
            SPI_CSMODE_REG      <=  AUTO;
            SPI_DELAY0_REG      <=  24'h010001;
            SPI_DELAY1_REG      <=  24'h000001;
            SPI_FMT_REG         <=  20'h80000;
            SPI_TXMARK_REG      <=  3'b0;
            SPI_RXMARK_REG      <=  3'b0;
            SPI_IE_REG          <=  2'b0;
        end else if (hwrite_en) begin
            case (haddr_d)
                SPI_SCKDIV_OFFSET: SCKDIV_REG       <=  hwdata_i[11:0];
                SPI_SCKMODE_OFFSET: SCKMODE_REG     <=  hwdata_i[1:0];
                SPI_CSID_OFFSET: CSID_REG           <=  hwdata_i[1:0];
                SPI_CSDEF_OFFSET: CSDEF_REG         <=  hwdata_i[3:0];
                SPI_CSMODE_OFFSET: CSMODE_REG       <=  hwdata_i[1:0];
                SPI_DELAY0_OFFSET: DELAY0_REG       <=  hwdata_i[23:0] & DELAY0_WMASK;
                SPI_DELAY1_OFFSET: DELAY1_REG       <=  hwdata_i[23:0] & DELAY1_WMASK;
                SPI_FMT_OFFSET: FMT_REG             <=  hwdata_i[19:0] & FMT_WMASK;
                SPI_TXMARK_OFFSET: TXMARK_REG       <=  hwdata_i[2:0];
                SPI_RXMARK_OFFSET: RXMARK_REG       <=  hwdata_i[2:0];
                SPI_IE_OFFSET: IE_REG               <=  hwdata_i[1:0];
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (!resetn) begin
            hsel_d      <=  1'b0;
            haddr_d     <=  12'h0;
            htrans_d    <=  2'b0;
            hwrite_d    <=  1'b0;
        end else if (ahb_advance) begin
            hsel_d      <=  hsel_i;
            haddr_d     <=  haddr_i[11:0];
            htrans_d    <=  htrans_i;
            hwrite_d    <=  hwrite_i;
        end
    end

    always_comb begin
        ahb_advance         =   hready_i;

        hvalid_d            =   hsel_d && htrans_d[1];

        hwrite_en           =   hvalid_d && hwrite_d && hready_i;

        hreadyout_o         =   1'b1;
        hresp_o             =   AHB_OKAY;

        rx_fifo_pop         =   hvalid_d && !hwrite_d && hready_i && (haddr_d == SPI_RXDATA_OFFSET) && !rx_fifo_empty;
        
        tx_fifo_push        =   hwrite_en && (haddr_d == SPI_TXDATA_OFFSET);
        tx_fifo_push_data   =   hwdata_i[7:0];

        txmark              =   {1'b0, TXMARK_REG};
        tx_wm_ip            =   (tx_fifo_count < txmark);

        rxmark              =   {1'b0, RXMARK_REG};
        rx_wm_ip            =   (rx_fifo_count > rxmark);

        spi_interrupt_o     =   (tx_wm_ip && IE_REG[0]) || (rx_wm_ip && IE_REG[1]);

        cssck               =   DELAY0_REG[7:0];
        sckcs               =   DELAY0_REG[23:16];
        intercs             =   DELAY1_REG[7:0];
        interxfr            =   DELAY1_REG[23:16];
        endian              =   FMT_REG[2];
        dir                 =   FMT_REG[3];
        len                 =   FMT_REG[19:16];

        SCKDIV_RD           =   {20'h0, SCKDIV_REG};
        SCKMODE_RD          =   {30'h0, SCKMODE_REG};
        CSID_RD             =   {30'h0, CSID_REG};
        CSDEF_RD            =   {28'h0, CSDEF_REG};
        CSMODE_RD           =   {30'h0, CSMODE_REG};
        DELAY0_RD           =   {8'b0, DELAY0_REG};
        DELAY1_RD           =   {8'b0, DELAY1_REG};
        FMT_RD              =   {12'h0, FMT_REG};
        TXDATA_RD           =   {tx_fifo_full, 31'h0};
        RXDATA_RD           =   {rx_fifo_empty, 23'h0, rx_fifo_pop_data};
        TXMARK_RD           =   {29'h0, TXMARK_REG};
        RXMARK_RD           =   {29'h0, RXMARK_REG};
        IE_RD               =   {30'h0, IE_REG};
        IP_RD               =   {30'h0, rx_wm_ip, tx_wm_ip};        

        case (haddr_d[11:3])
            SPI_SCKDIV_OFFSET[11:3]: hrdata_o   =   {SCKMODE_RD, SCKDIV_RD};
            SPI_CSID_OFFSET[11:3]: hrdata_o     =   {CSDEF_RD, CSID_RD};
            SPI_CSMODE_OFFSET[11:3]: hrdata_o   =   {32'h0, CSMODE_RD};
            SPI_DELAY0_OFFSET[11:3]: hrdata_o   =   {DELAY1_RD, DELAY0_RD};
            SPI_FMT_OFFSET[11:3]: hrdata_o      =   {32'h0, FMT_RD};
            SPI_TXDATA_OFFSET[11:3]: hrdata_o   =   {RXDATA_RD, TXDATA_RD};
            SPI_TXMARK_OFFSET[11:3]: hrdata_o   =   {RXMARK_RD, TXMARK_RD};
            SPI_IE_OFFSET[11:3]: hrdata_o       =   {IP_RD, IE_RD};
            default: hrdata_o                   =   64'h0;
        endcase
    end

endmodule