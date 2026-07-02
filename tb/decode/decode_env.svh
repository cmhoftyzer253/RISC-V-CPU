class decode_env extends uvm_env;
    `uvm_component_utils(decode_env)

    virtual decode_if       decode_vif;

    decode_agent            decode_agent_h;
    decode_scoreboard       decode_scoreboard_h;
    decode_coverage         decode_coverage_h;
    decode_agent_config     decode_agent_config_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual decode_if)::get(this, "", "decode_vif", decode_vif))
            `uvm_fatal("ENV", "Failed to get decode_vif")

        decode_agent_config_h = decode_agent_config::type_id::create("decode_agent_config_h");
        decode_agent_config_h.set_vif(decode_vif);

        uvm_config_db #(decode_agent_config)::set(this, "decode_agent_h*", "decode_agent_config", decode_agent_config_h);

        decode_agent_h          =   decode_agent::type_id::create("decode_agent_h", this);
        decode_scoreboard_h     =   decode_scoreboard::type_id::create("decode_scoreboard_h", this);
        decode_coverage_h       =   decode_coverage::type_id::create("decode_coverage_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        decode_agent_h.cmd_mon_ap.connect(decode_scoreboard_h.cmd_export);
        decode_agent_h.res_ap.connect(decode_scoreboard_h.res_export);
        decode_agent_h.cmd_mon_ap.connect(decode_coverage_h.cmd_export);
    endfunction : connect_phase

endclass : decode_env