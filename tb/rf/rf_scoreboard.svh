class rf_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(rf_scoreboard)

    uvm_analysis_export #(rf_command_transaction)       cmd_export;
    uvm_analysis_export #(rf_result_transaction)        res_export;
    uvm_analysis_export #(rf_reset_transaction)         reset_export;


    uvm_tlm_analysis_fifo #(rf_command_transaction)     cmd_fifo;
    uvm_tlm_analysis_fifo #(rf_result_transaction)      res_fifo;
    uvm_tlm_analysis_fifo #(rf_reset_transaction)       reset_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cmd_export      =   new("cmd_export", this);
        res_export      =   new("res_export", this);
        reset_export    =   new("reset_export", this);

        cmd_fifo        =   new("cmd_fifo", this);
        res_fifo        =   new("res_fifo", this);
        reset_fifo      =   new("reset_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        cmd_export.connect(cmd_fifo.analysis_export);
        res_export.connect(res_fifo.analysis_export);
        reset_export.connect(reset_fifo.analysis_export);
    endfunction : connect_phase

    function rf_result_transaction predict_result(rf_command_transaction cmd);
        rf_result_transaction   predicted;
        longint                 rs1_data_o;
        longint                 rs2_data_o;

        predicted = rf_result_transaction::type_id::create("predicted");

        rf_golden(
            1,
            cmd.rs1_addr_i,
            cmd.rs2_addr_i,
            rs1_data_o,
            rs2_data_o,
            cmd.rd_addr_i,
            cmd.wr_en_i,
            cmd.wr_data_i
        );

        predicted.rs1_data_o    =   rs1_data_o;
        predicted.rs2_data_o    =   rs2_data_o;

        return predicted;
    endfunction : predict_result

    task run_phase(uvm_phase phase);
        string                  data_str;
        rf_command_transaction  cmd;
        rf_result_transaction   res;
        rf_result_transaction   predicted;
        rf_reset_transaction    reset;

        longint                 rs1_data_reset;
        longint                 rs2_data_reset;

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
                    reset_fifo.get(reset);
                end
            join_any
            disable fork;

            //pass resetn = 1'b0 to golden model to clear registers
            rf_golden(
                0, 0, 0, rs1_data_reset, rs2_data_reset, 0, 0, 0
            );

            cmd_fifo.flush();
            res_fifo.flush();
        end
    endtask : run_phase

endclass : rf_scoreboard