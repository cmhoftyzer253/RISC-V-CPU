class alu_result_transaction extends uvm_transaction;
    `uvm_object_utils(alu_result_transaction)

    logic           valid_res_o;
    logic [63:0]    alu_res_o;

    function new(string name = "alu_result_transaction");
        super.new(name);
    endfunction : new

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        alu_result_transaction  RHS;
        bit                     same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer) &&
                    (valid_res_o == RHS.valid_res_o) &&
                    (alu_res_o == RHS.alu_res_o);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        alu_result_transaction  RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))  
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        valid_res_o     =   RHS.valid_res_o;
        alu_res_o       =   RHS.alu_res_o;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("valid_res_o: %b, alu_res_o: %h", valid_res_o, alu_res_o);

        return s;
    endfunction : convert2string

endclass : alu_result_transaction