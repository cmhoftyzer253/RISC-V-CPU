class branch_control_env extends uvm_env;
    `uvm_component_utils(branch_control_env)

    virtual branch_control_if           branch_control_vif;

    branch_control_agent                branch_control_agent_h;
    branch_control_scoreboard           branch_control_scoreboard_h;
    branch_control_coverage             branch_control_coverage_h;
    branch_control_agent_config         branch_control_agent_config_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual branch_control_if)::get(this, "", "branch_control_vif", branch_control_vif))
            `uvm_fatal("ENV", "Failed to get branch_control_vif")
        
        branch_control_agent_config_h = branch_control_agent_config::type_id::create("branch_control_agent_config_h");
        branch_control_agent_config_h.set_vif(branch_control_vif);

        uvm_config_db #(branch_control_agent_config)::set(this, "branch_control_agent_h*", "branch_control_agent_config", branch_control_agent_config);

        branch_control_agent_h              =   branch_control_agent::type_id::create("branch_control_agent_h", this);
        branch_control_scoreboard_h         =   branch_control_scoreboard::type_id::create("branch_control_scoreboard_h", this);
        branch_control_coverage_h           =   branch_control_coverage::type_id::create("branch_control_coverage_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect(phase);

        branch_control_agent_h.cmd_mon_ap.connect(branch_control_scoreboard_h.cmd_export);
        branch_control_agent_h.res_ap.connect(branch_control_scoreboard_h.res_export);
        branch_control_agent_h.cmd_mon_ap.connect(branch_control_coverage_h.cmd_export);
    endfunction : connect_phase

endclass : branch_control_env