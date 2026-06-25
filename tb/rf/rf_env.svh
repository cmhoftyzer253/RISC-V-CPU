class rf_env extends uvm_env;
    `uvm_component_utils(rf_env)

    virtual rf_if           rf_vif;

    rf_agent                rf_agent_h;
    rf_reset_agent          rf_reset_agent_h;

    rf_agent_config         rf_config;
    rf_reset_agent_config   reset_config;

    rf_virtual_sequencer    rf_virtual_sequencer_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual rf_if)::get(this, "", "rf_vif", rf_vif))
            `uvm_fatal("ENV", "Failed to get rf_vif")

        rf_config       =   rf_agent_config::type_id::create("rf_config");
        reset_config    =   rf_reset_agent_config::type_id::create("reset_config");

        rf_config.set_vif(rf_vif);
        reset_config.set_vif(rf_vif);

        uvm_config_db #(rf_agent_config)::set(this, "rf_agent_config_h*", "rf_agent_config", rf_config);
        uvm_config_db #(rf_reset_agent_config)::set(this, "rf_reset_agent_config_h*", "rf_reset_agent_config", reset_config);

        rf_virtual_sequencer_h = rf_virtual_sequencer::type_id::create("rf_virtual_sequencer_h", this);

        rf_agent_h          =   rf_agent::type_id::create("rf_agent_h", this);
        rf_reset_agent_h    =   rf_reset_agent::type_id::create("rf_reset_agent_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        rf_agent_h.rf_command_monitor_h.ap.connect(rf_scoreboard_h.cmd_fifo.analysis_export);
        rf_agent_h.rf_result_monitor_h.ap.connect(rf_scoreboard_h.res_fifo.analysis_export);
        rf_reset_agent_h.rf_reset_monitor_h.ap.connect(rf_scoreboard_h.reset_fifo.analysis_export);

        rf_virtual_sequencer_h.cmd_sequencer    =   rf_agent_h.rf_sequencer_h;
        rf_virtual_sequencer_h.reset_sequencer  =   rf_reset_agent_h.rf_reset_sequencer_h;
    endfunction : connect_phase

endclass : rf_env