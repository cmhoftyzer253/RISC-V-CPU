interface rf_if(
    input logic     clk
);

    logic           resetn,

    logic [4:0]     rs1_addr_i;
    logic [4:0]     rs2_addr_i;
    logic [63:0]    rs1_data_o;
    logic [63:0]    rs2_data_o;
    logic [4:0]     rd_addr_i;
    logic           wr_en_i;
    logic [63:0]    wr_data_i;

    clocking reset_cb @(posedge clk);
        default output #1ns;
        output  resetn;
    endclocking : reset_cb

    clocking mon_cb @(posedge clk);
        default input #1step;
        input rs1_addr_i;
        input rs2_addr_i;
        input rd_addr_i;
        input wr_en_i;
        input wr_data_i;
    endclocking : mon_cb

    clocking drv_cb @(posedge clk);
        default output #1ns;
        output rs1_addr_i;
        output rs2_addr_i;
        output rd_addr_i;
        output wr_en_i;
        output wr_data_i;
    endclocking : drv_cb

    clocking res_cb @(posedge clk);
        default input #1step;
        input rs1_data_o;
        input rs2_data_o;
    endclocking : res_cb

    modport RESET (clocking reset_cb,       input clk);
    modport MON (clocking mon_cb,           input clk);
    modport DRV (clocking drv_cb,           input clk);
    modport RESULT_MON (clocking res_cb,    input clk);

endinterface