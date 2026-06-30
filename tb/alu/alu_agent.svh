class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

    alu_agent_config        alu_agent_config_h;

    alu_sequencer           alu_sequencer_h;
    alu_driver              alu_driver_h;
    alu_command_monitor     alu_command_monitor_h;
    alu_result_monitor      alu_result_monitor_h;

    uvm_analysis_port #(alu_command_transaction)    cmd_mon_ap;
    uvm_analysis_port #(alu_result_transaction)     res_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (alu_agent_config_h == null)
            `uvm_fatal("AGENT", "agent_config is null")
    endfunction : end_of_elaboration_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(alu_agent_config)::get(this, "", "alu_agent_config", alu_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get alu_agent_config")

        if (alu_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            alu_sequencer_h                 =   alu_sequencer::type_id::create("alu_sequencer_h", this);
            alu_driver_h                    =   alu_driver::type_id::create("alu_driver_h", this);

            alu_driver_h.agent_config       =   alu_agent_config_h;
        end

        alu_command_monitor_h               =   alu_command_monitor::type_id::create("alu_command_monitor_h", this);
        alu_command_monitor_h.agent_config  =   alu_agent_config_h;
        alu_result_monitor_h                =   alu_result_monitor::type_id::create("alu_result_monitor_h", this);
        alu_result_monitor_h.agent_config   =   alu_agent_config_h;

        cmd_mon_ap      =   new("cmd_mon_ap", this);
        res_ap          =   new("res_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (alu_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            alu_driver_h.seq_item_port.connect(alu_sequencer_h.seq_item_export);
        end

        alu_command_monitor_h.ap.connect(cmd_mon_ap);
        alu_result_monitor_h.ap.connect(res_ap);
    endfunction : connect_phase

endclass : alu_agent