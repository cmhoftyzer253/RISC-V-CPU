class control_driver extends uvm_driver #(control_command_transaction);
    `uvm_component_utils(control_driver)

    control_agent_config            agent_config;
    control_command_transaction     cmd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual control_if control_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(cmd);

            `uvm_info("DRV", $sformatf("cmd.r=%b cmd.u=%b", cmd.r_type_i, cmd.u_type_i), UVM_LOW)

            @(control_vif.drv_cb);
            control_vif.drv_cb.r_type_i         <=  cmd.r_type_i;
            control_vif.drv_cb.i_type_i         <=  cmd.i_type_i;
            control_vif.drv_cb.s_type_i         <=  cmd.s_type_i;
            control_vif.drv_cb.b_type_i         <=  cmd.b_type_i;
            control_vif.drv_cb.u_type_i         <=  cmd.u_type_i;
            control_vif.drv_cb.j_type_i         <=  cmd.j_type_i;
            control_vif.drv_cb.system_type_i    <=  cmd.system_type_i;
            control_vif.drv_cb.instr_funct3_i   <=  cmd.instr_funct3_i;
            control_vif.drv_cb.instr_funct12_i  <=  cmd.instr_funct12_i;
            control_vif.drv_cb.instr_opcode_i   <=  cmd.instr_opcode_i;

            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : control_driver