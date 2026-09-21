class multiply_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(multiply_scoreboard)

    uvm_analysis_export #(multiply_command_transaction)     cmd_export;
    uvm_analysis_export #(multiply_result_transaction)      res_export;
    uvm_analysis_export #(multiply_flush_transaction)       flush_export;
    uvm_analysis_export #(multiply_reset_transaction)       reset_export;

    uvm_tlm_analysis_fifo #(multiply_command_transaction)   cmd_fifo;
    uvm_tlm_analysis_fifo #(multiply_result_transaction)    res_fifo;
    uvm_tlm_analysis_fifo #(multiply_flush_transaction)     flush_fifo;
    uvm_tlm_analysis_fifo #(multiply_reset_transaction)     reset_fifo;

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

    function multiply_result_transaction predict_result(multiply_command_transaction cmd);
        multiply_result_transaction     predicted;
        longint                         mul_res_o;

        predicted = multiply_result_transaction::type_id::create("predicted");

        multiply_golden(
            cmd.opr_a_i,
            cmd.opr_b_i,
            cmd.mul_func_i,
            cmd.word_op_i,
            mul_res_o
        );

        predicted.mul_res_o         =   mul_res_o;
        predicted.mul_res_valid_o   =   1'b1;

        return predicted;
    endfunction : predict_result

    task run_phase(uvm_phase phase);
        string                          data_str;
        multiply_command_transaction    cmd;
        multiply_result_transaction     res;
        multiply_result_transaction     predicted;
        multiply_flush_transaction      flush;
        multiply_reset_transaction      reset;

        forever begin
            fork
                begin
                    forever begin
                        cmd_fifo.get(cmd);
                        res_fifo.get(res);

                        predicted = predict_result(cmd);

                        data_str = {
                            cmd.convert2string(),
                            " ==> Actual: ", res.convert2string(),
                            "/Predicted: ", predicted.convert2string()
                        };

                        if (!predicted.compare(res))
                            `uvm_error("SCOREBOARD", {"FAIL: ", data_str})
                        else 
                            `uvm_info("SCOREBOARD", {"PASS: ", data_str}, UVM_LOW)
                    end
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

endclass : multiply_scoreboard