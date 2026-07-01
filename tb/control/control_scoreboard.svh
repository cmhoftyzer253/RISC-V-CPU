class control_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(control_scoreboard)

    uvm_analysis_export #(control_command_transaction)      cmd_export;
    uvm_analysis_export #(control_result_transaction)       res_export;

    uvm_tlm_analysis_fifo #(control_command_transaction)    cmd_fifo;
    uvm_tlm_analysis_fifo #(control_result_transaction)     res_fifo;

    int unsigned num_checked;
    int unsigned num_failed;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cmd_export  =   new("cmd_export", this);
        res_export  =   new("res_export", this);

        cmd_fifo    =   new("cmd_fifo", this);
        res_fifo    =   new("res_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        cmd_export.connect(cmd_fifo.analysis_export);
        res_export.connect(res_fifo.analysis_export);
    endfunction : connect_phase

    function control_result_transaction predict_result(control_command_transaction cmd);
        control_result_transaction  predicted;
        int unsigned                pc_sel_o;
        int unsigned                opa_sel_o;
        int unsigned                opb_sel_o;
        int unsigned                exu_func_sel_o;
        int unsigned                rd_src_o;
        int unsigned                csr_en_o;
        int unsigned                csr_rw_o;
        int unsigned                data_req_o;
        int unsigned                data_byte_o;
        int unsigned                bypass_avail_o;
        int unsigned                data_wr_o;
        int unsigned                zero_extnd_o;
        int unsigned                rf_wr_en_o;
        int unsigned                word_op_o;
        int unsigned                alu_instr_o;
        int unsigned                mul_instr_o;
        int unsigned                div_instr_o;
        int unsigned                mret_o;
        int unsigned                wfi_o;
        int unsigned                exc_valid_o;
        int unsigned                exc_code_o;

        predicted = control_result_transaction::type_id::create("predicted");

        control_golden(
            cmd.r_type_i,
            cmd.i_type_i,
            cmd.s_type_i,
            cmd.b_type_i,
            cmd.u_type_i,
            cmd.j_type_i,
            cmd.system_type_i,
            cmd.instr_funct3_i,
            cmd.instr_funct12_i,
            cmd.instr_opcode_i,
            pc_sel_o,
            opa_sel_o,
            opb_sel_o,
            exu_func_sel_o,
            rd_src_o,
            csr_en_o,
            csr_rw_o,
            data_req_o,
            data_byte_o,
            bypass_avail_o,
            data_wr_o,
            zero_extnd_o,
            rf_wr_en_o,
            word_op_o,
            alu_instr_o,
            mul_instr_o,
            div_instr_o,
            mret_o,
            wfi_o,
            exc_valid_o,
            exc_code_o
        );

        predicted.pc_sel_o          =   pc_sel_o;
        predicted.opa_sel_o         =   opa_sel_o;
        predicted.opb_sel_o         =   opb_sel_o;
        predicted.exu_func_sel_o    =   exu_func_sel_o;
        predicted.rd_src_o          =   rd_src_o;
        predicted.csr_en_o          =   csr_en_o;
        predicted.csr_rw_o          =   csr_rw_o;
        predicted.data_req_o        =   data_req_o;
        predicted.data_byte_o       =   data_byte_o;
        predicted.bypass_avail_o    =   bypass_avail_o;
        predicted.data_wr_o         =   data_wr_o;
        predicted.zero_extnd_o      =   zero_extnd_o;
        predicted.rf_wr_en_o        =   rf_wr_en_o;
        predicted.word_op_o         =   word_op_o;
        predicted.alu_instr_o       =   alu_instr_o;
        predicted.mul_instr_o       =   mul_instr_o;
        predicted.div_instr_o       =   div_instr_o;
        predicted.mret_o            =   mret_o;
        predicted.wfi_o             =   wfi_o;
        predicted.exc_valid_o       =   exc_valid_o;
        predicted.exc_code_o        =   exc_code_o;

        return predicted;
    endfunction : predict_result

    task run_phase(uvm_phase phase);
        string                          data_str;
        control_command_transaction     cmd;
        control_result_transaction      res;
        control_result_transaction      predicted;

        forever begin
            cmd_fifo.get(cmd);
            res_fifo.get(res);
        
            predicted = predict_result(cmd);
            num_checked++;

            data_str = {
                cmd.convert2string(),
                " ==> Actual ", res.convert2string(),
                "/Predicted ", predicted.convert2string()
            };

            if (!predicted.compare(res)) begin
                num_failed++;
                `uvm_error("SCOREBOARD", {"FAIL: ", data_str});
            end else begin
                `uvm_info("SCOREBOARD", {"PASS: ", data_str}, UVM_HIGH);
            end
        end
    endtask : run_phase

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCOREBOARD", $sformatf("Checked %0d transactions with %0d mismatches",
            num_checked, num_failed), UVM_LOW)
    endfunction : report_phase

endclass : control_scoreboard