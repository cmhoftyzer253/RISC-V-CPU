class multiply_ready_transaction extends uvm_sequence_item;
    `uvm_object_utils(multiply_ready_transaction)

    function new(string name = "multiply_ready_transaction");
        super.new(name);
    endfunction : new

    rand int unsigned ready_delay;

    constraint delay_dist {
        ready_delay dist {
            0       := 6,
            [1:4]   := 3,
            [5:20]  := 1
        };
    }

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        multiply_ready_transaction  RHS;
        bit                         same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)     &&
                    (RHS.ready_delay == ready_delay);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        multiply_ready_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")
            
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        ready_delay = RHS.ready_delay;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("ready_delay: %0d", ready_delay);

        return s;
    endfunction : convert2string

endclass : multiply_ready_transaction