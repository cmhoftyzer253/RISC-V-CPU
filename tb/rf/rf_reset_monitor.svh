class rf_reset_monitor extends uvm_component;
    `uvm_component_utils(rf_reset_monitor)

    rf_reset_agent_config agent_config;
    uvm_analysis_port #(rf_reset_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("RESET_MONITOR", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        rf_reset_transaction reset;
        virtual rf_if rf_vif = agent_config.get_vif();

        forever begin
            @(negedge rf_vif.resetn);
            reset = rf_reset_transaction::type_id::create("reset");

            `uvm_info("RESET_MONITOR", reset.convert2string(), UVM_HIGH)
            ap.write(reset);
        end
    endtask : run_phase

endclass : rf_reset_monitor