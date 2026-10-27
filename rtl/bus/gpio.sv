import cpu_defines::*;

module gpio (
    input logic             clk,
    input logic             resetn,

    input logic [31:0]      gpio_in_i,
    output logic [31:0]     gpio_out_o,
    output logic [31:0]     gpio_out_en_o,

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

    output logic [31:0]     iof_en_o,
    output logic [31:0]     iof_sel_o,

    output logic            gpio_interrupt_o
);

    logic [31:0]            gpio_in_q;
    logic [31:0]            gpio_in_q2;
    logic [31:0]            gpio_in_q3;

    logic [31:0]            INPUT_EN_REG;
    logic [31:0]            OUTPUT_EN_REG;
    logic [31:0]            OUTPUT_VAL_REG;
    logic [31:0]            RISE_IE_REG;
    logic [31:0]            RISE_IP_REG;
    logic [31:0]            FALL_IE_REG;
    logic [31:0]            FALL_IP_REG;
    logic [31:0]            HIGH_IE_REG;
    logic [31:0]            HIGH_IP_REG;
    logic [31:0]            LOW_IE_REG;
    logic [31:0]            LOW_IP_REG;
    logic [6:0]             IOF_EN_REG;
    logic [6:0]             IOF_SEL_REG;
    logic [31:0]            OUT_XOR_REG;

    logic [31:0]            IOF_EN_RD;
    logic [31:0]            IOF_SEL_RD;

    logic [31:0]            rise_set;
    logic [31:0]            fall_set;
    logic [31:0]            high_set;
    logic [31:0]            low_set;

    logic                   hsel_d;
    logic [11:0]            haddr_d;
    logic [1:0]             htrans_d;
    logic                   hwrite_d;

    logic                   ahb_advance;
    logic                   hvalid_d;
    logic                   hwrite_en;

    logic                   rise_ip_hwrite;
    logic                   fall_ip_hwrite;
    logic                   high_ip_hwrite;
    logic                   low_ip_hwrite;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            gpio_in_q   <=  32'h0;
            gpio_in_q2  <=  32'h0;
            gpio_in_q3  <=  32'h0;
        end else begin
            gpio_in_q   <=  gpio_in_i & INPUT_EN_REG;
            gpio_in_q2  <=  gpio_in_q;
            gpio_in_q3  <=  gpio_in_q2;
        end
    end

    always_ff @(posedge clk) begin
        if (!resetn) begin
            INPUT_EN_REG    <=  32'h0;
            OUTPUT_EN_REG   <=  32'h0;
            OUTPUT_VAL_REG  <=  32'h0;
            RISE_IE_REG     <=  32'h0;
            RISE_IP_REG     <=  32'h0;
            FALL_IE_REG     <=  32'h0;
            FALL_IP_REG     <=  32'h0;
            HIGH_IE_REG     <=  32'h0;
            HIGH_IP_REG     <=  32'h0;
            LOW_IE_REG      <=  32'h0;
            LOW_IP_REG      <=  32'h0;
            IOF_EN_REG      <=  7'b0;
            IOF_SEL_REG     <=  7'b0;
            OUT_XOR_REG     <=  32'h0;
        end else begin
            if (hwrite_en) begin
                case (haddr_d)
                    GPIO_INPUT_EN_OFFSET: INPUT_EN_REG       <=  hwdata_i[31:0];
                    GPIO_OUTPUT_EN_OFFSET: OUTPUT_EN_REG     <=  hwdata_i[31:0];
                    GPIO_OUTPUT_VAL_OFFSET: OUTPUT_VAL_REG   <=  hwdata_i[31:0];
                    GPIO_RISE_IE_OFFSET: RISE_IE_REG         <=  hwdata_i[31:0];
                    GPIO_RISE_IP_OFFSET: RISE_IP_REG         <=  (RISE_IP_REG & ~hwdata_i[31:0]) | rise_set;
                    GPIO_FALL_IE_OFFSET: FALL_IE_REG         <=  hwdata_i[31:0];
                    GPIO_FALL_IP_OFFSET: FALL_IP_REG         <=  (FALL_IP_REG & ~hwdata_i[31:0]) | fall_set;
                    GPIO_HIGH_IE_OFFSET: HIGH_IE_REG         <=  hwdata_i[31:0];
                    GPIO_HIGH_IP_OFFSET: HIGH_IP_REG         <=  (HIGH_IP_REG & ~hwdata_i[31:0]) | high_set;
                    GPIO_LOW_IE_OFFSET: LOW_IE_REG           <=  hwdata_i[31:0];
                    GPIO_LOW_IP_OFFSET: LOW_IP_REG           <=  (LOW_IP_REG & ~hwdata_i[31:0]) | low_set;
                    GPIO_IOF_EN_OFFSET: IOF_EN_REG           <=  hwdata_i[6:0];
                    GPIO_IOF_SEL_OFFSET: IOF_SEL_REG         <=  hwdata_i[6:0];
                    GPIO_OUT_XOR_OFFSET: OUT_XOR_REG         <=  hwdata_i[31:0];
                endcase
            end 

            if (!rise_ip_hwrite)
                RISE_IP_REG     <=  RISE_IP_REG | rise_set;
            if (!fall_ip_hwrite)
                FALL_IP_REG     <=  FALL_IP_REG | fall_set;
            if (!high_ip_hwrite)
                HIGH_IP_REG     <=  HIGH_IP_REG | high_set;
            if (!low_ip_hwrite)
                LOW_IP_REG      <=  LOW_IP_REG | low_set;
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
        rise_ip_hwrite      =   hwrite_en && (haddr_d == GPIO_RISE_IP_OFFSET);
        fall_ip_hwrite      =   hwrite_en && (haddr_d == GPIO_FALL_IP_OFFSET);
        high_ip_hwrite      =   hwrite_en && (haddr_d == GPIO_HIGH_IP_OFFSET);
        low_ip_hwrite       =   hwrite_en && (haddr_d == GPIO_LOW_IP_OFFSET);

        rise_set            =   ~gpio_in_q3 & gpio_in_q2;
        fall_set            =   gpio_in_q3 & ~gpio_in_q2;
        high_set            =   gpio_in_q3;
        low_set             =   ~gpio_in_q3;

        gpio_out_en_o       =   OUTPUT_EN_REG;

        gpio_interrupt_o    =   |(RISE_IE_REG & RISE_IP_REG) || 
                                |(FALL_IE_REG & FALL_IP_REG) || 
                                |(HIGH_IE_REG & HIGH_IP_REG) || 
                                |(LOW_IE_REG & LOW_IP_REG);

        gpio_out_o          =   OUTPUT_VAL_REG ^ OUT_XOR_REG;

        hreadyout_o         =   1'b1;
        hresp_o             =   AHB_OKAY;

        IOF_EN_RD           =   {25'h0, IOF_EN_REG};
        IOF_SEL_RD          =   {25'h0, IOF_SEL_REG};

        iof_en_o            =   IOF_EN_RD;
        iof_sel_o           =   IOF_SEL_RD;

        //loads return aligned 64 bit data, load_es_algn extracts load data
        //only need to check bits [11:3]
        //neighbouring 32 bit registers have same return value
        case (haddr_d[11:3])
            GPIO_INPUT_VAL_OFFSET[11:3]: hrdata_o   =   {INPUT_EN_REG, gpio_in_q3};
            GPIO_OUTPUT_EN_OFFSET[11:3]: hrdata_o   =   {OUTPUT_VAL_REG, OUTPUT_EN_REG};
            GPIO_RISE_IE_OFFSET[11:3]: hrdata_o     =   {RISE_IP_REG, RISE_IE_REG};
            GPIO_FALL_IE_OFFSET[11:3]: hrdata_o     =   {FALL_IP_REG, FALL_IE_REG};
            GPIO_HIGH_IE_OFFSET[11:3]: hrdata_o     =   {HIGH_IP_REG, HIGH_IE_REG};
            GPIO_LOW_IE_OFFSET[11:3]: hrdata_o      =   {LOW_IP_REG, LOW_IE_REG};
            GPIO_IOF_EN_OFFSET[11:3]: hrdata_o      =   {IOF_SEL_RD, IOF_EN_RD};
            GPIO_OUT_XOR_OFFSET[11:3]: hrdata_o     =   {32'h0, OUT_XOR_REG};
            default: hrdata_o                       =   64'h0;
        endcase
    end

endmodule