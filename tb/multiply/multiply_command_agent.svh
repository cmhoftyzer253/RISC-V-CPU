class multiply_command_agent extends uvm_agent;
    `uvm_component_utils(multiply_command_agent)

    multiply_command_agent_config   multiply_command_agent_config_h;

    multiply_command_sequencer      multiply_command_sequencer_h;
    multiply_command_driver         multiply_command_driver_h;
    multiply_command_monitor        multiply_command_monitor_h;
    
    uvm_analysis_port #(multiply_command_transaction)   cmd_mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (multiply_command_agent_config_h == null)
            `uvm_fatal("COMMAND_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(multiply_command_agent_config)::get(this, "", "multiply_command_agent_config", multiply_command_agent_config_h))
            `uvm_fatal("COMMAND_AGENT", "Failed to get multiply_command_agent_config")

        if (multiply_command_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_command_sequencer_h            =   multiply_command_sequencer::type_id::create("multiply_command_sequencer_h", this);
            multiply_command_driver_h               =   multiply_command_driver::type_id::create("multiply_command_driver_h", this);

            multiply_command_driver_h.agent_config  =   multiply_command_agent_config_h;
        end

        multiply_command_monitor_h                  =   multiply_command_monitor::type_id::create("multiply_command_monitor_h", this);
        multiply_command_monitor_h.agent_config     =   multiply_command_agent_config_h;
        cmd_mon_ap                                  =   new("cmd_mon_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (multiply_command_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_command_driver_h.seq_item_port.connect(multiply_command_sequencer_h.seq_item_export);
        end

        multiply_command_monitor_h.ap.connect(cmd_mon_ap);
    endfunction : connect_phase

endclass : multiply_command_agent