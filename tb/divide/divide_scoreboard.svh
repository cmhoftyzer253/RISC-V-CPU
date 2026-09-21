class divide_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(divide_scoreboard)

    uvm_analysis_export #(divide_command_transaction)       cmd_export;
    uvm_analysis_export #(divide_result_transaction)        res_export;
    uvm_analysis_export #(divide_flush_transaction)         flush_export;
    uvm_analysis_export #(divide_reset_transaction)         reset_export;

    uvm_tlm_analysis_fifo #(divide_command_transaction)     cmd_fifo;
    uvm_tlm_analysis_fifo #(divide_result_transaction)      res_fifo;
    uvm_tlm_analysis_fifo #(divide_flush_transaction)       flush_fifo;
    uvm_tlm_analysis_fifo #(divide_reset_transaction)       reset_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cmd_export      =   new("cmd_export", this);
        res_export      =   new("res_export", this);
        flush_export    =   new("flush_export", this);
        reset_export    =   new("reset_export", this);

        cmd_fifo        =   new("cmd_fifo", this);
        res_fifo        =   new("res_fifo", this);
        flush_fifo      =   new("flush_fifo", this);
        reset_fifo      =   new("reset_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        cmd_export.connect(cmd_fifo.analysis_export);
        res_export.connect(res_fifo.analysis_export);
        flush_export.connect(flush_fifo.analysis_export);
        reset_export.connect(reset_fifo.analysis_export);
    endfunction : connect_phase

    function divide_result_transaction predict_result(divide_command_transaction cmd);
        divide_result_transaction   predicted;
        longint                     div_res_o;  

        predicted = divide_result_transaction::type_id::create("predicted");

        divide_golden(
            cmd.opr_a_i,
            cmd.opr_b_i,
            cmd.div_func_i,
            cmd.word_op_i,
            div_res_o
        );

        predicted.div_res_o         =   div_res_o;
        predicted.div_res_valid_o   =   1'b1;

        return predicted;
    endfunction : predict_result

    task run_phase(uvm_phase phase);
        string                      data_str;
        divide_command_transaction  cmd;
        divide_result_transaction   res;
        divide_result_transaction   predicted;
        divide_flush_transaction    flush;
        divide_reset_transaction    reset;

        forever begin
            fork
                begin
                    cmd_fifo.get(cmd);
                    res_fifo.get(res);

                    predicted = predict_result(cmd);

                    data_str = {
                        cmd.convert2string(),
                        " ==> Actual: ", convert2string(),
                        "/Predicted: ", predicted.convert2string()
                    };

                    if (!predicted.compare(res))
                        `uvm_error("SCOREBOARD", {"FAIL: ", data_str})
                    else
                        `uvm_error("SCOREBOARD", {"PASS: ", data_str}, UVM_LOW)
                end
                begin
                    fork
                        flush_fifo.get(flush);
                        reset_fifo.get(reset);
                    join_any
                end
            join_any

            disable fork;

            cmd_fifo.flush();
            res_fifo.flush();
        end
    endtask : run_phase

endclass : divide_scoreboard