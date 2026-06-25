class rf_command_transaction extends uvm_sequence_item;
    `uvm_object_utils(rf_command_transaction)

    function new(string name = "rf_command_transaction");
        super.new(name);
    endfunction : new

    rand logic [4:0]    rs1_addr_i;
    rand logic [4:0]    rs2_addr_i;
    rand logic [4:0]    rd_addr_i;
    rand logic          wr_en_i;
    rand logic [63:0]   wr_data_i;

    //TODO: constraints

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        rf_command_transaction  RHS;
        bit                     same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to do cast in do_compare")

        same    =   super.do_compare(rhs, comparer) &&
                    (RHS.rs1_addr_i == rs1_addr_i)  &&
                    (RHS.rs2_addr_i == rs2_addr_i)  &&
                    (RHS.rd_addr_i == rd_addr_i)    &&
                    (RHS.wr_en_i == wr_en_i)        &&
                    (RHS.wr_data_i == wr_data_i);
        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        rf_command_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        rs1_addr_i      =   RHS.rs1_addr_i;
        rs2_addr_i      =   RHS.rs2_addr_i;
        rd_addr_i       =   RHS.rd_addr_i;
        wr_en_i         =   RHS.wr_en_i;
        wr_data_i       =   RHS.wr_data_i;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("rs1_addr_i: %b, rs2_addr_i: %b, rd_addr_i: %b, wr_en_i: %b, wr_data_i: 64'h%h",
            rs1_addr_i, rs2_addr_i, rd_addr_i, wr_en_i, wr_data_i);

        return s;
    endfunction : convert2string

endclass : rf_command_transaction