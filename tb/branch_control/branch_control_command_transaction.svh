class branch_control_command_transaction extends uvm_sequence_item;
    `uvm_object_utils(branch_control_command_transaction)

    function new(string name = "branch_control_command_transaction");
        super.new(name);
    endfunction : new

    rand logic [63:0]   opr_a_i;
    rand logic [63:0]   opr_b_i;
    rand logic          b_type_i;
    rand b_type_t       instr_funct3_i;

    //TODO: constraints

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        branch_control_command_transaction  RHS;
        bit                                 same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)         &&
                    (RHS.opr_a_i == opr_a_i)                &&
                    (RHS.opr_b_i == opr_b_i)                &&
                    (RHS.b_type_i == b_type_i)              &&
                    (RHS.instr_funct3_i == instr_funct3_i);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        branch_control_command_transaction  RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        opr_a_i         =   RHS.opr_a_i;
        opr_b_i         =   RHS.opr_b_i;
        b_type_i        =   RHS.b_type_i;
        instr_funct3_i  =   RHS.instr_funct3_i;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("opr_a_i: 64'h%h, opr_b_i: 64'h%h, b_type_i: %b, instr_funct3_i: %s",
            opr_a_i, opr_b_i, b_type_i, instr_funct3_i.name());

            return s;
    endfunction : convert2string

endclass : branch_control_command_transaction