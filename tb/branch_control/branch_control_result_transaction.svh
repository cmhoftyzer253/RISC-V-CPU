class branch_control_result_transaction extends uvm_transaction;
    `uvm_object_utils(branch_control_result_transaction)

    logic branch_taken_o;

    function new(string name = "branch_control_result_transaction");
        super.new(name);
    endfunction : new

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        branch_control_result_transaction   RHS;
        bit                                 same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)         &&
                    (branch_taken_o = RHS.branch_taken_o);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        branch_control_result_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transasction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        branch_taken_o  =   RHS.branch_taken_o;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("branch_taken_o: %b", branch_taken_o);

        return s;
    endfunction : convert2string

endclass : branch_control_result_transaction