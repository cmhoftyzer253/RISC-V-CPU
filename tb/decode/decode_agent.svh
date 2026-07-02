class decode_agent extends uvm_agent;   
    `uvm_component_utils(decode_agent)

    decode_agent_config     decode_agent_config_h;

    decode_sequencer        decode_sequencer_h;
    decode_driver           decode_driver_h;
    decode_command_monitor  decode_command_monitor_h;
    decode_result_monitor   decode_result_monitor_h;

    uvm_analysis_port #(decode_command_transaction)     cmd_mon_ap;
    uvm_analysis_port #(decode_result_transaction)      res_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (decode_agent_config_h == null)
            `uvm_fatal("AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(decode_agent_config)::get(this, "", "decode_agent_config", decode_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get decode_agent_config")

        if (decode_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            decode_sequencer_h                  =   decode_sequencer::type_id::create("decode_sequencer_h", this);
            decode_driver_h                     =   decode_driver::type_id::create("decode_driver_h", this);

            decode_driver_h.agent_config        =   decode_agent_config_h;
        end

        decode_command_monitor_h                =   decode_command_monitor::type_id::create("decode_command_monitor_h", this);
        decode_command_monitor_h.agent_config   =   decode_agent_config_h;
        decode_result_monitor_h                 =   decode_result_monitor::type_id::create("decode_result_monitor_h", this);
        decode_result_monitor_h.agent_config    =   decode_agent_config_h;

        cmd_mon_ap  =   new("cmd_mon_ap", this);
        res_ap      =   new("res_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (decode_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            decode_driver_h.seq_item_port.connect(decode_sequencer_h.seq_item_export);
        end

        decode_command_monitor_h.ap.connect(cmd_mon_ap);
        decode_result_monitor_h.ap.connect(res_ap);
    endfunction : connect_phase

endclass : decode_agent