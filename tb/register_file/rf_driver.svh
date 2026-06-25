class rf_driver extends uvm_driver #(rf_command_transaction);
    `uvm_component_utils(rf_driver)

    rf_agent_config             agent_config;
    rf_command_transaction      cmd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual rf_if rf_vif = agent_config.get_vif();

        forever begin
            wait (rf_vif.resetn == 1'b1);

            fork
                drive_transactions();
                reset_watch();
            join_any
            disable fork;

            rf_vif.rs1_addr_i   <=  '0;
            rf_vif.rs2_addr_i   <=  '0;
            rf_vif.rd_addr_i    <=  '0;
            rf_vif.wr_en_i      <=  '0;
            rf_vif.wr_data_i    <=  '0;

            if (cmd != null) begin
                seq_item_port.item_done();
                cmd = null;
            end
        end
    endtask : run_phase

    task drive_transactions();
        virtual rf_if rf_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(cmd);

            @(rf_vif.drv_cb);
            rf_vif.drv_cb.rs1_addr_i    <=  cmd.rs1_addr_i;
            rf_vif.drv_cb.rs2_addr_i    <=  cmd.rs2_addr_i;
            rf_vif.drv_cb.rd_addr_i     <=  cmd.rd_addr_i;
            rf_vif.drv_cb.wr_en_i       <=  cmd.wr_en_i;
            rf_vif.drv_cb.wr_data_i     <=  cmd.wr_data_i;

            seq_item_port.item_done();
            cmd = null;
        end 
    endtask : drive_transactions

    protected task reset_watch();
        virtual rf_if rf_vif = agent_config.get_vif();
        @(negedge rf_vif.resetn);
    endtask : reset_watch

endclass : rf_driver