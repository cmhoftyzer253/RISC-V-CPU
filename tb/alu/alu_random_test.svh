class alu_random_test extends alu_base_test;
    `uvm_component_utils(alu_random_test)

    alu_random_sequence alu_random_sequence_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        alu_random_sequence_h = new("alu_random_sequence_h");
        phase.raise_objection(this);
        alu_random_sequence_h.start(alu_sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

endclass : alu_random_test