class control_agent_config extends uvm_object;
    `uvm_object_utils(control_agent_config)

    protected virtual control_if        control_vif;
    protected uvm_active_passive_enum   is_active;

    function new(string name = "control_agent_config");
        super.new(name);

        is_active = UVM_ACTIVE;
    endfunction : new

    function void set_vif(virtual control_if vif);
        control_vif = vif;
    endfunction : set_vif

    function virtual control_if get_vif();
        return control_vif;
    endfunction : get_vif

    function void set_is_active(uvm_active_passive_enum active_passive);
        is_active = active_passive;
    endfunction : set_is_active

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

endclass : control_agent_config