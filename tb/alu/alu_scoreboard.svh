class alu_scoreboard extends uvm_subscriber #(alu_result_transaction);
    `uvm_component_utils(alu_scoreboard)

    uvm_tlm_analysis_fifo #(alu_command_transaction) instr_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        instr_fifo = new("instr_fifo", this);
    endfunction : build_phase

    function alu_result_transaction predict_result(alu_command_transaction instr);
        alu_result_transaction  predicted;
        int                     valid_res_o;
        longint                 alu_res_o;

        predicted = new("predicted");

        alu_golden(
            instr.opr_a_i,
            instr.opr_b_i,
            instr.alu_valid_i,
            instr.alu_func_i,
            instr.word_op_i,
            instr.flush_i,
            valid_res_o,
            alu_res_o
        );

        predicted.valid_res_o   =   valid_res_o;
        predicted.alu_res_o     =   alu_res_o;

        return predicted;

    endfunction : predict_result

    function void write(alu_result_transaction res_tr);
        string                      data_str;
        alu_command_transaction     instr;
        alu_result_transaction      predicted;

        if (!instr_fifo.try_get(instr))
            `uvm_fatal("SCOREBOARD", "Missing command in scoreboard")

        predicted = predict_result(instr);

        data_str = {
            instr.convert2string(),
            " ==> Actual ", res_tr.convert2string(),
            "/Predicted ", predicted.convert2string()
        };

        if (!predicted.compare(res_tr))
            `uvm_error("SCOREBOARD", {"FAIL: ", data_str})
        else
            `uvm_info("SCOREBOARD", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write

endclass : alu_scoreboard