module ahb_boot_rom
    import cpu_defines::*;
(
    input logic             clk,
    
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

    xpm_memory_sprom #(
        .MEMORY_SIZE        (512 * 64),
        .MEMORY_PRIMITIVE   ("block"),
        .ADDR_WIDTH_A       (9),
        .READ_DATA_WIDTH_A  (64),
        .READ_LATENCY_A     (1),
        .READ_RESET_VALUE_A ("0"),
        .MEMORY_INIT_FILE   ("boot_rom.mem"),
        .MEMORY_INIT_PARAM  (""),
        .USE_MEM_INIT       (1),
        .ECC_MODE           ("no_ecc"),
        .WAKEUP_TIME        ("disable_sleep")
    ) u_boot_rom (
        .clka               (clk),
        .ena                (hread_en),
        .addra              (haddr_i[11:3]),
        .douta              (hrdata_o),
        .rsta               (1'b0),
        .regcea             (1'b1),
        .sleep              (1'b0),
        .injectsbiterra     (1'b0),
        .injectdbiterra     (1'b0),
        .sbiterra           (),
        .dbiterra           ()
    );

    always_comb begin
        hreadyout_o     =   1'b1;
        hresp_o         =   AHB_OKAY;

        hread_en        =   hsel_i && htrans_i[1] && !hwrite_i && hready_i;
    end

endmodule