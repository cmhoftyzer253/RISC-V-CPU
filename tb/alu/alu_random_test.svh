class alu_random_test extends alu_base_test;
    `uvm_component_utils(alu_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        alu_random_sequence random_sequence;
        
        super.run_phase(phase);

        random_sequence = alu_random_sequence::type_id::create("random_sequence");
        
        phase.raise_objection(this);
        random_sequence.start(env.alu_agent_h.alu_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : alu_random_test