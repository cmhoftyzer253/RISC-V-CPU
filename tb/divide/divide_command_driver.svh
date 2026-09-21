class divide_command_driver extends uvm_driver #(divide_command_transaction);
    `uvm_component_utils(divide_command_driver)

    divide_command_agent_config     agent_config;
    protected bit                   cmd_active;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("COMMAND_DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual divide_if divide_vif = agent_config.get_vif();

        forever begin
            wait (divide_vif.resetn == 1'b1);

            fork
                drive_transactions();
                reset_watch();
            join_any
            disable fork;

            if (cmd_active) begin
                seq_item_port.item_done();
                cmd_active = 1'b0;
            end

            divide_vif.div_valid_i      <=  1'b0;
        end
    endtask : run_phase

    task drive_transactions();
        divide_command_transaction cmd;
        virtual divide_if divide_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(cmd);
            cmd_active = 1'b1;

            repeat (cmd.valid_delay) @(divide_vif.drv_cb);

            @(divide_vif.drv_cb);
            divide_vif.drv_cb.opr_a_i       <=  cmd.opr_a_i;
            divide_vif.drv_cb.opr_b_i       <=  cmd.opr_b_i;
            divide_vif.drv_cb.div_valid_i   <=  cmd.div_valid_i;
            divide_vif.drv_cb.div_func_i    <=  cmd.div_func_i;
            divide_vif.drv_cb.word_op_i     <=  cmd.word_op_i;

            do begin
                @(divide_vif.drv_cb);
            end while (!(divide_vif.drv_cb.div_valid_i == 1'b1 && divide_vif.drv_cb.div_ready_o));

            divide_vif.drv_cb.div_valid_i   <=  1'b0;
            seq_item_port.item_done();
            cmd_active = 1'b0;
        end
    endtask : drive_transactions
    
    protected task reset_watch();
        virtual divide_if divide_vif = agent_config.get_vif();
        @(negedge divide_vif.resetn);
    endtask : reset_watch

endclass : divide_command_driver