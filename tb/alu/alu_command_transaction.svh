class alu_command_transaction extends uvm_sequence_item;
    `uvm_object_utils(alu_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [63:0]   opr_a_i;
    rand logic [63:0]   opr_b_i;
    rand logic          alu_valid_i;
    rand alu_op_t       alu_func_i;
    rand logic          word_op_i;
    rand logic          flush_i;

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

    constraint valid {
        alu_valid_i dist {1'b0 := 1, 1'b1 := 9};
    };

    constraint flush {
        flush_i dist {1'b0 := 99, 1'b1 := 1}
    };

    function bit do_compare(uvm_object check, uvm_comparer comparer);
        alu_command_transaction     check_transaction;
        bit                         same;

        if (check == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")
        
        if (!$cast(check_transaction, check))
            same    =   0;
        else 
            same    =   super.do_compare(check, comparer)               &&
                        (check_transaction.opr_a_i == opr_a_i)          &&
                        (check_transaction.opr_b_i == opr_b_i)          && 
                        (check_transaction.alu_valid_i == alu_valid_i)  && 
                        (check_transaction.alu_func_i == alu_func_i)    && 
                        (check_transaction.word_op_i == word_op_i)      && 
                        (check_transaction.flush_i == flush_i);
        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        alu_command_transaction RHS;
        assert (rhs != null) else 
            $fatal(1, "Tried to copy null transaction");
        
        super.do_copy(rhs);
        assert($cast(RHS, rhs)) else
            $fatal(1, "Failed to cast in do_copy");

        opr_a_i         =   RHS.opr_a_i;
        opr_b_i         =   RHS.opr_b_i;
        alu_valid_i     =   RHS.alu_valid_i;
        alu_func_i      =   RHS.alu_func_i;
        word_op_i       =   RHS.word_op_i;
        flush_i         =   RHS.flush_i;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("opr_a_i: 64'h%h, opr_b_i: 64'h%h, alu_valid_i: %b, alu_func_i: %s, word_op_i: %b, flush_i: %b"
            opr_a_i, opr_b_i, alu_valid_i, alu_func_i.name(), word_op_i, flush_i);

        return s;
    endfunction : convert2string

endclass : alu_command_transaction