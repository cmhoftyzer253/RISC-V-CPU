module alu_tb_top;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import alu_tb_pkg::*;

    logic clk;

    alu_if alu_vif(clk);

    alu u_alu (
        .opr_a_i        (alu_vif.opr_a_i),
        .opr_b_i        (alu_vif.opr_b_i),
        .alu_valid_i    (alu_vif.alu_valid_i),
        .alu_func_i     (alu_vif.alu_func_i),
        .word_op_i      (alu_vif.word_op_i),
        .flush_i        (alu_vif.flush_i),
        .valid_res_o    (alu_vif.valid_res_o),
        .alu_res_o      (alu_vif.alu_res_o)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual alu_if)::set(null, "*", "alu_vif", alu_vif);
        run_test();
    end

    initial begin
        $dumpfile("alu_tb_top.vcd");
        $dumpvars(0, alu_tb_top);
    end

endmodule : alu_tb_top