class control_command_monitor extends uvm_component;
    `uvm_component_utils(control_command_monitor)

    control_agent_config                                agent_config;
    uvm_analysis_port #(control_command_transaction)    ap;

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
        control_command_transaction cmd;
        virtual control_if control_vif = agent_config.get_vif();

        forever begin
            @(control_vif.mon_cb);
            
            cmd = control_command_transaction::type_id::create("cmd");

            cmd.r_type_i            =   control_vif.mon_cb.r_type_i;
            cmd.i_type_i            =   control_vif.mon_cb.i_type_i;
            cmd.s_type_i            =   control_vif.mon_cb.s_type_i;
            cmd.b_type_i            =   control_vif.mon_cb.b_type_i;
            cmd.u_type_i            =   control_vif.mon_cb.u_type_i;
            cmd.j_type_i            =   control_vif.mon_cb.j_type_i;
            cmd.system_type_i       =   control_vif.mon_cb.system_type_i;
            cmd.instr_funct3_i      =   control_vif.mon_cb.instr_funct3_i;
            cmd.instr_funct12_i     =   control_vif.mon_cb.instr_funct12_i;
            cmd.instr_opcode_i      =   control_vif.mon_cb.instr_opcode_i;

            `uvm_info("COMMAND_MONITOR", cmd.convert2string(), UVM_HIGH)
            ap.write(cmd);
        end
    endtask : run_phase

endclass : control_command_monitor