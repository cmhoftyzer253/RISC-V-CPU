class multiply_result_agent extends uvm_agent;
    `uvm_component_utils(multiply_result_agent)

    multiply_result_agent_config    multiply_result_agent_config_h;

    multiply_ready_sequencer        multiply_ready_sequencer_h;
    multiply_ready_driver           multiply_ready_driver_h;
    multiply_result_monitor         multiply_result_monitor_h;

    uvm_analysis_port #(multiply_result_transaction)    res_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (multiply_result_agent_config_h == null)
            `uvm_fatal("RESULT_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(multiply_result_agent_config)::get(this, "", "multiply_result_agent_config", multiply_result_agent_config_h))
            `uvm_fatal("RESULT_AGENT", "Failed to get multiply_result_agent_config")

        if (multiply_result_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_ready_sequencer_h              =   multiply_ready_sequencer::type_id::create("multiply_ready_sequencer_h", this);
            multiply_ready_driver_h                 =   multiply_ready_driver::type_id::create("multiply_ready_driver_h", this);

            multiply_ready_driver_h.agent_config    =   multiply_result_agent_config_h;
        end

        multiply_result_monitor_h                   =   multiply_result_monitor::type_id::create("multiply_result_monitor_h", this);
        multiply_result_monitor_h.agent_config      =   multiply_result_agent_config_h;
        res_ap                                      =   new("res_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (multiply_result_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            multiply_ready_driver_h.seq_item_port.connect(multiply_ready_sequencer_h.seq_item_export);
        end

        multiply_result_monitor_h.ap.connect(res_ap);
    endfunction : connect_phase

endclass : multiply_result_agent