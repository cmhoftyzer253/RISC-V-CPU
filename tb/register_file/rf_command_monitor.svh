class rf_command_monitor extends uvm_component;
    `uvm_component_utils(rf_command_monitor)

    rf_command_agent_config                         agent_config;
    uvm_analysis_port #(rf_command_transaction)     ap;

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
        rf_command_transaction cmd;
        virtual rf_if rf_vif = agent_config.get_vif();

        forever begin
            @(rf_vif.mon_cb);

            cmd = rf_command_transaction::type_id::create("cmd");
            cmd.rs1_addr_i  =   rf_vif.mon_cb.rs1_addr_i;
            cmd.rs2_addr_i  =   rf_vif.mon_cb.rs2_addr_i;
            cmd.rd_addr_i   =   rf_vif.mon_cb.rd_addr_i;
            cmd.wr_en_i     =   rf_vif.mon_cb.wr_en_i;
            cmd.wr_data_i   =   rf_vif.mon_cb.wr_data_i;

            `uvm_info("COMMAND_MONITOR", cmd.convert2string(), UVM_HIGH)
            ap.write(cmd);
        end
    endtask : run_phase

endclass : rf_command_monitor