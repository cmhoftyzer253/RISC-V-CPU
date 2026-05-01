class alu_result_transaction extends uvm_transaction;
    `uvm_object_utils(alu_result_transaction)

    logic           valid_res_o;
    logic [63:0]    alu_res_o;

    function new(string name = "");
        super.new(name);
    endfunction : new

    function bit do_compare(uvm_object check, uvm_comparer comparer);
        alu_result_transaction check_transaction;
        bit same;

        assert (check != null) else
            $fatal(1, "Tried to compare null transaction");
        
        same    =   super.do_compare(check, comparer);
        assert ($cast(check_transaction, check)) else
            $fatal(1, "Failed to cast in do_copy");

        same    =   (valid_res_o == check_transaction.valid_res_o) &&
                    (alu_res_o == check_transaction.alu_res_o) && 
                    same;

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        alu_result_transaction copied_transaction_h;

        assert (rhs != null) else
            $fatal(1, "Tried to copy null transaction");

        super.do_copy(rhs);
        assert($cast(copied_transaction_h, rhs)) else   
            $fatal(1, "Failed to cast in do_copy");

        valid_res_o     =   copied_transaction_h.valid_res_o;
        alu_res_o       =   copied_transaction_h.alu_res_o;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("valid_res_o: %b, alu_res_o: %h", valid_res_o, alu_res_o);

        return s;
    endfunction : convert2string

endclass : alu_result_transaction