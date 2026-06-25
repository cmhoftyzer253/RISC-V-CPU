class rf_reset_agent extends uvm_agent;
    `uvm_component_utils(rf_reset_agent)

    rf_reset_agent_config   rf_reset_agent_config_h;

    rf_reset_sequencer      rf_reset_sequencer_h;
    rf_reset_driver         rf_reset_driver_h;
    rf_reset_monitor        rf_reset_monitor_h;

    uvm_analysis_port #(rf_reset_transaction)   reset_mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (rf_reset_agent_config_h == null)
            `uvm_fatal("RESET_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(rf_reset_agent_config)::get(this, "", "rf_reset_agent_config", rf_reset_agent_config_h))
            `uvm_fatal("RESET_AGENT", "Failed to get rf_reset_agent_config")
        
        if (rf_reset_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            rf_reset_sequencer_h            =   rf_reset_sequencer::type_id::create("rf_reset_sequencer_h", this);
            rf_reset_driver_h               =   rf_reset_driver::type_id::create("rf_reset_driver_h", this);

            rf_reset_driver_h.agent_config  =   rf_reset_agent_config_h;
        end

        rf_reset_monitor_h                  =   rf_reset_monitor::type_id::create("rf_reset_monitor_h", this);
        rf_reset_monitor_h.agent_config     =   rf_reset_agent_config_h;
        reset_mon_ap                        =   new("reset_mon_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (rf_reset_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            rf_reset_driver_h.seq_item_port.connect(rf_reset_sequencer_h.seq_item_export);
        end

        rf_reset_monitor_h.ap.connect(reset_mon_ap);
    endfunction : connect_phase

endclass : rf_reset_agent