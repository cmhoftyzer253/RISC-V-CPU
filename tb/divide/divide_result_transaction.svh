class divide_result_transaction extends uvm_transaction;
    `uvm_object_utils(divide_result_transaction)

    logic [63:0]    div_res_o;
    logic           div_res_valid_o;

    function new(string name = "divide_result_transaction");
        super.new(name);
    endfunction : new

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        divide_result_transaction   RHS;
        bit                         same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)             &&
                    (div_res_o == RHS.div_res_o)                &&
                    (div_res_valid_o == RHS.div_res_valid_o);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        divide_result_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        div_res_o           =   RHS.div_res_o;
        div_res_valid_o     =   RHS.div_res_valid_o;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("div_res_o: 64'h%h, div_res_valid_o: %b", div_res_o, div_res_valid_o);

        return s;
    endfunction : convert2string

endclass : divide_result_transaction