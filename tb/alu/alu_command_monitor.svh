class alu_command_monitor extends uvm_component;
    `uvm_component_utils(alu_command_monitor)

    alu_agent_config                                agent_config;
    uvm_analysis_port #(alu_command_transaction)    ap;

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
        alu_command_transaction cmd;
        virtual alu_if alu_vif = agent_config.get_vif();

        forever begin
            @(alu_vif.mon_cb);
            `uvm_info("COMMAND_MONITOR", "sampled a cycle", UVM_LOW)

            cmd = alu_command_transaction::type_id::create("cmd");

            cmd.opr_a_i       =   alu_vif.mon_cb.opr_a_i;
            cmd.opr_b_i       =   alu_vif.mon_cb.opr_b_i;
            cmd.alu_valid_i   =   alu_vif.mon_cb.alu_valid_i;
            cmd.alu_func_i    =   alu_vif.mon_cb.alu_func_i;
            cmd.word_op_i     =   alu_vif.mon_cb.word_op_i;
            cmd.flush_i       =   alu_vif.mon_cb.flush_i;

            `uvm_info("COMMAND_MONITOR", cmd.convert2string(), UVM_HIGH)
            ap.write(cmd);
        end
    endtask : run_phase

endclass : alu_command_monitor