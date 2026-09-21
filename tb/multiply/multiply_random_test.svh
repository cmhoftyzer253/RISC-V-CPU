class multiply_random_test extends multiply_base_test;
    `uvm_component_utils(multiply_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        multiply_virtual_sequence virtual_sequence;
        virtual_sequence = multiply_virtual_sequence::type_id::create("virtual_sequence");

        phase.raise_objection(this);
        virtual_sequence.start(env.multiply_virtual_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : multiply_random_test