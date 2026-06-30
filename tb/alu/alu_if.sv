interface alu_if (
    input logic clk
);

    import cpu_consts::*;

    logic [63:0]    opr_a_i         =   '0;
    logic [63:0]    opr_b_i         =   '0;
    logic           alu_valid_i     =   '0;
    alu_op_t        alu_func_i      =   OP_ADD;
    logic           word_op_i       =   '0;
    logic           flush_i         =   '0;
    
    logic           valid_res_o;
    logic [63:0]    alu_res_o;

    clocking mon_cb @(posedge clk);
        default input #1step;
        input opr_a_i;
        input opr_b_i;
        input alu_valid_i;
        input alu_func_i;
        input word_op_i;
        input flush_i;
    endclocking : mon_cb

    clocking drv_cb @(posedge clk);
        default output #1ns;
        output opr_a_i;
        output opr_b_i;
        output alu_valid_i;
        output alu_func_i;
        output word_op_i;
        output flush_i;
    endclocking : drv_cb

    clocking res_cb @(posedge clk);
        default input #1step;
        input valid_res_o;
        input alu_res_o;
    endclocking : res_cb

    modport MON (clocking mon_cb, input clk);
    modport DRV (clocking drv_cb, input clk);
    modport RES (clocking res_cb, input clk);

    modport DUT (
        input   opr_a_i,
        input   opr_b_i,
        input   alu_valid_i,
        input   alu_func_i,
        input   word_op_i,
        input   flush_i,
        output  valid_res_o,
        output  alu_res_o
    );

endinterface