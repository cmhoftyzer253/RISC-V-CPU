module rf_tb_top;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import rf_tb_pkg::*;

    logic clk;

    rf_if rf_vif(clk);

    register_file u_register_file(
        .clk            (clk),
        .resetn         (rf_vif.resetn),
        .rs1_addr_i     (rf_vif.rs1_addr_i),
        .rs2_addr_i     (rf_vif.rs2_addr_i),
        .rs1_data_o     (rf_vif.rs1_data_o),
        .rs2_data_o     (rf_vif.rs2_data_o),
        .rd_addr_i      (rf_vif.rd_addr_i),
        .wr_en_i        (rf_vif.wr_en_i),
        .wr_data_i      (rf_vif.wr_data_i)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        uvm_config_db #(virtual rf_if)::set(null, "*", "rf_vif", rf_vif);
        run_test();
    end

endmodule : rf_tb_top