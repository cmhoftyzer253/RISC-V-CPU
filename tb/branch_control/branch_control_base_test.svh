class branch_control_base_test extends uvm_test;
    `uvm_component_utils(branch_control_base_test)

    branch_control_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_test(uvm_phase phase);
        super.build_test(phase);

        env = branch_control_env::type_id::create("env", this);
    endfunction : build_test

endclass : branch_control_base_test