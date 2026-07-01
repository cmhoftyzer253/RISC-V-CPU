class control_base_test extends uvm_test;
    `uvm_component_utils(control_base_test)

    control_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = control_env::type_id::create("env", this);
    endfunction : build_phase

endclass : control_base_test