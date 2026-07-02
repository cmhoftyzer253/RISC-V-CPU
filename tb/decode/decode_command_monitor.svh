class decode_command_monitor extends uvm_component;
    `uvm_component_utils(decode_command_monitor)

    decode_agent_config                                 agent_config;
    uvm_analysis_port #(decode_command_transaction)     ap;

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
            `uvm_fatal("COMMAND_MONITOR", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        decode_command_transaction cmd;
        virtual decode_if decode_vif = agent_config.get_vif();

        forever begin
            @(decode_vif.mon_cb);

            cmd = decode_command_transaction::type_id::create("cmd");

            cmd.instr_i = decode_vif.mon_cb.instr_i;

            `uvm_info("COMMAND_MONITOR", cmd.convert2string(), UVM_HIGH)
            ap.write(cmd);
        end
    endtask : run_phase

endclass : decode_command_monitor