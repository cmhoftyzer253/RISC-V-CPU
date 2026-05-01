class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)

    alu_sequencer   alu_sequencer_h;
    alu_driver      alu_driver_h;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        alu_sequencer_h     =   new("alu_sequencer_h", this);
        alu_driver_h        =   alu_driver::type_id::create("alu_driver_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        alu_driver_h.seq_item_port.connect(alu_sequencer_h.seq_item_export);
    endfunction : connect_phase

endclass : alu_env