class alu_agent_config extends uvm_object;
    `uvm_object_utils(alu_agent_config)

    protected virtual alu_if              alu_vif;
    protected uvm_active_passive_enum     is_active;

    function new(string name = "alu_agent_config");
        super.new(name);
    endfunction : new

    function void set_alu_vif(virtual alu_if vif);
        alu_vif = vif;
    endfunction : set_alu_vif

    function virtual alu_if get_alu_vif();
        return alu_vif;
    endfunction : get_alu_vif

    function void set_is_active(uvm_active_passive_enum active_passive);
        is_active = active_passive;
    endfunction : set_is_active

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

endclass : alu_agent_config;