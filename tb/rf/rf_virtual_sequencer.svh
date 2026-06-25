class rf_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(rf_virtual_sequencer)

    rf_sequencer            cmd_sequencer;
    rf_reset_sequencer      reset_sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : rf_virtual_sequencer