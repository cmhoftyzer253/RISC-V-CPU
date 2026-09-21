class divide_result_agent extends uvm_agent;
    `uvm_component_utils(divide_result_agent)

    divide_result_agent_config  divide_result_agent_config_h;

    divide_ready_sequencer      divide_ready_sequencer_h;
    divide_ready_driver         divide_ready_driver_h;
    divide_result_monitor       divide_result_monitor_h;

    uvm_analysis_port #(divide_result_transaction)  res_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (divide_result_agent_config_h == null)
            `uvm_fatal("RESULT_AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(divide_result_agent_config)::get(this, "", "divide_result_agent_config", divide_result_agent_config_h))
            `uvm_fatal("RESULT_AGENT", "Failed to get divide_result_agent_config")

        if (divide_result_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_ready_sequencer_h            =   divide_ready_sequencer::type_id::create("divide_ready_sequencer_h", this);
            divide_ready_driver_h               =   divide_ready_driver::type_id::create("divide_ready_driver_h", this);

            divide_ready_driver_h.agent_config  =   divide_result_agent_config_h;
        end

        divide_result_monitor_h                 =   divide_result_monitor::type_id::create("divide_result_monitor_h" this);
        divide_result_monitor_h.agent_config    =   divide_result_agent_config_h;
        res_ap                                  =   new("res_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (divide_result_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            divide_ready_driver_h.seq_item_port.connect(divide_ready_sequencer_h.seq_item_export);
        end

        divide_result_monitor_h.ap.connect(res_ap);
    endfunction : connect_phase

endclass : divide_result_agent