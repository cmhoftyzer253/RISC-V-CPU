class branch_control_command_monitor extends uvm_component;
    `uvm_component_utils(branch_control_command_monitor)

    branch_control_agent_config                                 agent_config;
    uvm_analysis_port #(branch_control_command_transaction)     ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("COMMAND_MONITOR", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        branch_control_command_transaction cmd;
        virtual branch_control_if branch_control_vif = agent_config.get_vif();

        forever begin
            @(branch_control_vif.mon_cb);

            cmd = branch_control_command_transaction::type_id::create("cmd");
            
            cmd.opr_a_i         =   branch_control_vif.mon_cb.opr_a_i;
            cmd.opr_b_i         =   branch_control_vif.mon_cb.opr_b_i;
            cmd.b_type_i        =   branch_control_vif.mon_cb.b_type_i;
            cmd.instr_funct3_i  =   branch_control_vif.mon_cb.instr_funct3_i;

            `uvm_info("COMMAND_MONITOR", cmd.convert2string(), UVM_HIGH)
            ap.write(cmd);
        end
    endtask : run_phase

endclass : branch_control_command_monitor