class divide_env extends uvm_env;
    `uvm_component_utils(divide_env)

    virtual divide_if divide_vif;

    divide_command_agent            divide_command_agent_h;
    divide_result_agent             divide_result_agent_h;
    divide_flush_agent              divide_flush_agent_h;
    divide_reset_agent              divide_reset_agent_h;
    divide_scoreboard               divide_scoreboard_h;

    divide_command_agent_config     cmd_config;
    divide_result_agent_config      res_config;
    divide_flush_agent_config       flush_config;
    divide_reset_agent_config       reset_config;

    divide_virtual_sequencer        divide_virtual_sequencer_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual divide_if)::get(this, "", "divide_vif", divide_vif))
            `uvm_fatal("ENV", "Failed to get divide_vif")

        cmd_config      =   divide_command_agent_config::type_id::create("cmd_config");
        res_config      =   divide_result_agent_config::type_id::create("res_config");
        flush_config    =   divide_flush_agent_config::type_id::create("flush_config");
        reset_config    =   divide_reset_agent_config::type_id::create("reset_config");

        cmd_config.set_vif(divide_vif);
        res_config.set_vif(divide_vif);
        flush_config.set_vif(divide_vif);
        reset_config.set_vif(divide_vif);

        uvm_config_db #(divide_command_agent_config)::set(this, "divide_command_agent_h*", "divide_command_agent_config", cmd_config);
        uvm_config_db #(divide_result_agent_config)::set(this, "divide_result_agent_h*", "divide_result_agent_config", res_config);
        uvm_config_db #(divide_flush_agent_config)::set(this, "divide_flush_agent_h*", "divide_flush_agent_config", flush_config);
        uvm_config_db #(divide_reset_agent_config)::set(this, "divide_reset_agent_h*", "divide_reset_agent_config", reset_config);

        divide_virtual_sequencer_h  =   divide_virtual_sequencer::type_id::create("divide_virtual_sequencer_h", this);

        divide_command_agent_h      =   divide_command_agent::type_id::create("divide_command_agent_h", this);
        divide_result_agent_h       =   divide_result_agent::type_id::create("divide_result_agent_h", this);
        divide_flush_agent_h        =   divide_flush_agent::type_id::create("divide_flush_agent_h", this);
        divide_reset_agent_h        =   divide_reset_agent::type_id::create("divide_reset_agent_h", this);
        divide_scoreboard_h         =   divide_scoreboard::type_id::create("divide_scoreboard_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        divide_command_agent_h.cmd_mon_ap.connect(divide_scoreboard_h.cmd_export);
        divide_result_agent_h.res_ap.connect(divide_scoreboard_h.res_export);
        divide_flush_agent_h.flush_mon_ap.connect(divide_scoreboard_h.flush_export);
        divide_reset_agent_h.reset_mon_ap.connect(divide_scoreboard_h.reset_export);

        divide_virtual_sequencer_h.cmd_sequencer    =   divide_command_agent_h.divide_command_sequencer_h;
        divide_virtual_sequencer_h.ready_sequencer  =   divide_result_agent_h.divide_ready_sequencer_h;
        divide_virtual_sequencer_h.flush_sequencer  =   divide_flush_agent_h.divide_flush_sequencer_h;
        divide_virtual_sequencer_h.reset_sequencer  =   divide_reset_agent_h.divide_reset_sequencer_h;
    endfunction : connect_phase

endclass : divide_env