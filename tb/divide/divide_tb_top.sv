module divide_tb_top;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import divide_tb_pkg::*;

    logic clk;

    divide_if divide_vif(clk);

    divide u_divide(
        .clk                (clk),
        .resetn             (divide_vif.resetn),
        .opr_a_i            (divide_vif.opr_a_i),
        .opr_b_i            (divide_vif.opr_b_i),
        .div_valid_i        (divide_vif.div_valid_i),
        .div_func_i         (divide_vif.div_func_i),
        .word_op_i          (divide_vif.word_op_i),
        .div_ready_o        (divide_vif.div_ready_o),
        .flush_i            (divide_vif.flush_i),
        .div_res_ready_i    (divide_vif.div_res_ready_i),
        .div_res_o          (div_res_o),
        .div_res_valid_o    (divide_vif.div_res_valid_o)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual divide_if)::set(null, "*", "divide_vif", divide_vif);
        run_test();
    end

endmodule : divide_tb_top