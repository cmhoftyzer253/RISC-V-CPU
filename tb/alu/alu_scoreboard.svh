class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_export #(alu_command_transaction)      cmd_export;
    uvm_analysis_export #(alu_result_transaction)       res_export;

    uvm_tlm_analysis_fifo #(alu_command_transaction)    cmd_fifo;
    uvm_tlm_analysis_fifo #(alu_result_transaction)     res_fifo;

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

    function alu_result_transaction predict_result(alu_command_transaction cmd);
        alu_result_transaction  predicted;
        int                     valid_res_o;
        longint                 alu_res_o;

        predicted = alu_result_transaction::type_id::create("predicted");

        alu_golden(
            cmd.opr_a_i,
            cmd.opr_b_i,
            cmd.alu_valid_i,
            cmd.alu_func_i,
            cmd.word_op_i,
            cmd.flush_i,
            valid_res_o,
            alu_res_o
        );

        predicted.valid_res_o   =   valid_res_o;
        predicted.alu_res_o     =   alu_res_o;

        return predicted;
    endfunction : predict_result

    task run_phase(uvm_phase phase);
        string                      data_str;
        alu_command_transaction     cmd;
        alu_result_transaction      res;
        alu_result_transaction      predicted;

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
                `uvm_error("SCOREBOARD", {"FAIL: ", data_str})
            end else
                `uvm_info("SCOREBOARD", {"PASS: ", data_str}, UVM_HIGH)
        end
    endtask : run_phase

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCOREBOARD", $sformatf("Checked %0d transactions with %0d mismatches", 
            num_checked, num_failed), UVM_LOW)
    endfunction : report_phase

endclass : alu_scoreboard