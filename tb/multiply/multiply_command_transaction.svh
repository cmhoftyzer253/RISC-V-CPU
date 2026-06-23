class multiply_command_transaction extends uvm_sequence_item;
    `uvm_object_utils(multiply_command_transaction)
    
    function new(string name = "multiply_command_transaction");
        super.new(name);
    endfunction

    rand logic [63:0]   opr_a_i;
    rand logic [63:0]   opr_b_i;
    rand logic          mul_valid_i;
    rand r_type_m_t     mul_func_i;
    rand logic          word_op_i;

    rand int unsigned   valid_delay;

    constraint operands {
        opr_a_i dist {
            64'h0 := 1,
            [64'h0000_0000_0000_0001 : 64'h0000_0000_7FFF_FFFE] := 1,
            64'h0000_0000_7FFF_FFFF := 1,
            [64'h0000_0000_8000_0000 : 64'h7FFF_FFFF_FFFF_FFFE] := 1,
            64'h7FFF_FFFF_FFFF_FFFF := 1,
            [64'h8000_0000_0000_0000 : 64'hFFFF_FFFF_FFFF_FFFE] := 1,
            64'hFFFF_FFFF_FFFF_FFFF := 1
        };

        opr_b_i dist {
            64'h0 := 1,
            [64'h0000_0000_0000_0001 : 64'h0000_0000_7FFF_FFFE] := 1,
            64'h0000_0000_7FFF_FFFF := 1,
            [64'h0000_0000_8000_0000 : 64'h7FFF_FFFF_FFFF_FFFE] := 1,
            64'h7FFF_FFFF_FFFF_FFFF := 1,
            [64'h8000_0000_0000_0000 : 64'hFFFF_FFFF_FFFF_FFFE] := 1,
            64'hFFFF_FFFF_FFFF_FFFF := 1
        };
    }

    constraint mul_func_legal {
        mul_func_i inside {OP_MUL, OP_MULH, OP_MULHSU, OP_MULHU};
    }

    constraint valid {
        mul_valid_i == 1'b1;
    }

    constraint word_op_legal {
        word_op_i == 1'b1 -> mul_func_i == OP_MUL;
    }

    constraint valid_delay_dist {
        valid_delay dist {
            0       := 6,
            [1:4]   := 3,
            [5:20]  := 1
        };
    }

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        multiply_command_transaction    RHS;
        bit                             same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)     && 
                    (RHS.opr_a_i == opr_a_i)            &&
                    (RHS.opr_b_i == opr_b_i)            &&
                    (RHS.mul_valid_i == mul_valid_i)    &&
                    (RHS.mul_func_i == mul_func_i)      &&
                    (RHS.word_op_i == word_op_i);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        multiply_command_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")
        
        super.do_copy(rhs);
        opr_a_i         =   RHS.opr_a_i;
        opr_b_i         =   RHS.opr_b_i;
        mul_valid_i     =   RHS.mul_valid_i;
        mul_func_i      =   RHS.mul_func_i;
        word_op_i       =   RHS.word_op_i;
        valid_delay     =   RHS.valid_delay;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("opr_a_i: 64'h%h, opr_b_i: 64'h%h, mul_valid_i: %b, mul_func_i: %s, word_op_i: %b, valid_delay: %0d",
            opr_a_i, opr_b_i, mul_valid_i, mul_func_i.name(), word_op_i, valid_delay);

        return s;
    endfunction : convert2string

endclass : multiply_command_transaction