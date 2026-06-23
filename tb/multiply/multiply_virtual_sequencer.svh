class multiply_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(multiply_virtual_sequencer)

    multiply_command_sequencer  cmd_sequencer;
    multiply_ready_sequencer    ready_sequencer;
    multiply_flush_sequencer    flush_sequencer;
    multiply_reset_sequencer    reset_sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : multiply_virtual_sequencer