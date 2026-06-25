class rf_result_monitor extends uvm_component;
    `uvm_component_utils(rf_result_monitor)

    rf_agent_config                             agent_config;
    uvm_analysis_port #(rf_result_transaction)  ap;

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
            `uvm_fatal("RESULT_MONITOR", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        rf_result_transaction res;
        virtual rf_if rf_vif = agent_config.get_vif();

        forever begin
            @(rf_vif.res_cb);

            res = rf_result_transaction::type_id::create("res");

            res.rs1_data_o = rf_vif.res_cb.rs1_data_o;
            res.rs2_data_o = rf_vif.res_cb.rs2_data_o;

            `uvm_info("RESULT_MONITOR", res.convert2string(), UVM_HIGH)
            ap.write(res);
        end
    endtask : run_phase

endclass : rf_result_monitor