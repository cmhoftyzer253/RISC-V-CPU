class decode_random_test extends decode_base_test;
    `uvm_component_utils(decode_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        decode_random_sequence random_sequence;

        super.run_phase(phase);

        random_sequence = decode_random_sequence::type_id::create("random_sequence");

        phase.raise_objection(this);
        random_sequence.start(env.decode_agent_h.decode_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : decode_random_test