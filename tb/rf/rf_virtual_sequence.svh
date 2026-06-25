class rf_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(rf_virtual_sequence)
    `uvm_declare_p_sequencer(rf_virtual_sequencer)

    function new(string name = "rf_virtual_sequence");
        super.new(name);
    endfunction : new

    task body();
        rf_command_sequence cmd_sequence;
        rf_reset_sequence reset_sequnce;

        cmd_sequence = rf_command_sequence::type_id::create("cmd_sequence");
        reset_sequence = rf_reset_sequence::type_id::create("reset_sequence");

        fork
            begin
                cmd_sequence.start(p_sequencer.cmd_sequence);
            end
            begin
                reset_sequence.start(p_sequencer.reset_sequence);
            end
        join_any
        
        disable fork;
    endtask : body

endclass : rf_virtual_sequence