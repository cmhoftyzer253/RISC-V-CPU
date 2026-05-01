class alu_base_test extends uvm_test;
    `uvm_component_utils(alu_base_test)

    alu_env         alu_env_h;
    alu_sequencer   alu_sequencer_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        alu_env_h = alu_env::type_id::create("alu_env_h", this);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        alu_sequencer_h = alu_env_h.alu_agent_h.alu_sequencer_h;
    endfunction : end_of_elaboration_phase

endclass : alu_base_test