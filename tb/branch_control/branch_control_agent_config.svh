class branch_control_agent_config extends uvm_object;
    `uvm_object_utils(branch_control_agent_config)

    protected virtual branch_control_if     branch_control_vif;
    protected uvm_active_passive_enum       is_active;

    function new(string name = "branch_control_agent_config");
        super.new(name);

        is_active = UVM_ACTIVE;
    endfunction : new

    function void set_vif(virtual branch_control_if vif);
        branch_control_vif = vif;
    endfunction : set_vif

    function virtual branch_control_if get_vif();
        return branch_control_vif;
    endfunction : get_vif

    function void set_is_active(uvm_active_passive_enum active_passive);
        is_active = active_passive;
    endfunction : set_is_active

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

endclass : branch_control_agent_config