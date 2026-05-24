class alu_base_test extends uvm_test;
    `uvm_component_utils(alu_base_test)

    alu_env             alu_env_h;
    alu_agent_config    alu_agent_config_h;
    alu_sequencer       alu_sequencer_h;
    virtual alu_if      alu_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual alu_if)::get(this, "", "alu_vif", alu_vif))
            `uvm_fatal("BASE_TEST", "Failed to get alu_vif from config_db")

        alu_agent_config_h = alu_agent_config::type_id::create("alu_agent_config_h");
        alu_agent_config_h.set_alu_vif(alu_vif);
        alu_agent_config_h.set_is_active(UVM_ACTIVE);

        uvm_config_db #(alu_agent_config)::set(this, "*", "alu_agent_config", alu_agent_config_h);

        alu_env_h = alu_env::type_id::create("alu_env_h", this);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        alu_sequencer_h = alu_env_h.alu_agent_h.alu_sequencer_h;
    endfunction : end_of_elaboration_phase

endclass : alu_base_test