class divide_flush_agent extends uvm_agent;
    `uvm_component_utils(divide_flush_agent)

    divide_flush_agent_config   divide_flush_agent_config_h;

    divide_flush_sequencer      divide_flush_sequencer_h;
    divide_flush_driver         divide_flush_driver_h;
    divide_flush_monitor        divide_flush_monitor_h;

    uvm_analysis_port #(divide_flush_transaction)   flush_mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (divide_flush_agent_config_h == null)
            `uvm_fatal("FLUSH_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(divide_flush_agent_config)::get(this, "", "divide_flush_agent_config", divide_flush_agent_config_h))
            `uvm_fatal("FLUSH_AGENT", "Failed to get divide_flush_agent_config")

        if (divide_flush_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_flush_sequencer_h            =   divide_flush_sequencer::type_id::create("divide_flush_sequencer_h", this);
            divide_flush_driver_h               =   divide_flush_driver::type_id::create("divide_flush_driver_h", this);

            divide_flush_driver_h.agent_config  =   divide_flush_agent_config_h;
        end

        divide_flush_monitor_h                  =   divide_flush_monitor::type_id::create("divide_flush_monitor_h", this);
        divide_flush_monitor_h.agent_config     =   divide_flush_agent_config_h;
        flush_mon_ap                            =   new("flush_mon_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (divide_flush_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_flush_driver_h.seq_item_port.connect(divide_flush_sequencer_h.seq_item_export);
        end

        divide_flush_monitor_h.ap.connect(flush_mon_ap);
    endfunction : connect_phase

endclass : divide_flush_agent