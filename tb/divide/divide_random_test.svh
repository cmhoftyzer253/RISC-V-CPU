class divide_random_test extends divide_base_test;
    `uvm_component_utils(divide_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        divide_virtual_sequence virtual_sequence;
        virtual_sequence = divide_virtual_sequence::type_id::create("virtual_sequence");

        phase.raise_objection(this);
        virtual_sequence.start(env.divide_virtual_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : divide_random_test