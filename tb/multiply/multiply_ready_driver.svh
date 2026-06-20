class multiply_ready_driver extends uvm_driver #(multiply_ready_transaction);
    `uvm_component_utils(multiply_ready_driver)

    multiply_result_agent_config    agent_config;
    protected bit                   item_active;
    protected int unsigned          pending_handshakes;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("READY_DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual multiply_if multiply_vif = agent_config.get_vif();

        forever begin
            wait (multiply_vif.resetn == 1'b1);

            pending_handshakes = 0;

            fork
                track_handshakes();
                drive_ready();
                reset_watch();
            join_any
            disable fork;

            if (item_active) begin
                seq_item_port.item_done();
                item_active = 1'b0;
            end

            multiply_vif.mul_res_ready_i  <=  1'b0;
        end
    endtask : run_phase

    protected task drive_ready();
        multiply_ready_transaction item;
        virtual multiply_if multiply_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(item);
            item_active = 1'b1;

            while (pending_handshakes == 0)
                @(multiply_vif.ready_cb);

            repeat (item.ready_delay)
                @(multiply_vif.ready_cb);

            multiply_vif.ready_cb.mul_res_ready_i <= 1'b1;

            @(multiply_vif.ready_cb);
            while (!(multiply_vif.ready_cb.mul_res_valid_o == 1'b1))
                @(multiply_vif.ready_cb);

            multiply_vif.ready_cb.mul_res_ready_i <= 1'b0;

            pending_handshakes--;
            seq_item_port.item_done();
            item_active = 1'b0;
        end
    endtask : drive_ready

    protected task track_handshakes();
        virtual multiply_if multiply_vif = agent_config.get_vif();

        forever begin
            @(multiply_vif.ready_cb);
            if (multiply_vif.ready_cb.mul_valid_i == 1'b1 && multiply_vif.ready_cb.mul_ready_o == 1'b1)
                pending_hanshakes++;
        end
    endtask : track_handshakes

    protected task reset_watch();
        virtual multiply_if multiply_vif = agent_config.get_vif();
        @(negedge multiply_vif.resetn);
    endtask : reset_watch

endclass : multiply_ready_driver