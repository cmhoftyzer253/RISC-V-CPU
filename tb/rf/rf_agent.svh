class rf_agent extends uvm_agent;
    `uvm_component_utils(rf_agent)

    rf_agent_config         rf_agent_config_h;

    rf_sequencer            rf_sequencer_h;
    rf_driver               rf_driver_h;
    rf_command_monitor      rf_command_monitor_h;
    rf_result_monitor       rf_result_monitor_h;

    uvm_analysis_port #(rf_command_transaction)     cmd_mon_ap;
    uvm_analysis_port #(rf_result_transaction)      res_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (rf_agent_config_h == null)
            `uvm_fatal("AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(rf_agent_config)::get(this, "", "rf_agent_config", rf_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get rf_agent_config")
        
        if (rf_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            rf_sequencer_h  =   rf_sequencer::type_id::create("rf_sequencer_h", this);
            rf_driver_h     =   rf_driver::type_id::create("rf_driver_h", this);

            rf_driver_h.agent_config = rf_agent_config_h;
        end

        rf_command_monitor_h                =    rf_command_monitor::type_id::create("rf_command_monitor_h", this);
        rf_command_monitor_h.agent_config   =   rf_agent_config_h;
        rf_result_monitor_h                 =   rf_result_monitor::type_id::create("rf_result_monitor_h", this);
        rf_result_monitor_h.agent_config    =   rf_agent_config_h;

        cmd_mon_ap  =   new("cmd_mon_ap", this);
        res_ap      =   new("res_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (rf_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            rf_driver_h.seq_item_port.connect(rf_sequencer_h.seq_item_export);
        end

        rf_command_monitor_h.ap.connect(cmd_mon_ap);
        rf_result_monitor_h.ap.connect(res_ap);
    endfunction : connect_phase

endclass : rf_agent