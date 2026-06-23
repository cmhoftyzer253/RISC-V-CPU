class multiply_flush_agent extends uvm_agent;
    `uvm_component_utils(multiply_flush_agent)

    multiply_flush_agent_config     multiply_flush_agent_config_h;

    multiply_flush_sequencer        multiply_flush_sequencer_h;
    multiply_flush_driver           multiply_flush_driver_h;
    multiply_flush_monitor          multiply_flush_monitor_h;

    uvm_analysis_port #(multiply_flush_transaction)     flush_mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (multiply_flush_agent_config_h == null)
            `uvm_fatal("FLUSH_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(multiply_flush_agent_config)::get(this, "", "multiply_flush_agent_config", multiply_flush_agent_config_h))
            `uvm_fatal("FLUSH_AGENT", "Failed to get multiply_flush_agent_config")

        if (multiply_flush_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_flush_sequencer_h              =   multiply_flush_sequencer::type_id::create("multiply_flush_sequencer_h", this);
            multiply_flush_driver_h                 =   multiply_flush_driver::type_id::create("multiply_flush_driver_h", this);

            multiply_flush_driver_h.agent_config    =   multiply_flush_agent_config_h;
        end

        multiply_flush_monitor_h                    =   multiply_flush_monitor::type_id::create("multiply_flush_monitor_h", this);
        multiply_flush_monitor_h.agent_config       =   multiply_flush_agent_config_h;
        flush_mon_ap                                =   new("flush_mon_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (multiply_flush_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_flush_driver_h.seq_item_port.connect(multiply_flush_sequencer_h.seq_item_export);
        end

        multiply_flush_monitor_h.ap.connect(flush_mon_ap);
    endfunction : connect_phase

endclass : multiply_flush_agent