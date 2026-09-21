import cpu_defines::*;

module clint (
    input logic             clk,       
    input logic             resetn,

    output logic            mtip_o,
    output logic            msip_o,

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
    output logic            hresp_o
);

    logic                   MSIP_REG;
    logic [63:0]            MTIMECMP_REG;
    logic [63:0]            MTIME_REG;

    logic                   hsel_d;
    logic [15:0]            haddr_d;
    logic [1:0]             htrans_d;
    logic                   hwrite_d;
    logic [2:0]             hsize_d;
    logic [2:0]             hburst_d;

    logic                   ahb_advance;
    logic                   hvalid_d;
    logic                   ahb_error;
    logic                   error_ff;

    logic                   hwrite_en;
    logic                   mtime_hwrite;
    logic [1:0]             hwrite_mask;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            MTIME_REG                       <=  64'h0;
            MTIMECMP_REG                    <=  64'hFFFF_FFFF_FFFF_FFFF;
            MSIP_REG                        <=  1'b0;
        end else begin 
            if (hwrite_en) begin
                case (haddr_d[15:3])
                    MTIME_ADDR[15:3]: begin
                        MTIME_REG[63:32]        <=  hwrite_mask[1] ? hwdata_i[63:32] : MTIME_REG[63:32];
                        MTIME_REG[31:0]         <=  hwrite_mask[0] ? hwdata_i[31:0] : MTIME_REG[31:0];
                    end
                    MTIMECMP_ADDR[15:3]: begin
                        MTIMECMP_REG[63:32]     <=  hwrite_mask[1] ? hwdata_i[63:32] : MTIMECMP_REG[63:32];
                        MTIMECMP_REG[31:0]      <=  hwrite_mask[0] ? hwdata_i[31:0] : MTIMECMP_REG[31:0];
                    end
                    MSIP_ADDR[15:3]: MSIP_REG   <=  hwrite_mask[0] ? hwdata_i[0] : MSIP_REG;
                endcase
            end
            if (!mtime_hwrite)
                MTIME_REG   <=  MTIME_REG + 64'h1;

        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            hsel_d      <=  1'b0;
            haddr_d     <=  16'h0;
            htrans_d    <=  2'b0;
            hwrite_d    <=  1'b0;
            hsize_d     <=  3'b0;
            hburst_d    <=  3'b0;
        end else if (ahb_advance) begin
            hsel_d      <=  hsel_i;
            haddr_d     <=  haddr_i[15:0];
            htrans_d    <=  htrans_i;
            hwrite_d    <=  hwrite_i;
            hsize_d     <=  hsize_i;
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
        ahb_advance     =   hready_i;

        hvalid_d        =   hsel_d && htrans_d[1];
        ahb_error       =   hvalid_d && ((hburst_d != SINGLE) || (htrans_d == SEQ));

        hwrite_en       =   hvalid_d && !ahb_error && hwrite_d && hready_i;
        mtime_hwrite    =   hwrite_en && (haddr_d[15:3] == MTIME_OFFSET[15:3]);

        hwrite_mask[1]  =   (hsize_d == AMBA_DOUBLE_WORD) ||  haddr_d[2];
        hwrite_mask[0]  =   (hsize_d == AMBA_DOUBLE_WORD) || !haddr_d[2];

        msip_o          =   MSIP_REG;
        mtip_o          =   (MTIME_REG >= MTIMECMP_REG);

        hreadyout_o     =   !ahb_error || error_ff;
        hresp_o         =   ahb_error;

        case (haddr_d[15:3])
            MSIP_OFFSET[15:3]: hrdata_o         =   {63'h0, MSIP_REG};
            MTIMECMP_OFFSET[15:3]: hrdata_o     =   MTIMECMP_REG;
            MTIME_OFFSET[15:3]: hrdata_o        =   MTIME_REG;
            default: hrdata_o                   =   64'h0;
        endcase
    end

endmodule