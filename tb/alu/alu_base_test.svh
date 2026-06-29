class alu_base_test extends uvm_test;
    `uvm_component_utils(alu_base_test)

    alu_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = alu_env::type_id::create("env", this);
    endfunction : build_phase

endclass : alu_base_test