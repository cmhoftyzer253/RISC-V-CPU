class alu_driver extends uvm_driver #(alu_command_transaction);
    `uvm_component_utils(alu_driver)

    alu_agent_config            agent_config;
    alu_command_transaction     cmd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual alu_if alu_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(cmd);
            `uvm_info("DRIVER", "get_next_item from port completed", UVM_HIGH)

            @(alu_vif.drv_cb);
            alu_vif.drv_cb.opr_a_i      <=  cmd.opr_a_i;
            alu_vif.drv_cb.opr_b_i      <=  cmd.opr_b_i;
            alu_vif.drv_cb.alu_valid_i  <=  cmd.alu_valid_i;
            alu_vif.drv_cb.alu_func_i   <=  cmd.alu_func_i;
            alu_vif.drv_cb.word_op_i    <=  cmd.word_op_i;
            alu_vif.drv_cb.flush_i      <=  cmd.flush_i;

            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : alu_driver