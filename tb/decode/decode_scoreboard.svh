class decode_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(decode_scoreboard)

    uvm_analysis_export #(decode_command_transaction)       cmd_export;
    uvm_analysis_export #(decode_result_transaction)        res_export;

    uvm_tlm_analysis_fifo #(decode_command_transaction)     cmd_fifo;
    uvm_tlm_analysis_fifo #(decode_result_transaction)      res_fifo;

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

    function decode_result_transaction predict_result(decode_command_transaction cmd);
        decode_result_transaction   predicted;
        int unsigned                instr_i;
        int unsigned                rs1_o;
        int unsigned                rs2_o;
        int unsigned                rd_o;
        int unsigned                op_o;
        int unsigned                funct3_o;
        int unsigned                funct12_o;
        int unsigned                csr_addr_o;
        int unsigned                r_type_o;
        int unsigned                i_type_o;
        int unsigned                s_type_o;
        int unsigned                b_type_o;
        int unsigned                u_type_o;
        int unsigned                j_type_o;
        int unsigned                system_type_o;
        longint unsigned            imm_o;
        int unsigned                exc_valid_o;
        int unsigned                exc_code_o;

        predicted = decode_result_transaction::type_id::create("predicted");
        
        decode_golden(
            cmd.instr_i,
            rs1_o,
            rs2_o,
            rd_o,
            op_o,
            funct3_o,
            funct12_o,
            csr_addr_o,
            r_type_o,
            i_type_o,
            s_type_o,
            b_type_o,
            u_type_o,
            j_type_o,
            system_type_o,
            imm_o,
            exc_valid_o,
            exc_code_o
        );

        predicted.rs1_o             =   rs1_o;
        predicted.rs2_o             =   rs2_o;
        predicted.rd_o              =   rd_o;
        predicted.op_o              =   op_o;
        predicted.funct3_o          =   funct3_o;
        predicted.funct12_o         =   funct12_o;
        predicted.csr_addr_o        =   csr_addr_o;
        predicted.r_type_o          =   r_type_o;
        predicted.i_type_o          =   i_type_o;
        predicted.s_type_o          =   s_type_o;
        predicted.b_type_o          =   b_type_o;
        predicted.u_type_o          =   u_type_o;
        predicted.j_type_o          =   j_type_o;
        predicted.system_type_o     =   system_type_o;
        predicted.imm_o             =   imm_o;
        predicted.exc_valid_o       =   exc_valid_o;
        predicted.exc_code_o        =   exc_code_o;

        return predicted;
    endfunction : predict_result

    task run_phase(uvm_phase phase);
        string                      data_str;
        decode_command_transaction  cmd;
        decode_result_transaction   res;
        decode_result_transaction   predicted;

        forever begin
            cmd_fifo.get(cmd);
            res_fifo.get(res);

            predicted = predict_result(cmd);
            num_checked++;

            data_str = {
                cmd.convert2string(),
                " ==> Actual", res.convert2string(),
                "/Predicted: ", predicted.convert2string()
            };

            if (!predicted.compare(res)) begin
                num_failed++;
                `uvm_error("SCOREBOARD", {"FAIL: ", data_str})
            end else begin
                `uvm_info("SCOREBOARD", {"PASS: ", data_str}, UVM_HIGH)
            end
        end
    endtask : run_phase

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCOREBOARD", $sformatf("Checked %0d transactions with %0d mismatches", 
            num_checked, num_failed), UVM_LOW)
    endfunction : report_phase

endclass : decode_scoreboard