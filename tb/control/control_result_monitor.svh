class control_result_monitor extends uvm_component;
    `uvm_component_utils(control_result_monitor)

    control_agent_config                                agent_config;
    uvm_analysis_port #(control_result_transaction)     ap;

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
            `uvm_fatal("RESULT_MONITOR", "agent_config is null")
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        control_result_transaction res;
        virtual control_if control_vif = agent_config.get_vif();

        forever begin
            @(control_vif.res_cb);

            res = control_result_transaction::type_id::create("res");

            res.pc_sel_o        =   control_vif.res_cb.pc_sel_o;
            res.opa_sel_o       =   control_vif.res_cb.opa_sel_o;
            res.opb_sel_o       =   control_vif.res_cb.opb_sel_o;
            res.exu_func_sel_o  =   control_vif.res_cb.exu_func_sel_o;
            res.rd_src_o        =   control_vif.res_cb.rd_src_o;
            res.csr_en_o        =   control_vif.res_cb.csr_en_o;
            res.csr_rw_o        =   control_vif.res_cb.csr_rw_o;
            res.data_byte_o     =   control_vif.res_cb.data_byte_o;
            res.bypass_avail_o  =   control_vif.res_cb.bypass_avail_o;
            res.data_wr_o       =   control_vif.res_cb.data_wr_o;
            res.zero_extnd_o    =   control_vif.res_cb.zero_extnd_o;
            res.rf_wr_en_o      =   control_vif.res_cb.rf_wr_en_o;
            res.word_op_o       =   control_vif.res_cb.word_op_o;
            res.alu_instr_o     =   control_vif.res_cb.alu_instr_o;
            res.mul_instr_o     =   control_vif.res_cb.mul_instr_o; 
            res.div_instr_o     =   control_vif.res_cb.div_instr_o;
            res.mret_o          =   control_vif.res_cb.mret_o;
            res.wfi_o           =   control_vif.res_cb.wfi_o;
            res.exc_valid_o     =   control_vif.res_cb.exc_valid_o;
            res.exc_code_o      =   control_vif.res_cb.exc_code_o;

            `uvm_info("RESULT_MONITOR", res.convert2string(), UVM_HIGH)
            ap.write(res);
        end
    endtask : run_phase

endclass : control_result_monitor