class decode_command_transaction extends uvm_sequence_item;
    `uvm_object_utils(decode_command_transaction)

    function new(string name = "decode_command_transaction");
        super.new(name);
    endfunction : new

    logic [31:0]        instr_i;
    rand logic [6:0]    opcode;

    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        decode_command_transaction  RHS;
        bit                         same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer) && 
                    (RHS.instr_i == instr_i);

        return same;
    endfunction : do_compare

    virtual function void do_copy(uvm_object rhs);
        decode_type_command_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        instr_i     =   RHS.instr_i;
    endfunction : do_copy

    virtual function string convert2string();
        string s;
        s = $sformatf("instr_i: %h", instr_i);

        return s;
    endfunction : convert2string

endclass : decode_command_transaction