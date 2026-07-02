class decode_result_monitor extends uvm_component;
    `uvm_component_utils(decode_result_monitor)

    decode_agent_config                             agent_config;
    uvm_analysis_port #(decode_result_transaction)  ap;

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
        decode_result_transaction res;
        virtual decode_if decode_vif = agent_config.get_vif();

        forever begin
            @(decode_vif.res_cb);

            res = decode_result_transaction::type_id::create("res");

            res.rs1_o           =   decode_vif.res_cb.rs1_o;
            res.rs2_o           =   decode_vif.res_cb.rs2_o;
            res.rd_o            =   decode_vif.res_cb.rd_o;
            res.op_o            =   decode_vif.res_cb.op_o;
            res.funct3_o        =   decode_vif.res_cb.funct3_o;
            res.funct12_o       =   decode_vif.res_cb.funct12_o;
            res.csr_addr_o      =   decode_vif.res_cb.csr_addr_o;
            res.r_type_o        =   decode_vif.res_cb.r_type_o;
            res.i_type_o        =   decode_vif.res_cb.i_type_o;
            res.s_type_o        =   decode_vif.res_cb.s_type_o;
            res.b_type_o        =   decode_vif.res_cb.b_type_o;
            res.u_type_o        =   decode_vif.res_cb.u_type_o;
            res.j_type_o        =   decode_vif.res_cb.j_type_o;
            res.system_type_o   =   decode_vif.res_cb.system_type_o;
            res.imm_o           =   decode_vif.res_cb.imm_o;
            res.exc_valid_o     =   decode_vif.res_cb.exc_valid_o;
            res.exc_code_o      =   decode_vif.res_cb.exc_code_o;

            `uvm_info("RESULT_MONITOR", res.convert2string(), UVM_HIGH)
            ap.write(res);
        end
    endtask : run_phase

endclass : decode_result_monitor