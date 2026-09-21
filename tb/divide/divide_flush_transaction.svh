class divide_flush_transaction extends uvm_sequence_item;
    `uvm_object_utils(divide_flush_transaction)

    function new(string name, uvm_component parent);
    endfunction : new

    rand int unsigned flush_delay;

    constraint delay {
        flush_delay inside {[10 : 50]};
    }

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        divide_flush_transaction    RHS;
        bit                         same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)     &&
                    (RHS.flush_delay == flush_delay);
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        divide_flush_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        flush_delay = RHS.flush_delay;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("flush_delay: %d", flush_delay);

        return s;
    endfunction : convert2string

endclass : divide_flush_transaction