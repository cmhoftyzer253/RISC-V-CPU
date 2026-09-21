class divide_flush_driver extends uvm_driver #(divide_flush_driver);
    `uvm_component_utils(divide_flush_driver)

    divide_flush_agent_config   agent_config;
    protected bit               flush_active;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("FLUSH_DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual divide_if divide_vif = agent_config.get_vif();

        forever begin
            wait (divide_vif.resetn == 1'b1);

            fork
                drive_flush();
                reset_watch();
            join_any
            disable fork;

            if (flush_active) begin
                seq_item_port.item_done();
                flush_active = 1'b0;
            end

            divide_vif.flush_i  <=  1'b0;
        end
    endtask : run_phase

    task drive_flush();
        divide_flush_transaction flush;
        virtual divide_if divide_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(flush);
            flush_active = 1'b1;

            repeat (flush.flush_delay) @(divide_vif.drv_cb);

            @(divide_vif.drv_cb);
            divide_vif.drv_cb.flush_i   <=  1'b1;

            @(divide_vif.drv_cb);

            divide_vif.drv_cb.flush_i   <=  1'b0;

            seq_item_port.item_done();
            flush_active = 1'b0;
        end
    endtask : drive_flush

    protected task reset_watch();
        virtual divide_if divide_vif = agent_config.get_vif();
        @(negedge divide_vif.resetn);
    endtask : reset_watch

endclass : divide_flush_driver