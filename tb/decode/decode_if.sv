interface decode_if(
    input logic     clk
);

    logic [31:0]    instr_i = '0;
    logic [4:0]     rs1_o;
    logic [4:0]     rs2_o;
    logic [4:0]     rd_o;
    logic [6:0]     op_o;
    logic [2:0]     funct3_o;
    logic [11:0]    funct12_o;
    logic [11:0]    csr_addr_o;
    logic           r_type_o;
    logic           i_type_o;
    logic           s_type_o;
    logic           b_type_o;
    logic           u_type_o;
    logic           j_type_o;
    logic           system_type_o;
    logic [63:0]    imm_o;
    logic           exc_valid_o;
    logic [4:0]     exc_code_o;

    clocking mon_cb @(posedge clk);
        default input #1step;
        input instr_i;
    endclocking : mon_cb

    clocking drv_cb @(posedge clk);
        default output #1ns;
        output instr_i;
    endclocking : drv_cb

    clocking res_cb @(posedge clk);
        default input #1step;
        input rs1_o;
        input rs2_o;
        input rd_o;
        input op_o;
        input funct3_o;
        input funct12_o;
        input csr_addr_o;
        input r_type_o;
        input i_type_o;
        input s_type_o;
        input b_type_o;
        input u_type_o;
        input j_type_o;
        input system_type_o;
        input imm_o;
        input exc_valid_o;
        input exc_code_o;
    endclocking : res_cb

    modport MON (clocking mon_cb, input clk);
    modport DRV (clocking drv_cb, input clk);
    modport RES (clocking res_cb, input clk);

    modport DUT (
        input   instr_i,
        output  rs1_o,
        output  rs2_o,
        output  rd_o,
        output  op_o,
        output  funct3_o,
        output  funct12_o,
        output  csr_addr_o,
        output  r_type_o,
        output  i_type_o,
        output  s_type_o,
        output  b_type_o,
        output  u_type_o,
        output  j_type_o,
        output  system_type_o,
        output  imm_o,
        output  exc_valid_o,
        output  exc_code_o
    );

endinterface