class rf_reset_driver extends uvm_driver #(rf_reset_transaction);
    `uvm_component_utils(rf_reset_driver)

    rf_reset_agent_config agent_config;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("RESET_DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        rf_reset_transaction reset;
        virtual rf_if rf_vif = agent_config.get_vif();

        rf_vif.resetn   <=  1'b0;
        repeat (5) @(posedge rf_vif.clk);
        rf_vif.resetn   <=  1'b1;

        forever begin
            seq_item_port.get_next_item(reset);

            repeat (reset.reset_delay) @(posedge rf_vif.clk);
            rf_vif.resetn   <=  1'b0;
            repeat (reset.reset_duration) @(posedge rf_vif.clk);
            rf_vif.resetn   <=  1'b1;

            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : rf_reset_driver