module branch_control_tb_top;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import branch_control_tb_pkg::*;

    logic clk;

    branch_control_if branch_control_vif(clk);

    branch_control u_branch_control (
        .opr_a_i            (branch_control_vif.opr_a_i),
        .opr_b_i            (branch_control_vif.opr_b_i),
        .b_type_i           (branch_control_vif.b_type_i),
        .instr_funct3_i     (branch_control_vif.instr_funct3_i),
        .branch_taken_o     (branch_control_vif.branch_taken_o)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual branch_control_if)::set(this, "*", "branch_control_vif", branch_control_vif);
        run_test();
    end

endmodule : branch_control_tb_top