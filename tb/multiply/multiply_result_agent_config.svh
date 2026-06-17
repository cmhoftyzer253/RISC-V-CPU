class multiply_result_agent_config extends uvm_object;
    `uvm_object_utils(multiply_result_agent_config)

    protected virtual multiply_if       multiply_vif;
    protected uvm_active_passive_enum   is_active;

    function new(string name = "multiply_result_agent_config");
        super.new(name);

        is_active = UVM_ACTIVE;
    endfunction : new

    function void set_vif(virtual multiply_if vif);
        multiply_vif = vif;
    endfunction : set_vif

    function virtual multiply_if get_vif();
        return multiply_vif;
    endfunction : get_vif

    function void set_is_active(uvm_active_passive_enum active_passive);
        is_active = active_passive;
    endfunction : set_is_active

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

endclass : multiply_result_agent_config