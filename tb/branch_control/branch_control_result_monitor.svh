class branch_control_result_monitor extends uvm_component;
    `uvm_component_utils(branch_control_result_monitor)

    branch_control_agent_config                             agent_config;
    uvm_analysis_port #(branch_control_result_transaction)  ap;

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
        branch_control_result_transaction res;
        virtual branch_control_if branch_control_vif = agent_config.get_vif();

        forever begin
            @(branch_control_vif.res_cb);

            res = branch_control_result_transaction::type_id::create("res");
            
            res.branch_taken_o = branch_control_vif.res_cb.branch_taken_o;

            `uvm_info("RESULT_MONITOR", res.convert2string(), UVM_HIGH)
            ap.write(res);
        end
    endtask : run_phase

endclass : branch_control_result_monitor