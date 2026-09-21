interface divide_if (
    input logic clk
);

    import cpu_consts::*;

    logic           resetn;

    logic [63:0]    opr_a_i;
    logic [63:0]    opr_b_i;

    logic           div_valid_i;
    r_type_m_t      div_func_i;
    logic           word_op_i;
    logic           div_ready_o;

    logic           flush_i;
    
    logic           div_res_ready_i;
    logic [63:0]    div_res_o;
    logic           div_res_valid_o;

    clocking drv_cb @(posedge clk);
        default output #1ns;
        output  opr_a_i;
        output  opr_b_i;
        inout   div_valid_i;
        output  div_func_i;
        output  word_op_i;
        output  flush_i;
        input   div_ready_o;
    endclocking : drv_cb

    clocking ready_cb @(posedge clk);
        default input #1step output #1ns;
        input   div_ready_o;
        inout   div_res_ready_i;
        input   div_res_valid_o;
    endclocking : ready_cb

    clocking flush_cb @(posedge clk);
        default output #1ns;
        output  flush_i;
    endclocking : flush_cb

    clocking reset_cb @(posedge clk);
        default output #1ns;
        output  resetn;
    endclocking : reset_cb

    clocking mon_cb @(posedge clk);
        default input #1step;
        input   opr_a_i;
        input   opr_b_i;
        input   div_valid_i;
        input   div_func_i;
        input   word_op_i;
        input   flush_i;
        input   div_ready_o;
    endclocking : mon_cb

    clocking res_cb @(posedge clk);
        default input #1step;
        input   div_res_ready_i;
        input   div_res_o;
        input   div_res_valid_o;
    endclocking : res_cb

    clocking flush_mon_cb @(posedge clk);
        default input #1step;
        input   flush_i;
    endclocking : flush_mon_cb

    modport DRV         (clocking drv_cb,           input clk);
    modport READY       (clocking ready_cb,         input clk);
    modport FLUSH       (clocking flush_cb,         input clk);
    modport RESET       (clocking reset_cb,         input clk);
    modport MON         (clocking mon_cb,           input clk);
    modport RESULT_MON  (clocking res_cb,           input clk);
    modport FLUSH_MON   (clocking flush_mon_cb,     input clk);

    modport DUT(
        input   resetn,
        input   opr_a_i,
        input   opr_b_i,
        input   div_valid_i,
        input   div_func_i,
        input   word_op_i,
        output  div_ready_o,
        input   flush_i,
        output  div_res_ready_i,
        output  div_res_o,
        output  div_res_valid_o
    );

endinterface : divide_if