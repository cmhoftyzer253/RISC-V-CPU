import cpu_defines::*;
import cpu_utils::*;

module uart(
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

    input logic             rx_i,
    output logic            tx_o,

    output logic            uart_interrupt_o
);

    logic                   txen;
    logic                   rxen;
    logic                   nstop;

    logic [3:0]             txmark;
    logic [3:0]             rxmark;
    logic                   tx_wm_ip;
    logic                   rx_wm_ip;

    logic [18:0]            TXCTRL_REG;
    logic [18:0]            RXCTRL_REG;
    logic [1:0]             IE_REG;
    logic [31:0]            DIV_REG;

    logic [31:0]            TXDATA_RD;
    logic [31:0]            RXDATA_RD;
    logic [31:0]            TXCTRL_RD;
    logic [31:0]            RXCTRL_RD;
    logic [31:0]            IE_RD;
    logic [31:0]            IP_RD;

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

    uart_rx u_uart_rx (
        .clk                    (clk),
        .resetn                 (resetn),
        .rxen_i                 (rxen),
        .div_i                  (DIV_REG),
        .rx_fifo_push_o         (rx_fifo_push),
        .rx_fifo_push_data_o    (rx_fifo_push_data),
        .rx_i                   (rx_i)
    );

    uart_tx u_uart_tx (
        .clk                    (clk),
        .resetn                 (resetn),
        .txen_i                 (txen),
        .nstop_i                (nstop),
        .div_i                  (DIV_REG),
        .tx_fifo_empty_i        (tx_fifo_empty),
        .tx_fifo_pop_o          (tx_fifo_pop),
        .tx_fifo_pop_data_i     (tx_fifo_pop_data),
        .tx_o                   (tx_o)
    );

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            TXCTRL_REG  <=  19'h0;
            RXCTRL_REG  <=  19'h0;
            IE_REG      <=  2'b0;
            DIV_REG     <=  32'h0;
        end else if (hwrite_en) begin
            case (haddr_d)
                TXCTRL_OFFSET: TXCTRL_REG   <=  hwdata_i[18:0] & TXCTRL_WMASK;
                RXCTRL_OFFSET: RXCTRL_REG   <=  hwdata_i[18:0] & RXCTRL_WMASK;
                IE_OFFSET: IE_REG           <=  hwdata_i[1:0];
                DIV_OFFSET: DIV_REG         <=  hwdata_i[31:0];
            endcase
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            hsel_d      <=  1'b0;
            haddr_d     <=  12'h0;
            htrans_d    <=  2'b0;
            hwrite_d    <=  1'b0;
            hburst_d    <=  3'b0;
        end else if (ahb_advance) begin
            hsel_d      <=  hsel_i;
            haddr_d     <=  haddr_i[11:0];
            htrans_d    <=  htrans_i;
            hwrite_d    <=  hwrite_i;
            hburst_d    <=  hburst_i;
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            error_ff    <=  1'b0;
        end else if (error_ff && hready_i) begin
            error_ff    <=  1'b0;
        end else if (ahb_error) begin
            error_ff    <=  1'b1;
        end
    end

    always_comb begin
        ahb_advance         =   hready_i;

        hvalid_d            =   hsel_d && htrans_d[1];
        ahb_error           =   hvalid_d && ((hburst_d != SINGLE) || (htrans_d == SEQ));

        hwrite_en           =   hvalid_d && !ahb_error && hwrite_d && hready_i;

        hreadyout_o         =   !ahb_error || error_ff;
        hresp_o             =   ahb_error;

        rx_fifo_pop         =   hvalid_d && !ahb_error && !hwrite_d && hready_i && (haddr_d == RXDATA_OFFSET) && !rx_fifo_empty;

        tx_fifo_push        =   hwrite_en && (haddr_d == TXDATA_OFFSET);
        tx_fifo_push_data   =   hwdata_i[7:0];

        rxen                =   RXCTRL_REG[0];

        txen                =   TXCTRL_REG[0];
        nstop               =   TXCTRL_REG[1];

        txmark              =   {1'b0, TXCTRL_REG[18:16]};
        tx_wm_ip            =   (tx_fifo_count < txmark);

        rxmark              =   {1'b0, RXCTRL_REG[18:16]};
        rx_wm_ip            =   (rx_fifo_count > rxmark);

        uart_interrupt_o    =   (tx_wm_ip && IE_REG[0]) || (rx_wm_ip && IE_REG[1]);

        TXDATA_RD           =   {tx_fifo_full, 31'h0};
        RXDATA_RD           =   {rx_fifo_empty, 23'h0, rx_fifo_pop_data};
        TXCTRL_RD           =   {13'h0, TXCTRL_REG};
        RXCTRL_RD           =   {13'h0, RXCTRL_REG};
        IE_RD               =   {30'h0, IE_REG};
        IP_RD               =   {30'h0, rx_wm_ip, tx_wm_ip};

        case (haddr_d[11:3])
            TXDATA_OFFSET[11:3]: hrdata_o   =   {RXDATA_RD, TXDATA_RD};
            TXCTRL_OFFSET[11:3]: hrdata_o   =   {RXCTRL_RD, TXCTRL_RD};
            IE_OFFSET[11:3]: hrdata_o       =   {IP_RD, IE_RD};
            DIV_OFFSET[11:3]: hrdata_o      =   {32'h0, DIV_REG};
            default: hrdata_o               =   64'h0;
        endcase
    end

endmodule