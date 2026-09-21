`uvm_analysis_imp_decl(_cmd)

class branch_control_coverage extends uvm_component;
    `uvm_component_utils(branch_control_coverage)

    logic [63:0]    opr_a_i;
    logic [63:0]    opr_b_i;
    logic           b_type_i;
    b_type_t        instr_funct3_i;

    //TODO: covergroups

    function new(string name, uvm_component parent);
        super.new(name, parent);

        cmd_export = new("cmd_export", this);

        //TODO: create covergroups
    endfunction : new

    function void write(branch_control_command_transaction t);
        opr_a_i         =   t.opr_a_i;
        opr_b_i         =   t.opr_b_i;
        b_type_i        =   t.b_type_i;
        instr_funct3_i  =   t.instr_funct3_i;
        
        //TODO: sample covergroups
    endfunction : write

endclass : branch_control_coverage