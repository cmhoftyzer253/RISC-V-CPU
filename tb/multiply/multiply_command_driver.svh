class multiply_command_driver extends uvm_driver #(multiply_command_transaction);
    `uvm_component_utils(multiply_command_driver)

    multiply_command_agent_config   agent_config;
    protected bit                   cmd_active;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("COMMAND_DRIVER", "agent_config is null")
    endfunction

    task run_phase(uvm_phase phase);
        virtual multiply_if multiply_vif = agent_config.get_vif();

        forever begin
            wait (multiply_vif.resetn == 1'b1);

            fork
                drive_transactions();
                reset_watch();
            join_any
            disable fork;

            if (cmd_active) begin
                seq_item_port.item_done();
                cmd_active = 1'b0;
            end

            multiply_vif.mul_valid_i     <=  1'b0;
            multiply_vif.flush_i         <=  1'b0;
        end
    endtask : run_phase

    task drive_transactions();
        multiply_command_transaction cmd;
        virtual multiply_if multiply_vif    =   agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(cmd);
            cmd_active = 1'b1;

            repeat (cmd.valid_delay) @(multiply_vif.drv_cb);

            @(multiply_vif.drv_cb);
            multiply_vif.drv_cb.opr_a_i         <=  cmd.opr_a_i;
            multiply_vif.drv_cb.opr_b_i         <=  cmd.opr_b_i;
            multiply_vif.drv_cb.mul_valid_i     <=  cmd.mul_valid_i;
            multiply_vif.drv_cb.mul_func_i      <=  cmd.mul_func_i;
            multiply_vif.drv_cb.word_op_i       <=  cmd.word_op_i;
            multiply_vif.drv_cb.flush_i         <=  cmd.flush_i; 

            @(multiply_vif.drv_cb);
            while (!((multiply_vif.drv_cb.mul_res_valid_o == 1'b1 && multiply_vif.drv_cb.mul_res_ready_i == 1'b1) || multiply_vif.flush_i))
                @(multiply_vif.drv_cb);

            multiply_vif.drv_cb.mul_valid_i        <=  1'b0;
            seq_item_port.item_done();
            cmd_active = 1'b0;
        end
    endtask : drive_transactions

    protected task reset_watch();
        virtual multiply_if multiply_vif = agent_config.get_vif();
        @(negedge multiply_vif.resetn);
    endtask : reset_watch

endclass : multiply_command_driver