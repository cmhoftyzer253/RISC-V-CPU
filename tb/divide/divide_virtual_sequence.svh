class divide_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(divide_virtual_sequence)
    `uvm_declare_p_sequencer(divide_virtual_sequencer)

    function new(string name = "divide_virtual_sequencer");
        super.new(name);
    endfunction : new

    task body();
        divide_command_sequence     cmd_sequence;
        divide_ready_sequence       ready_sequence;
        divide_flush_sequence       flush_sequence;
        divide_reset_sequence       reset_sequence;

        cmd_sequence    =   divide_command_sequence::type_id::create("cmd_sequence");
        ready_sequence  =   divide_ready_sequence::type_id::create("ready_sequence");
        flush_sequence  =   divide_flush_sequence::type_id::create("flush_sequence");
        reset_sequence  =   divide_reset_sequence::type_id::create("reset_sequence");

        fork
            begin
                cmd_sequence.start(p_sequencer.cmd_sequencer);
            end
            begin
                cmd_sequencer.start(p_sequencer.ready_sequencer);
            end
            begin
                cmd_sequencer.start(p_sequencer.flush_sequencer);
            end
            begin
                cmd_sequencer.start(p_sequencer.reset_sequencer);
            end
        join_any

        disable fork;
    endtask : body

endclass : divide_virtual_sequence