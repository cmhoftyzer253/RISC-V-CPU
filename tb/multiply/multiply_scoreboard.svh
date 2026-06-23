class multiply_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(multiply_scoreboard)

    uvm_tlm_analysis_fifo #(multiply_command_transaction)   cmd_fifo;
    uvm_tlm_analysis_fifo #(multiply_result_transaction)    res_fifo;
    uvm_tlm_analysis_fifo #(multiply_flush_transaction)     flush_fifo;
    uvm_tlm_analysis_fifo #(multiply_reset_transaction)     reset_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cmd_fifo    =   new("cmd_fifo", this);
        res_fifo    =   new("res_fifo", this);
        flush_fifo  =   new("flush_fifo", this);
        reset_fifo  =   new("reset_fifo", this);
    endfunction : build_phase

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
                            `uvm_info("SCOREBOARD", {"PASS: ", data_str}, UVM_HIGH)
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