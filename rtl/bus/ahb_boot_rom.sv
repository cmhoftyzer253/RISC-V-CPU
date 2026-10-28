module ahb_boot_rom
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
    output logic            hresp_o
);

    logic                   hread_en;

    boot_rom u_boot_rom(
        .clka       (clk),
        .ena        (hread_en),
        .addra      (haddr_i[11:3]),
        .douta      (hrdata_o)
    );

    always_comb begin
        hreadyout_o     =   1'b1;
        hresp_o         =   AHB_OKAY;

        hread_en        =   hsel_i && htrans_i[1] && !hwrite_i && hready_i;
    end

endmodule