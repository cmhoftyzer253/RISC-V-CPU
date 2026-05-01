class alu_result_monitor extends uvm_component;
    `uvm_component_utils(alu_result_monitor)

    virtual alu_if                                  alu_vif;
    uvm_analysis_port #(alu_result_transaction)     ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual alu_if)::get(null, "*", "alu_vif", alu_vif))
            `uvm_fatal("RESULT_MONITOR", "Failed to get alu_vif")

        ap = new("ap", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        alu_result_transaction res;
        forever begin
            @(posedge alu_vif.clk);
            res = alu_result_transaction::type_id::create("res");

            res.valid_res_o = alu_vif.valid_res_o;
            res.alu_res_o = alu_vif.alu_res_o;

            `uvm_info("RESULT_MONITOR", res.convert2string(), UVM_HIGH)
            ap.write(res);
        end
    endtask : run_phase

endclass : alu_result_monitor