class multiply_flush_monitor extends uvm_component;
    `uvm_component_utils(multiply_flush_monitor)

    multiply_flush_agent_config                         agent_config;
    uvm_analysis_port #(multiply_flush_transaction)     ap;

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
            `uvm_fatal("FLUSH_MONITOR", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        multiply_flush_transaction flush;
        virtual multiply_if multiply_vif = agent_config.get_vif();

        forever begin
            @(multiply_vif.flush_mon_cb);
            
            forever begin
                @(posedge multiply_vif.flush_i);
                flush = multiply_flush_transaction::type_id::create("flush");

                `uvm_info("FLUSH_MONITOR", flush.convert2string(), UVM_HIGH)
                ap.write(flush);
            end
        end
    endtask : run_phase

endclass : multiply_flush_monitor