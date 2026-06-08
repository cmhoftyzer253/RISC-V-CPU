class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)

    uvm_tlm_analysis_fifo #(alu_command_transaction) cmd_fifo;
    uvm_tlm_analysis_fifo #(alu_result_transaction) res_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cmd_fifo = new("cmd_fifo", this);
        res_fifo = new("res_fifo", this);
    endfunction : build_phase

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

    function void write(alu_result_transaction t);
        string                      data_str;
        alu_command_transaction     cmd;
        alu_result_transaction      res;
        alu_result_transaction      predicted;

        cmd_fifo.get(cmd);
        res_fifo.get(res);

        predicted = predict_result(cmd);

        data_str = {
            cmd.convert2string(),
            " ==> Actual ", t.convert2string(),
            "/Predicted ", predicted.convert2string()
        };

        if (!predicted.compare(t))
            `uvm_error("SCOREBOARD", {"FAIL: ", data_str})
        else
            `uvm_info("SCOREBOARD", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write

endclass : alu_scoreboard