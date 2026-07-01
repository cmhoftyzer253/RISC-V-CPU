module control_tb_top;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import control_tb_pkg::*;

    logic clk;

    control_if control_vif(clk);

    control u_control(
        .r_type_i           (control_vif.r_type_i),
        .i_type_i           (control_vif.i_type_i),
        .s_type_i           (control_vif.s_type_i),
        .b_type_i           (control_vif.b_type_i),
        .u_type_i           (control_vif.i_type_i),
        .j_type_i           (control_vif.j_type_i),
        .system_type_i      (control_vif.system_type_i),
        .instr_funct3_i     (control_vif.instr_funct3_i),
        .instr_funct12_i    (control_vif.instr_funct12_i),
        .instr_opcode_i     (control_vif.instr_opcode_i),
        .pc_sel_o           (control_vif.pc_sel_o),
        .exu_func_sel_o     (control_vif.exu_func_sel_o),
        .rd_src_o           (control_vif.rd_src_o),
        .csr_en_o           (control_vif.csr_en_o),
        .csr_rw_o           (control_vif.csr_rw_o),
        .data_req_o         (control_vif.data_req_o),
        .data_byte_o        (control_vif.data_byte_o),
        .bypass_avail_o     (control_vif.bypass_avail_o),
        .data_wr_o          (control_vif.data_wr_o), 
        .zero_extnd_o       (control_vif.zero_extnd_o),
        .rf_wr_en_o         (control_vif.rf_wr_en_o),
        .word_op_o          (control_vif.word_op_o),
        .alu_instr_o        (control_vif.alu_instr_o),
        .mul_instr_o        (control_vif.mul_instr_o),
        .div_instr_o        (control_vif.div_instr_o),
        .mret_o             (control_vif.mret_o),
        .wfi_o              (control_vif.wfi_o),
        .exc_valid_o        (control_vif.exc_valid_o),
        .exc_code_o         (control_vif.exc_code_o)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual control_if)::set(null, "*", "control_vif", control_vif);
        run_test();
    end

endmodule : control_tb_top