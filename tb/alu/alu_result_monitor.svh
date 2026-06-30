class alu_result_monitor extends uvm_component;
    `uvm_component_utils(alu_result_monitor)

    alu_agent_config                                agent_config;
    uvm_analysis_port #(alu_result_transaction)     ap;

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
        alu_result_transaction res;
        virtual alu_if alu_vif = agent_config.get_vif();
        
        forever begin
            @(alu_vif.res_cb);
            `uvm_info("RESULT_MONITOR", "sampled a cycle", UVM_HIGH)
            
            res = alu_result_transaction::type_id::create("res");

            res.valid_res_o = alu_vif.res_cb.valid_res_o;
            res.alu_res_o = alu_vif.res_cb.alu_res_o;

            `uvm_info("RESULT_MONITOR", res.convert2string(), UVM_HIGH)
            ap.write(res);
        end
    endtask : run_phase

endclass : alu_result_monitor