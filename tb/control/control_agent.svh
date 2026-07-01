class control_agent extends uvm_agent;
    `uvm_component_utils(control_agent)

    control_agent_config        control_agent_config_h;

    control_sequencer           control_sequencer_h;
    control_driver              control_driver_h;
    control_command_monitor     control_command_monitor_h;
    control_result_monitor      control_result_monitor_h;

    uvm_analysis_port #(control_command_transaction)    cmd_mon_ap;
    uvm_analysis_port #(control_result_transaction)     res_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (control_agent_config_h == null)
            `uvm_fatal("AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(control_agent_config)::get(this, "", "control_agent_config", control_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get control_agent_config")
        

        if (control_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            control_sequencer_h                 =   control_sequencer::type_id::create("control_sequencer_h", this);
            control_driver_h                    =   control_driver::type_id::create("control_driver_h", this);

            control_driver_h.agent_config       =   control_agent_config_h;
        end

        control_command_monitor_h               =   control_command_monitor::type_id::create("control_command_monitor_h", this);
        control_command_monitor_h.agent_config  =   control_agent_config_h;
        control_result_monitor_h                =   control_result_monitor::type_id::create("control_result_monitor_h", this);
        control_result_monitor_h.agent_config   =   control_agent_config_h;

        cmd_mon_ap  =   new("cmd_mon_ap", this);
        res_ap      =   new("res_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (control_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            control_driver_h.seq_item_port.connect(control_sequencer_h.seq_item_export);
        end

        control_command_monitor_h.ap.connect(cmd_mon_ap);
        control_result_monitor_h.ap.connect(res_ap);
    endfunction : connect_phase

endclass : control_agent