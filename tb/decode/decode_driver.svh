class decode_driver extends uvm_driver #(decode_command_transaction);
    `uvm_component_utils(decode_driver)

    decode_agent_config         agent_config;
    decode_command_transaction  cmd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        if (agent_config == null)
            `uvm_fatal("DRIVER", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        virtual decode_if decode_vif = agent_config.get_vif();

        forever begin
            seq_item_port.get_next_item(cmd);

            @(decode_vif.drv_cb);
            decode_vif.drv_cb.instr_i <= cmd.instr_i;
            
            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : decode_driver