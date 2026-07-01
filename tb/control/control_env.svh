class control_env extends uvm_env;
    `uvm_component_utils(control_env)

    virtual control_if      control_vif;

    control_agent           control_agent_h;
    control_scoreboard      control_scoreboard_h;
    control_coverage        control_coverage_h;
    control_agent_config    control_agent_config_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual control_if)::get(this, "", "control_vif", control_vif))
            `uvm_fatal("ENV", "Failed to get control_vif")

        control_agent_config_h = control_agent_config::type_id::create("control_agent_config_h");
        control_agent_config_h.set_vif(control_vif);

        uvm_config_db #(control_agent_config)::set(this, "control_agent_h*", "control_agent_config", control_agent_config_h);

        control_agent_h         =   control_agent::type_id::create("control_agent_h", this);
        control_scoreboard_h    =   control_scoreboard::type_id::create("control_scoreboard_h", this);
        control_coverage_h      =   control_coverage::type_id::create("control_coverage_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        control_agent_h.cmd_mon_ap.connect(control_scoreboard_h.cmd_export);
        control_agent_h.res_ap.connect(control_scoreboard_h.res_export);
        control_agent_h.cmd_mon_ap.connect(control_coverage_h.cmd_export);
    endfunction : connect_phase

endclass : control_env