class branch_control_driver extends uvm_driver #(branch_control_command_transaction);
    `uvm_component_utils(branch_control_driver)

    branch_control_agent_config         agent_config;
    branch_control_command_transaction  cmd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual branch_control_if branch_control_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(cmd);

            @(branch_control_vif.drv_cb);
            branch_control_vif.drv_cb.opr_a_i           <=  cmd.opr_a_i;
            branch_control_vif.drv_cb.opr_b_i           <=  cmd.opr_b_i;
            branch_control_vif.drv_cb.b_type_i          <=  cmd.b_type_i;
            branch_control_vif.drv_cb.instr_funct3_i    <=  cmd.instr_funct3_i;

            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : branch_control_driver