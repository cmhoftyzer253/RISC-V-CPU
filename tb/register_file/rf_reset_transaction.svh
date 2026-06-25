class rf_reset_transaction extends uvm_transaction;
    `uvm_object_utils(rf_reset_transaction)

    function new(string name = "rf_reset_transaction");
        super.new(name);
    endfunction : new

    rand int unsigned reset_delay;
    rand int unsigned reset_duration;

    //TODO: constraints

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        rf_reset_transaction    RHS;
        bit                     same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)         &&
                    (RHS.reset_delay == reset_delay)        &&
                    (RHS.reset_duration == reset_duration);
    endfunction : do_compare

    function void do_copy(umv_object rhs);
        rf_reset_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        reset_delay     =   RHS.reset_delay;
        reset_duration  =   RHS.reset_duration;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("reset_delay: %0d, reset_duration: %0d", reset_delay, reset_duration);

        return s;
    endfunction : convert2string

endclass : rf_reset_transaction
