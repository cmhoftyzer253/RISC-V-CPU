class divide_reset_agent extends uvm_agent;
    `uvm_component_utils(divide_reset_agent)

    divide_reset_agent_config   divide_reset_agent_config_h;

    divide_reset_sequencer      divide_reset_sequencer_h;
    divide_reset_driver         divide_reset_driver_h;
    divide_reset_monitor        divide_reset_monitor_h;

    uvm_analysis_port #(divide_reset_transaction)   reset_mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (divide_reset_agent_config_h.get_is_active() == UVM_ACTIVE)
            `uvm_fatal("RESET_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(divide_reset_agent_config)::get(this, "" "divide_reset_agent_config", divide_reset_agent_config_h))
            `uvm_fatal("RESET_AGENT", "Failed to get divide_reset_agent_config")

        if (divide_reset_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_reset_sequencer_h            =   divide_reset_sequencer::type_id::create("divide_reset_sequencer_h", this);
            divide_reset_driver_h               =   divide_reset_driver::type_id::create("divide_reset_driver_h", this);

            divide_reset_driver_h.agent_config  =   divide_reset_agent_config_h;
        end

        divide_reset_monitor_h                  =   divide_reset_monitor::type_id::create("divide_reset_monitor_h", this);
        divide_reset_monitor_h.agent_config     =   divide_reset_agent_config_h;
        reset_mon_ap                            =   new("reset_mon_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (divide_reset_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_reset_driver_h.seq_item_port.connect(divide_reset_sequencer_h.seq_item_export);
        end

        divide_reset_monitor_h.ap.connect(reset_mon_ap);
    endfunction : connect_phase

endclass : divide_reset_agent