class decode_result_transaction extends uvm_transaction;
    `uvm_object_utils(decode_result_transaction)

    logic [4:0]     rs1_o;
    logic [4:0]     rs2_o;
    logic [4:0]     rd_o;
    logic [2:0]     funct3_o;
    logic [11:0]    funct12_o;
    logic [11:0]    csr_addr_o;
    logic           r_type_o;
    logic           i_type_o;
    logic           s_type_o;
    logic           b_type_o;
    logic           u_type_o;
    logic           j_type_o;
    logic           system_type_o;
    logic [63:0]    imm_o;
    logic           exc_valid_o;
    logic [4:0]     exc_code_o;

    function new(string name = "decode_result_transaction");
        super.new(name);
    endfunction : new

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        decode_result_transaction   RHS;
        bit                         same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)         &&
                    (rs1_o == RHS.rs1_o)                    &&
                    (rs2_o == RHS.rs2_o)                    && 
                    (rd_o == RHS.rd_o)                      &&
                    (funct3_o == RHS.funct3_o)              &&
                    (funct12_o == RHS.funct12_o)            &&
                    (csr_addr_o == RHS.csr_addr_o)          &&
                    (r_type_o == RHS.r_type_o)              && 
                    (i_type_o == RHS.i_type_o)              &&
                    (s_type_o == RHS.s_type_o)              &&
                    (b_type_o == RHS.b_type_o)              &&
                    (u_type_o == RHS.u_type_o)              &&
                    (j_type_o == RHS.j_type_o)              &&
                    (system_type_o == RHS.system_type_o)    &&
                    (imm_o == RHS.imm_o)                    &&
                    (exc_valid_o == RHS.exc_valid_o)        &&
                    (exc_code_o == RHS.exc_code_o);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        decode_result_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        rs1_o           =   RHS.rs1_o;
        rs2_o           =   RHS.rs2_o;
        rd_o            =   RHS.rd_o;
        funct3_o        =   RHS.funct3_o;
        funct12_o       =   RHS.funct12_o;
        csr_addr_o      =   RHS.csr_addr_o;
        r_type_o        =   RHS.r_type_o;
        i_type_o        =   RHS.i_type_o;
        s_type_o        =   RHS.s_type_o;
        b_type_o        =   RHS.b_type_o;
        u_type_o        =   RHS.u_type_o;
        j_type_o        =   RHS.j_type_o;
        system_type_o   =   RHS.system_type_o;
        imm_o           =   RHS.imm_o;
        exc_valid_o     =   RHS.exc_valid_o;
        exc_code_o      =   RHS.exc_code_o;
    endfunction : do_copy   

    function string convert2string();
        string s;
        s = $sformatf("rs1_o: %b, rs2_o: %b, rd_o: %b, funct3_o: %b, funct12_o: %b, csr_addr_o: %h, r_type_o: %b, i_type_o: %b, s_type_o: %b, b_type_o: %b, u_type_o: %b, j_type_o: %b, system_type_o: %b, imm_o: %b, exc_valid_o: %b, exc_code_o: %b",
            rs1_o, rs2_o, rd_o, funct3_o, funct12_o, csr_addr_o, r_type_o, i_type_o, s_type_o, b_type_o, u_type_o, j_type_o, system_type_o, imm_o, exc_valid_o, exc_code_o);

        return s;
    endfunction : convert2string

endclass : decode_result_transaction