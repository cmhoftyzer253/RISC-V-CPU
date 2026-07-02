module decode_tb_top;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import decode_tb_pkg::*;

    logic clk;

    decode_if decode_vif(clk);

    decode u_decode(
        .instr_i        (decode_vif.instr_i),
        .rs1_o          (decode_vif.rs1_o),
        .rs2_o          (decode_vif.rs2_o),
        .rd_o           (decode_vif.rd_o),
        .op_o           (decode_vif.op_o),
        .funct3_o       (decode_vif.funct3_o),
        .funct12_o      (decode_vif.funct12_o),
        .csr_addr_o     (decode_vif.csr_addr_o),
        .r_type_o       (decode_vif.r_type_o),
        .i_type_o       (decode_vif.i_type_o),
        .s_type_o       (decode_vif.s_type_o),
        .b_type_o       (decode_vif.b_type_o),
        .u_type_o       (decode_vif.u_type_o),
        .j_type_o       (decode_vif.j_type_o),
        .system_type_o  (decode_vif.system_type_o),
        .imm_o          (decode_vif.imm_o),
        .exc_valid_o    (decode_vif.exc_valid_o),
        .exc_code_o     (decode_vif.exc_code_o)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual decode_if)::set(null, "*", "decode_vif", decode_vif);
        run_test();
    end

endmodule : decode_tb_top