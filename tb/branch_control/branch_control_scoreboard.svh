class branch_control_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(branch_control_scoreboard)

    uvm_analysis_export #(branch_control_command_transaction)       cmd_export;
    uvm_analysis_export #(branch_control_result_transaction)        res_export;

    uvm_tlm_analysis_fifo #(branch_control_command_transaction)     cmd_fifo;
    uvm_tlm_analysis_fifo #(branch_control_result_transaction)      res_fifo;

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

    function branch_control_result_transaction predict_result(branch_control_command_transaction cmd);
        branch_control_result_transaction   predicted;
        int                                 branch_taken_o;

        predicted = branch_control_result_transaction::type_id::create("predicted");

        branch_control_golden(
            cmd.opr_a_i;
            cmd.opr_b_i;
            cmd.b_type_i;
            cmd.instr_funct3_i;
            branch_taken_o
        );

        predicted.branch_taken_o    =   branch_taken_o;

        return predicted;
    endfunction : predict_result

    task run_phase(uvm_phase phase);
        string                              data_str;
        branch_control_command_transaction  cmd;
        branch_control_result_transaction   res;
        branch_control_result_transaction   predicted;
        
        forever begin
            cmd_fifo.get(cmd);
            res_fifo.get(res);

            predicted = predict_result(cmd);
            num_checked++;

            data_str = {
                cmd.convert2string(),
                " ==> Actual: ", res.convert2string(),
                "/Predicted: ", predicted.convert2string()
            };

            if (!predicted.compare(res)) begin
                num_failed++;
                `uvm_error("SCOREBOARD", {"FAIL: ", data_str})
            end else begin
                `uvm_info("SCOREBOARD: ", {"PASSL ", data_str}, UVM_HIGH)
            end
        end
    endtask : run_phase

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCOREBOARD", $sformatf("Checked %0d transactions with %0d mismatches", 
            num_checked, num_failed), UVM_LOW)
    endfunction : report_phase

endclass : branch_control_scoreboard