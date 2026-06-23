class multiply_reset_transaction extends uvm_sequence_item;
    `uvm_object_utils(multiply_reset_transaction)

    function new(string name = "multiply_reset_transaction");
        super.new(name);
    endfunction : new

    rand int unsigned reset_delay;
    rand int unsigned reset_duration;

    constraint delay {
        reset_delay inside {[100 : 500]};
    }

    constraint duration {
        reset_duration inside {[1 : 10]};
    }

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        multiply_reset_transaction  RHS;
        bit                         same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)         &&
                    (RHS.reset_delay == reset_delay)        &&
                    (RHS.reset_duration == reset_duration);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        multiply_reset_transaction RHS;

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

endclass : multiply_reset_transaction