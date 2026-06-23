class multiply_reset_agent extends uvm_agent;
    `uvm_component_utils(multiply_reset_agent)

    multiply_reset_agent_config     multiply_reset_agent_config_h;

    multiply_reset_sequencer        multiply_reset_sequencer_h;
    multiply_reset_driver           multiply_reset_driver_h;
    multiply_reset_monitor          multiply_reset_monitor_h;

    uvm_analysis_port #(multiply_reset_transaction)     reset_mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (multiply_reset_agent_config_h == null)
            `uvm_fatal("RESET_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(multiply_reset_agent_config)::get(this, "", "multiply_reset_agent_config", multiply_reset_agent_config_h))
            `uvm_fatal("RESET_AGENT", "Failed to get multiply_reset_agent_config")

        if (multiply_reset_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_reset_sequencer_h              =   multiply_reset_sequencer::type_id::create("multiply_reset_sequencer_h", this);
            multiply_reset_driver_h                 =   multiply_reset_driver::type_id::create("multiply_reset_driver_h", this);

            multiply_reset_driver_h.agent_config    =   multiply_reset_agent_config_h;
        end

        multiply_reset_monitor_h                =   multiply_reset_monitor::type_id::create("multiply_reset_monitor_h", this);
        multiply_reset_monitor_h.agent_config   =   multiply_reset_agent_config_h;
        reset_mon_ap                            =   new("reset_mon_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (multiply_reset_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_reset_driver_h.seq_item_port.connect(multiply_reset_sequencer_h.seq_item_export);
        end

        multiply_reset_monitor_h.ap.connect(reset_mon_ap);
    endfunction : connect_phase

endclass : multiply_reset_agent