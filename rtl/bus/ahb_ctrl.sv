module ahb_ctrl
    import cpu_defines::*;
(
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      haddr_i,
    input logic [5:0]       hreadyout_i,
    input logic [63:0]      hrdata_i [5:0],
    input logic [5:0]       hresp_i,

    output logic [5:0]      hsel_o,
    output logic            hready_o,
    output logic [63:0]     hrdata_o,
    output logic            hresp_o
);

    logic [5:0]             hsel_d;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            hsel_d  <=  6'b0;
        end else if (hready_o) begin
            hsel_d  <=  hsel_o;
        end
    end

    always_comb begin
        //hsel bits:
        //0: Boot ROM 
        //1: CLINT
        //2: PLIC
        //3: UART
        //4: SPI
        //5: GPIO
        hsel_o[0] = (haddr_i[63:13] == 51'h0_0000_0000_0008);
        hsel_o[1] = (haddr_i[63:16] == 48'h0000_0000_0200);
        hsel_o[2] = (haddr_i[63:26] == 38'h00_0000_0003);
        hsel_o[3] = (haddr_i[63:12] == 52'h0_0000_0001_0010);
        hsel_o[4] = (haddr_i[63:12] == 52'h0_0000_0001_0040);
        hsel_o[5] = (haddr_i[63:12] == 52'h0_0000_0001_0060);

        case (hsel_d)
            6'b00_0001: begin
                hready_o = hreadyout_i[0];
                hrdata_o = hrdata_i[0];
                hresp_o = hresp_i[0];
            end
            6'b00_0010: begin
                hready_o = hreadyout_i[1];
                hrdata_o = hrdata_i[1];
                hresp_o = hresp_i[1];
            end
            6'b00_0100: begin
                hready_o = hreadyout_i[2];
                hrdata_o = hrdata_i[2];
                hresp_o = hresp_i[2];
            end
            6'b00_1000: begin
                hready_o = hreadyout_i[3];
                hrdata_o = hrdata_i[3];
                hresp_o = hresp_i[3];
            end
            6'b01_0000: begin
                hready_o = hreadyout_i[4];
                hrdata_o = hrdata_i[4];
                hresp_o = hresp_i[4];
            end
            6'b10_0000: begin
                hready_o = hreadyout_i[5];
                hrdata_o = hrdata_i[5];
                hresp_o = hresp_i[5];
            end
            default: begin
                hready_o = 1'b1;
                hrdata_o = 64'h0;
                hresp_o = AHB_OKAY;
            end
        endcase
    end

endmodule