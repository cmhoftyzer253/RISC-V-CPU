class alu_driver extends uvm_driver #(alu_command_transaction);
    `uvm_component_utils(alu_driver)

    virtual alu_if alu_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual alu_if)::get(this, "", "alu_vif", alu_vif))
            `uvm_fatal("DRIVER", "Failed to get alu_vif")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        alu_command_transaction cmd;

        forever begin : drive_loop
            seq_item_port.get_next_item(cmd);
            @(alu_vif.drv_cb);
            alu_vif.drv_cb.opr_a_i         <=   cmd.opr_a_i;
            alu_vif.drv_cb.opr_b_i         <=   cmd.opr_b_i;
            alu_vif.drv_cb.alu_valid_i     <=   cmd.alu_valid_i;
            alu_vif.drv_cb.alu_func_i      <=   cmd.alu_func_i;
            alu_vif.drv_cb.word_op_i       <=   cmd.word_op_i;
            alu_vif.drv_cb.flush_i         <=   cmd.flush_i;
            seq_item_port.item_done();
        end : drive_loop
    endtask : run_phase

endclass : alu_driver