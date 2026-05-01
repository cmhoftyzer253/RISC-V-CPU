class alu_driver extends uvm_driver #(alu_command_transaction);
    `uvm_component_utils(alu_driver)

    virtual alu_if alu_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual alu_if)::get(null, "*", "alu_vif", alu_vif))
            `uvm_fatal("DRIVER", "Failed to get alu_vif");
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        alu_command_transaction instr;

        forever begin : instr_loop
            seq_item_port.get_next_item(instr);
            @(negedge alu_vif.clk);
            //drive alu_vif signals
            alu_vif.opr_a_i         <=   instr.opr_a_i;
            alu_vif.opr_b_i         <=   instr.opr_b_i;
            alu_vif.alu_valid_i     <=   instr.alu_valid_i;
            alu_vif.alu_func_i      <=   instr.alu_func_i;
            alu_vif.word_op_i       <=   instr.word_op_i;
            alu_vif.flush_i         <=   instr.flush_i;
            @(posedge alu_vif.clk);
            seq_item_port.item_done();
        end : instr_loop
    endtask : run_phase

endclass : alu_driver