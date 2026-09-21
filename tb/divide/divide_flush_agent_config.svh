class divide_flush_agent_config extends uvm_object;
    `uvm_object_utils(divide_flush_agent_config)

    protected virtual divide_if         divide_vif;
    protected uvm_active_passive_enum   is_active;

    function new(string name = "divide_flush_agent_config");
        super.new(name);

        is_active = UVM_ACTIVE;
    endfunction : new

    function void set_vif(virtual divide_if vif);
        divide_vif = vif;
    endfunction : set_vif

    function virtual divide_if get_vif();
        return divide_vif;
    endfunction : get_vif

    function void set_is_active(uvm_active_passive_enum active_passive);
        is_active = active_passive;
    endfunction : set_is_active

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

endclass : divide_flush_agent_config