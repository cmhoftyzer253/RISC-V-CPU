class multiply_env extends uvm_env;
    `uvm_component_utils(multiply_env)

    virtual multiply_if             multiply_vif;

    multiply_command_agent          multiply_command_agent_h;
    multiply_result_agent           multiply_result_agent_h;

    multiply_command_agent_config   cmd_config;
    multiply_result_agent_config    res_config;

    multiply_virtual_sequencer      multiply_virtual_sequencer_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual multiply_if)::get(this, "", "multiply_vif", multiply_vif))
            `uvm_fatal("ENV", "Failed to get multiply_vif")

        cmd_config = multiply_command_agent_config::type_id::create("cmd_config");
        res_config = multiply_result_agent_config::type_id::create("res_config");

        cmd_config.set_vif(multiply_vif);
        res_config.set_vif(multiply_vif);

        uvm_config_db #(multiply_command_agent_config)::set(this, "multiply_command_agent_h*", "multiply_command_agent_config", cmd_config);
        uvm_config_db #(multiply_result_agent_config)::set(this, "multiply_result_agent_h*", "multiply_result_agent_config", res_config);

        multiply_virtual_sequencer_h    =   multiply_virtual_sequencer::type_id::create("multiply_virtual_sequencer_h", this);

        multiply_command_agent_h        =   multiply_command_agent::type_id::create("multiply_command_agent_h", this);
        multiply_result_agent_h         =   multiply_result_agent::type_id::create("multiply_result_agent_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        multiply_virtual_sequencer_h.cmd_sequencer      =   multiply_command_agent_h.multiply_command_sequencer_h;
        multiply_virtual_sequencer_h.ready_sequencer    =   multiply_result_agent_h.multiply_ready_sequencer_h;
    endfunction : connect_phase

endclass : multiply_env