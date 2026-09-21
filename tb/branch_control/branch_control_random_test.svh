class branch_control_random_test extends uvm_test;
    `uvm_component_utils(branch_control_base_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        branch_control_random_sequence random_sequence;

        super.run_phase(phase);

        random_sequence = branch_control_random_sequence::type_id::create("random_sequence");

        phase.raise_objection(this);
        random_sequence.start(env.branch_control_agent_h.branch_control_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : branch_control_base_test