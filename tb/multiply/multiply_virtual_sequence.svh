class multiply_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(multiply_virtual_sequence)
    `uvm_declare_p_sequencer(multiply_virtual_sequencer)

    int unsigned num_tests = 50;

    function new(string name = "multiply_virtual_sequence");
        super.new(name);
    endfunction : new

    task body();
        multiply_command_sequence   cmd_sequence;
        multiply_ready_sequence     ready_sequence;
        multiply_flush_sequence     flush_sequence;
        multiply_reset_sequence     reset_sequence;

        cmd_sequence = multiply_command_sequence::type_id::create("cmd_sequence");
        ready_sequence = multiply_ready_sequence::type_id::create("ready_sequence");
        flush_sequence = multiply_flush_sequence::type_id::create("flush_sequence");
        reset_sequence = multiply_reset_sequence::type_id::create("reset_sequence");

        cmd_sequence.num_tests      =   num_tests;

        fork
            begin
                cmd_sequence.start(p_sequencer.cmd_sequencer);
            end
            begin
                ready_sequence.start(p_sequencer.ready_sequencer);
            end
            begin
                flush_sequence.start(p_sequencer.flush_sequencer);
            end
            begin
                reset_sequence.start(p_sequencer.reset_sequencer);
            end
        join_any

        disable fork;
    endtask : body

endclass : multiply_virtual_sequence