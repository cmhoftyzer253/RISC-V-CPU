class rf_agent_config extends uvm_object;
    `uvm_object_utils(rf_agent_config)

    protected virtual rf_if             rf_vif;
    protected uvm_active_passive_enum   is_active;

    function new(string name = "rf_command_agent_config");
        super.new(name);

        is_active = UVM_ACTIVE;
    endfunction : new

    function void set_vif(virtual rf_if vif);
        rf_vif = vif;
    endfunction : set_vif

    function virtual rf_if get_vif();
        return rf_vif;
    endfunction : get_vif

    function void set_is_active(uvm_active_passive_enum active_passive);
        is_active = active_passive;
    endfunction : set_is_active

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

endclass : rf_agent_config