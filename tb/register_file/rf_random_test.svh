class rf_random_test extends uvm_test;
    `uvm_component_utils(rf_random_test)

    rf_env env;

    function new(string name, uvm_component parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        rf_virtual_sequence virtual_sequence;
        virtual_sequence = rf_virtual_sequence::type_id::create("virtual_sequence");

        phase.raise_objection(this);
        virtual_sequence.start(env.rf_virtual_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : rf_random_test