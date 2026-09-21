class divide_ready_driver extends uvm_driver #(divide_ready_transaction);
    `uvm_component_utils(divide_ready_driver)

    divide_result_agent_config  agent_config;
    protected bit               ready_active;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("READY_DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual divide_if divide_vif = agent_config.get_vif();

        forever begin
            wait (divide_vif.resetn == 1'b1);

            fork
                drive_ready();
                reset_watch();
            join_any 
            disable fork;

            if (ready_active) begin
                seq_item_port.item_done();
                item_active = 1'b0;
            end

            divide_vif.div_res_ready_i  <=  1'b0;
        end
    endtask : run_phase

    protected task drive_ready();
        divide_ready_transaction ready;
        virtual divide_if divide_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(ready);
            ready_active = 1'b1;

            repeat (ready.ready_delay);
                @(divide_vif.ready_cb);

            divide_vif.ready_cb.div_res_ready_i <=  1'b1;

            do begin
                @(divide_vif.ready_cb);
            end while (!(divide_vif.ready_cb.div_res_valid_o == 1'b1 && divide_vif.ready_cb.div_res_ready_i == 1'b1));

            divide_vif.ready_cb.div_res_ready_i <=  1'b0;

            seq_item_port.item_done();
            ready_active = 1'b0;
        end
    endtask : drive_ready

    protected task reset_watch();
        virtual divide_if divide_vif = agent_config.get_vif();
        @(negedge divide_vif.resetn);
    endtask : reset_watch

endclass : divide_ready_driver