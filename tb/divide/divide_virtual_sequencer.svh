class divide_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(divide_virtual_sequencer)

    divide_command_sequencer    cmd_sequencer;
    divide_ready_sequencer      ready_sequencer;
    divide_flush_sequencer      flush_sequencer;
    divide_reset_sequencer      reset_sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : divide_virtual_sequencer