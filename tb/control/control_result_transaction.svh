class control_result_transaction extends uvm_sequence_item;
    `uvm_object_utils(control_result_transaction)

    function new(string name = "control_result_transaction");
        super.new(name);
    endfunction : new

    logic               pc_sel_o;
    alu_opr_a_sel_t     opa_sel_o;
    alu_opr_b_sel_t     opb_sel_o;
    logic [3:0]         exu_func_sel_o;
    rd_src_t            rd_src_o;
    logic               csr_en_o;
    logic               csr_rw_o;
    logic               data_req_o;
    mem_access_size_t   data_byte_o;
    bypass_avail_t      bypass_avail_o;
    logic               data_wr_o;
    logic               zero_extnd_o;
    logic               rf_wr_en_o;
    logic               word_op_o;
    logic               alu_instr_o;
    logic               mul_instr_o;
    logic               div_instr_o;
    logic               mret_o;
    logic               wfi_o;

    logic               exc_valid_o;
    logic [4:0]         exc_code_o;

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        control_result_transaction  RHS;
        bit                         same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)         &&
                    (pc_sel_o == RHS.pc_sel_o)              &&
                    (opa_sel_o == RHS.opa_sel_o)            &&
                    (opb_sel_o == RHS.opb_sel_o)            && 
                    (exu_func_sel_o == RHS.exu_func_sel_o)  &&
                    (rd_src_o == RHS.rd_src_o)              &&
                    (csr_en_o == RHS.csr_en_o)              &&
                    (csr_rw_o == RHS.csr_rw_o)              &&
                    (data_req_o == RHS.data_req_o)          &&
                    (data_byte_o == RHS.data_byte_o)        &&
                    (bypass_avail_o == RHS.bypass_avail_o)  &&
                    (data_wr_o == RHS.data_wr_o)            &&
                    (zero_extnd_o == RHS.zero_extnd_o)      && 
                    (rf_wr_en_o == RHS.rf_wr_en_o)          &&
                    (word_op_o == RHS.word_op_o)            &&
                    (alu_instr_o == RHS.alu_instr_o)        &&
                    (mul_instr_o == RHS.mul_instr_o)        &&
                    (div_instr_o == RHS.div_instr_o)        &&
                    (mret_o == RHS.mret_o)                  &&
                    (wfi_o == RHS.wfi_o)                    &&
                    (exc_valid_o == RHS.exc_valid_o)        &&
                    (exc_code_o == RHS.exc_code_o);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        control_result_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        pc_sel_o        =   RHS.pc_sel_o;
        opa_sel_o       =   RHS.opa_sel_o;
        opb_sel_o       =   RHS.opb_sel_o;
        exu_func_sel_o  =   RHS.exu_func_sel_o;
        rd_src_o        =   RHS.rd_src_o;
        csr_en_o        =   RHS.csr_en_o;
        csr_rw_o        =   RHS.csr_rw_o;
        data_req_o      =   RHS.data_req_o;
        data_byte_o     =   RHS.data_byte_o;
        bypass_avail_o  =   RHS.bypass_avail_o;
        data_wr_o       =   RHS.data_wr_o;
        zero_extnd_o    =   RHS.zero_extnd_o;
        rf_wr_en_o      =   RHS.rf_wr_en_o;
        word_op_o       =   RHS.word_op_o;
        alu_instr_o     =   RHS.alu_instr_o;
        mul_instr_o     =   RHS.mul_instr_o;
        div_instr_o     =   RHS.div_instr_o;
        mret_o          =   RHS.mret_o;
        wfi_o           =   RHS.wfi_o;
        exc_valid_o     =   RHS.exc_valid_o;
        exc_code_o      =   RHS.exc_code_o;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf({"pc_sel_o: %b, opa_sel_o: %b, opb_sel_o: %b, exu_func_sel_o: %b, rd_src_o: %b, csr_en_o: %b, csr_rw_o: %b, ",
            "data_req_o: %b, data_byte_o: %b, bypass_avail_o: %b, data_wr_o: %b, zero_extnd_o: %b, rf_wr_en_o: %b, word_op_o: %b, ",
            "alu_instr_o: %b, mul_instr_o: %b, div_instr_o: %b, mret_o: %b, wfi_o: %b, exc_valid_o: %b, exc_code_o: %b"},
            pc_sel_o, opa_sel_o.name(), opb_sel_o.name(), exu_func_sel_o, rd_src_o.name(), csr_en_o, csr_rw_o,
            data_req_o, data_byte_o.name(), bypass_avail_o.name(), data_wr_o, zero_extnd_o, rf_wr_en_o, word_op_o, alu_instr_o, mul_instr_o, 
            div_instr_o, mret_o, wfi_o, exc_valid_o, exc_code_o);

        return s;
    endfunction : convert2string

endclass : control_result_transaction