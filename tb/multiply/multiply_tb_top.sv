module multiply_tb_top;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import multiply_tb_pkg::*;

    logic clk;

    multiply_if multiply_vif(clk);

    multiply u_multiply(
        .clk                (clk),
        .resetn             (multiply_vif.resetn),
        .opr_a_i            (multiply_vif.opr_a_i),
        .opr_b_i            (multiply_vif.opr_b_i),
        .mul_valid_i        (multiply_vif.mul_valid_i),
        .mul_func_i         (multiply_vif.mul_func_i),
        .word_op_i          (multiply_vif.word_op_i),
        .mul_ready_o        (multiply_vif.mul_ready_o),
        .flush_i            (multiply_vif.flush_i),
        .mul_res_ready_i    (multiply_vif.mul_res_ready_i),
        .mul_res_o          (multiply_vif.mul_res_o),
        .mul_res_valid_o    (multiply_vif.mul_res_valid_o)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual multiply_if)::set(null, "*", "multiply_vif", multiply_vif);
        run_test();
    end

endmodule : multiply_tb_top