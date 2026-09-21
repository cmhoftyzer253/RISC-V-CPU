class divide_command_transaction extends uvm_sequence_item;
    `uvm_object_utils(divide_command_transaction)

    function new(string name = "divide_command_transaction");
        super.new(name);
    endfunction : new

    rand logic [63:0]   opr_a_i;
    rand logic [63:0]   opr_b_i;
    rand logic          div_valid_i;
    rand r_type_m_t     div_func_i;
    rand logic          word_op_i;

    rand int unsigned   valid_delay;

    //TODO: constraints

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        divide_command_transaction RHS;
        bit same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)     &&
                    (RHS.opr_a_i == opr_a_i)            &&
                    (RHS.opr_b_i == opr_b_i)            &&
                    (RHS.div_valid_i == div_valid_i)    &&
                    (RHS.div_func_i == div_func_i)      &&
                    (RHS.word_op_i == word_op_i);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        divide_command_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        opr_a_i         =   RHS.opr_a_i;
        opr_b_i         =   RHS.opr_b_i;
        div_valid_i     =   RHS.div_valid_i; 
        div_func_i      =   RHS.div_func_i;
        word_op_i       =   RHS.word_op_i;
        valid_delay     =   RHS.valid_delay;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("opr_a_i: 64'h%h, opr_b_i: 64'h%h, div_valid_i: %b, div_func_i: %s, word_op_i: %b, valid_delay: %0d", 
            opr_a_i, opr_b_i, div_valid_i, div_func_i.name(), word_op_i, valid_delay);

        return s;
    endfunction : convert2string

endclass : divide_command_transaction