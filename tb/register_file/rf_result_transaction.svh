class rf_result_transaction extends uvm_transaction;
    `uvm_object_utils(rf_result_transaction)

    logic [63:0]    rs1_data_o;
    logic [63:0]    rs2_data_o;

    function new(string name = "rf_result_transaction");
        super.new(name);
    endfunction : new

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        rf_result_transaction RHS;
        bit same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to do cast in do_compare")

        same    =   super.do_compare(rhs, comparer) &&
                    (rs1_data_o == RHS.rs1_data_o)  &&
                    (rs2_data_o == RHS.rs2_data_o);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        rf_result_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        rs1_data_o  =   RHS.rs1_data_o;
        rs2_data_o  =   RHS.rs2_data_o;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("rs1_data_o: 64'h%h, rs2_data_o: 64'h%h", rs1_data_o, rs2_data_o);

        return s;
    endfunction : convert2string

endclass : rf_result_transaction