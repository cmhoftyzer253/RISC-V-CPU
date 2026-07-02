class decode_base_test extends uvm_test;
    `uvm_component_utils(decode_base_test)

    decode_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = decode_env::type_id::create("env", this);
    endfunction : build_phase

endclass : decode_base_test