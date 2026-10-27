import cpu_defines::*;
import cpu_utils::*;

module plic(
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

    input logic             uart_interrupt_i,
    input logic             spi_interrupt_i,
    input logic             gpio_interrupt_i,

    output logic            meip_o,
    output logic            seip_o
);

    logic                   hsel_d;
    logic [25:0]            haddr_d;
    logic [1:0]             htrans_d;
    logic                   hwrite_d;

    logic                   ahb_advance;
    logic                   hvalid_d;
    logic                   hwrite_en;
    logic                   hread_en;

    logic [2:0]             SRC1_PRIORITY_REG;
    logic [2:0]             SRC2_PRIORITY_REG;
    logic [2:0]             SRC3_PRIORITY_REG;
    logic [3:0]             PENDING_REG;
    logic [3:0]             M_ENABLE_REG;
    logic [3:0]             S_ENABLE_REG;
    logic [2:0]             M_THRESHOLD_REG;
    logic [2:0]             S_THRESHOLD_REG;

    logic [31:0]            SRC1_PRIORITY_RD;
    logic [31:0]            SRC2_PRIORITY_RD;
    logic [31:0]            SRC3_PRIORITY_RD;
    logic [31:0]            PENDING_RD;
    logic [31:0]            M_ENABLE_RD;
    logic [31:0]            S_ENABLE_RD;
    logic [31:0]            M_THRESHOLD_RD;
    logic [31:0]            S_THRESHOLD_RD;
    logic [31:0]            M_CLAIM_COMPLETE_RD;
    logic [31:0]            S_CLAIM_COMPLETE_RD;

    logic [3:0]             source;
    logic [3:0]             gw_request;
    logic [3:0]             complete;

    logic [2:0]             PRIORITY_REG [0:3];

    logic [2:0]             m_priority_eff[0:3];
    logic [2:0]             s_priority_eff[0:3];

    logic [2:0]             m_priority;
    logic [2:0]             s_priority;

    logic [1:0]             m_claim_complete;
    logic [1:0]             s_claim_complete;

    logic [3:0]             m_claim;
    logic [3:0]             s_claim;
    logic [3:0]             claim;

    logic [3:0]             m_complete;
    logic [3:0]             s_complete;

    assign gw_request[0] = 1'b0;

    generate
        for (genvar i=1; i<4; i++) begin
            gateway_level #(
                .req_level(1'b1)
            ) u_gateway (
                .clk            (clk),
                .resetn         (resetn),
                .complete_i     (complete[i]),
                .source_i       (source[i]),
                .request_o      (gw_request[i])
            );
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (!resetn) begin
            SRC1_PRIORITY_REG   <=  3'b0;
            SRC2_PRIORITY_REG   <=  3'b0;
            SRC3_PRIORITY_REG   <=  3'b0;
            PENDING_REG         <=  4'b0;
            M_ENABLE_REG        <=  4'b0;
            S_ENABLE_REG        <=  4'b0;
            M_THRESHOLD_REG     <=  3'b0;
            S_THRESHOLD_REG     <=  3'b0;
        end else begin
            PENDING_REG         <=  (PENDING_REG | gw_request) & ~claim;    

            if (hwrite_en) begin
                case (haddr_d)
                    PLIC_SRC1_PRIORITY_OFFSET: SRC1_PRIORITY_REG     <=  hwdata_i[2:0];
                    PLIC_SRC2_PRIORITY_OFFSET: SRC2_PRIORITY_REG     <=  hwdata_i[2:0];
                    PLIC_SRC3_PRIORITY_OFFSET: SRC3_PRIORITY_REG     <=  hwdata_i[2:0];
                    PLIC_M_ENABLE_OFFSET: M_ENABLE_REG               <=  hwdata_i[3:0] & PLIC_M_ENABLE_WR_MASK;
                    PLIC_S_ENABLE_OFFSET: S_ENABLE_REG               <=  hwdata_i[3:0] & PLIC_S_ENABLE_WR_MASK;
                    PLIC_M_THRESHOLD_OFFSET: M_THRESHOLD_REG         <=  hwdata_i[2:0];
                    PLIC_S_THRESHOLD_OFFSET: S_THRESHOLD_REG         <=  hwdata_i[2:0];
                endcase
            end            
        end
    end

    always_ff @(posedge clk) begin
        if (!resetn) begin
            hsel_d      <=  1'b0;
            haddr_d     <=  26'h0;
            htrans_d    <=  2'b0;
            hwrite_d    <=  1'b0;
        end else if (ahb_advance) begin
            hsel_d      <=  hsel_i;
            haddr_d     <=  haddr_i[25:0];
            htrans_d    <=  htrans_i;
            hwrite_d    <=  hwrite_i;
        end
    end

    always_comb begin : ahb_read
        ahb_advance                 =   hready_i;

        hvalid_d                    =   hsel_d && htrans_d[1];

        hwrite_en                   =   hvalid_d && hwrite_d && hready_i;
        hread_en                    =   hvalid_d && !hwrite_d && hready_i;

        hreadyout_o                 =   1'b1;
        hresp_o                     =   AHB_OKAY;

        SRC1_PRIORITY_RD            =   {29'h0, SRC1_PRIORITY_REG};
        SRC2_PRIORITY_RD            =   {29'h0, SRC2_PRIORITY_REG};
        SRC3_PRIORITY_RD            =   {29'h0, SRC3_PRIORITY_REG};
        PENDING_RD                  =   {28'h0, PENDING_REG};
        M_ENABLE_RD                 =   {28'h0, M_ENABLE_REG};
        S_ENABLE_RD                 =   {28'h0, S_ENABLE_REG};
        M_THRESHOLD_RD              =   {29'h0, M_THRESHOLD_REG};
        M_CLAIM_COMPLETE_RD         =   {30'h0, m_claim_complete};
        S_THRESHOLD_RD              =   {29'h0, S_THRESHOLD_REG};
        S_CLAIM_COMPLETE_RD         =   {30'h0, s_claim_complete};

        case (haddr_d[25:3])
            PLIC_SRC1_PRIORITY_OFFSET[25:3]: hrdata_o    =   {SRC1_PRIORITY_RD, 32'h0};
            PLIC_SRC2_PRIORITY_OFFSET[25:3]: hrdata_o    =   {SRC3_PRIORITY_RD, SRC2_PRIORITY_RD};
            PLIC_PENDING_OFFSET[25:3]: hrdata_o          =   {32'h0, PENDING_RD};
            PLIC_M_ENABLE_OFFSET[25:3]: hrdata_o         =   {32'h0, M_ENABLE_RD};
            PLIC_S_ENABLE_OFFSET[25:3]: hrdata_o         =   {32'h0, S_ENABLE_RD};
            PLIC_M_THRESHOLD_OFFSET[25:3]: hrdata_o      =   {M_CLAIM_COMPLETE_RD, M_THRESHOLD_RD};
            PLIC_S_THRESHOLD_OFFSET[25:3]: hrdata_o      =   {S_CLAIM_COMPLETE_RD, S_THRESHOLD_RD};
            default: hrdata_o                       =   64'h0;
        endcase
    end

    always_comb begin : interrupt_logic
        source                      =   '0;
        source[PLIC_UART_SOURCE_ID] =   uart_interrupt_i;
        source[PLIC_SPI_SOURCE_ID]  =   spi_interrupt_i;
        source[PLIC_GPIO_SOURCE_ID] =   gpio_interrupt_i;

        PRIORITY_REG                =   '0;
        PRIORITY_REG[1]             =   SRC1_PRIORITY_REG;
        PRIORITY_REG[2]             =   SRC2_PRIORITY_REG;
        PRIORITY_REG[3]             =   SRC3_PRIORITY_REG;

        m_priority_eff              =   '0;
        s_priority_eff              =   '0;
        for (int i=1; i<4; i++) begin
            m_priority_eff[i] = (PENDING_REG[i] && M_ENABLE_REG[i]) ? PRIORITY_REG[i] : 3'b0;
            s_priority_eff[i] = (PENDING_REG[i] && S_ENABLE_REG[i]) ? PRIORITY_REG[i] : 3'b0;
        end

        m_claim_complete            =   2'b0;
        s_claim_complete            =   2'b0;
        m_priority                  =   3'b0;
        s_priority                  =   3'b0;
        for (int i=1; i<4; i++) begin
            m_claim_complete        =   (m_priority_eff[i] > m_priority) ? i[1:0] : m_claim_complete;
            m_priority              =   (m_priority_eff[i] > m_priority) ? m_priority_eff[i] : m_priority;

            s_claim_complete        =   (s_priority_eff[i] > s_priority) ? i[1:0] : s_claim_complete;
            s_priority              =   (s_priority_eff[i] > s_priority) ? s_priority_eff[i] : s_priority;
        end

        meip_o                      =   (m_priority > M_THRESHOLD_REG);
        seip_o                      =   (s_priority > S_THRESHOLD_REG);

        m_claim                     =   '0;
        s_claim                     =   '0;
        m_complete                  =   '0;
        s_complete                  =   '0;

        for (int i=1; i<4; i++) begin
            m_claim[i] = hread_en && (haddr_d == M_CLAIM_COMPLETE) && (m_claim_complete == i[1:0]);
            s_claim[i] = hread_en && (haddr_d == S_CLAIM_COMPLETE) && (s_claim_complete == i[1:0]);
        end

        for (int i=1; i<4; i++) begin
            m_complete[i] = hwrite_en && (haddr_d == M_CLAIM_COMPLETE) && (hwdata_i == i[1:0]);
            s_complete[i] = hwrite_en && (haddr_d == S_CLAIM_COMPLETE) && (hwdata_i == i[1:0]);
        end

        claim                       =   m_claim | s_claim;
        complete                    =   m_complete | s_complete;
    end

endmodule