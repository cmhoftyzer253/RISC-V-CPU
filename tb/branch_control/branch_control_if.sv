interface branch_control_if (
    input logic clk;
);

    import cpu_consts::*;

    logic [63:0]    opr_a_i         =   '0;
    logic [63:0]    opr_b_i         =   '0;
    logic           b_type_i        =   '0;
    b_type_t        instr_funct3_i  =   BEQ;

    logic           branch_taken_o;

    clocking mon_cb @(posedge clk);
        default input #1step;
        input   opr_a_i;
        input   opr_b_i;
        input   b_type_i;
        input   instr_funct3_i;
    endclocking : mon_cb

    clocking drv_cb @(posedge clk);
        default output #1ns;
        output  opr_a_i;
        output  opr_b_i;
        output  b_type_i;
        output  instr_funct3_i;
    endclocking : drv_cb

    clocking res_cb @(posedge clk);
        default input #1step;
        input   branch_taken_o;
    endclocking : res_cb

    modport MON (clocking mon_cb, input clk);
    modport DRV (clocking drv_cb, input clk);
    modport RES (clocking res_cb, input clk);

    modport DUT (
        input   opr_a_i,
        input   opr_b_i,
        input   b_type_i,
        input   instr_funct3_i,
        output  branch_taken_o
    );

endinterface : branch_control_if