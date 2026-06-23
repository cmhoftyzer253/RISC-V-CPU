class multiply_command_monitor extends uvm_component;
    `uvm_component_utils(multiply_command_monitor)

    multiply_command_agent_config                       agent_config;
    uvm_analysis_port #(multiply_command_transaction)   ap;

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
        multiply_command_transaction cmd;
        virtual multiply_if multiply_vif = agent_config.get_vif();

        forever begin
            @(multiply_vif.mon_cb);

            if (multiply_vif.mon_cb.mul_valid_i && multiply_vif.mon_cb.mul_ready_o) begin
                cmd = multiply_command_transaction::type_id::create("cmd");

                cmd.opr_a_i         =   multiply_vif.mon_cb.opr_a_i;
                cmd.opr_b_i         =   multiply_vif.mon_cb.opr_b_i;
                cmd.mul_valid_i     =   multiply_vif.mon_cb.mul_valid_i;
                cmd.mul_func_i      =   multiply_vif.mon_cb.mul_func_i;
                cmd.word_op_i       =   multiply_vif.mon_cb.word_op_i;

                `uvm_info("COMMAND_MONITOR", cmd.convert2string(), UVM_HIGH)
                ap.write(cmd);
            end
        end
    endtask : run_phase

endclass : multiply_command_monitor