class divide_reset_monitor extends uvm_component;
    `uvm_component_utils(divide_reset_monitor)

    divide_reset_agent_config                       agent_config;
    uvm_analysis_port #(divide_reset_transaction)   ap;

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
        divide_reset_transaction reset;
        virtual divide_if divide_vif = agent_config.get_vif();

        forever begin
            @(negedge divide_vif.resetn);
            reset = divide_reset_transaction::type_id::create("reset");

            `uvm_info("RESET_MONITOR", reset.convert2string(), UMV_HIGH)
            ap.write(reset);
        end
    endtask : run_phase

endclass : divide_reset_monitor