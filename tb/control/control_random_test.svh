class control_random_test extends control_base_test;
    `uvm_component_utils(control_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        control_random_sequence random_sequence;

        super.run_phase(phase);

        random_sequence = control_random_sequence::type_id::create("random_sequence");

        phase.raise_objection(this);
        random_sequence.start(env.control_agent_h.control_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : control_random_test