class divide_command_agent extends uvm_agent;
    `uvm_component_utils(divide_command_agent)

    divide_command_agent_config     divide_command_agent_config_h;

    divide_command_sequencer        divide_command_sequencer_h;
    divide_command_driver           divide_command_driver_h;
    divide_command_monitor          divide_command_monitor_h;

    uvm_analysis_port #(divide_command_transaction)     cmd_mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (divide_command_agent_config_h == null)
            `uvm_fatal("COMMAND_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(divide_command_agent_config)::get(this, "", "divide_command_agent_config", divide_command_agent_config_h))
            `uvm_fatal("COMMAND_AGENT", "Failed to get divide_command_agent_config")

        if (divide_command_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_command_sequencer_h              =   divide_command_sequencer::type_id::create("divide_command_sequencer_h", this);
            divide_command_driver_h                 =   divide_command_driver::type_id::create("divide_command_driver_h", this);

            divide_command_driver_h.agent_config    =   divide_command_agent_config_h;
        end

        divide_command_monitor_h                    =   divide_command_monitor::type_id::create("divide_command_monitor_h", this);
        divide_command_monitor_h.agent_config       =   divide_command_agent_config_h;
        cmd_mon_ap                                  =   new("cmd_mon_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (divide_command_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_command_driver_h.seq_item_port.connect(divide_command_sequencer_h.seq_item_export);
        end

        divide_command_monitor_h.ap.connect(cmd_mon_ap);
    endfunction : connect_phase

endclass : divide_command_agent