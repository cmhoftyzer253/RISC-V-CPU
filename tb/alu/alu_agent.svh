class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

    alu_agent_config        alu_agent_config_h;

    alu_sequencer           alu_sequencer_h;
    alu_driver              alu_driver_h;
    alu_command_monitor     alu_command_monitor_h;
    alu_result_monitor      alu_result_monitor_h;

    uvm_tlm_fifo #(alu_command_transaction)         instr_fifo;
    uvm_analysis_port #(alu_command_transaction)    instr_mon_ap;
    uvm_analysis_port #(alu_result_transaction)     result_ap;

    function new(string name, uvm_component parent);
        super.new(name, phase);
    endfunction : new

    function void build_phase(uvm_phase phase);

        if (!uvm_config_db #(alu_agent_config)::get(this, "", "alu_agent_config", alu_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get alu_agent_config");

        is_active = alu_agent_config_h.get_is_active();

        uvm_config_db #(virtual alu_if)::set(this, "*", "alu_vif", alu_agent_config_h.get_alu_vif());

        if (get_is_active() == UVM_ACTIVE) begin
            alu_sequencer_h =   new("sequencer_h", this);
            alu_driver_h    =   alu_driver::type_id::create("alu_driver_h", this);
        end

        alu_command_monitor_h   =   alu_command_monitor::type_id::create("alu_command_monitor_h", this);
        alu_result_monitor_h    =   alu_result_monitor::type_id::create("alu_result_monitor_h", this);

        instr_mon_ap    =   new("instr_mon_ap", this);
        result_ap       =   new("result_ap", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE) begin
            alu_driver_h.seq_item_port.connect(alu_sequencer_h.seq_item_export);
        end

        alu_command_monitor_h.ap.connect(instr_mon_ap);
        alu_result_monitor_h.ap.connect(result_ap);

    endfunction : connect_phase

endclass : alu_agent