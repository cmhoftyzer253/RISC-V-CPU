class multiply_result_monitor extends uvm_component;
    `uvm_component_utils(multiply_result_monitor)

    multiply_result_agent_config                        agent_config;
    uvm_analysis_port #(multiply_result_transaction)    ap;

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
        multiply_result_transaction res;
        virtual multiply_if multiply_vif = agent_config.get_vif();

        forever begin
            @(multiply_vif.res_cb);

            if (multiply_vif.res_cb.mul_res_valid_o && multiply_vif.res_cb.mul_res_ready_i) begin
                res = multiply_result_transaction::type_id::create("res");

                res.mul_res_o           =   multiply_vif.res_cb.mul_res_o;
                res.mul_res_valid_o     =   multiply_vif.res_cb.mul_res_valid_o;

                `uvm_info("RESULT_MONITOR", res.convert2string(), UVM_HIGH)
                ap.write(res);
            end
        end
    endtask : run_phase

endclass : multiply_result_monitor