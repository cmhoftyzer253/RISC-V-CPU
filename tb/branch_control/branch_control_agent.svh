class branch_control_agent extends uvm_agent;
    `uvm_component_utils(branch_control_agent)

    branch_control_agent_config         branch_control_agent_config_h;

    branch_control_sequencer            branch_control_sequencer_h;
    branch_control_driver               branch_control_driver_h;
    branch_control_command_monitor      branch_control_command_monitor_h;
    branch_control_result_monitor       branch_control_result_monitor_h;

    uvm_analysis_port #(branch_control_command_transaction)     cmd_mon_ap;
    uvm_analysis_port #(branch_control_result_transaction)      res_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (branch_control_agent_config_h == null)
            `uvm_fatal("AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(branch_control_agent_config)::get(this, "", "branch_control_agent_config", branch_control_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get branch_control_agent_config")

        if (branch_control_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            branch_control_sequencer_h                  =   branch_control_sequencer::type_id::create("branch_control_sequencer_h", this);
            branch_control_driver_h                     =   branch_control_driver::type_id::create("branch_control_driver_h", this);

            branch_control_driver_h.agent_config        =   branch_control_agent_config_h;
        end

        branch_control_command_monitor_h                =   branch_control_command_monitor::type_id::create("branch_control_command_monitor_h", this);
        branch_control_command_monitor_h.agent_config   =   branch_control_agent_config_h;
        branch_control_result_monitor_h                 =   branch_control_result_monitor::type_id::create("branch_control_result_monitor_h", this);
        branch_control_result_monitor_h.agent_config    =   branch_control_agent_config_h;

        cmd_mon_ap  =   new("cmd_mon_ap", this);
        res_ap      =   new("res_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (branch_control_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            branch_control_driver_h.seq_item_port.connect(branch_control_sequencer_h.seq_item_export);
        end

        branch_control_command_monitor_h.ap.connect(cmd_mon_ap);
        branch_control_result_monitor_h.ap.connect(res_ap);
    endfunction : connect_phase

endclass : branch_control_agent