class alu_command_monitor extends uvm_component;
    `uvm_component_utils(alu_command_monitor)

    virtual alu_if                                  alu_vif;
    uvm_analysis_port #(alu_command_transaction)    ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual alu_if)::get(null, "*", "alu_vif", alu_vif))
            `uvm_fatal("COMMAND_MONITOR", "Failed to get alu_vif");

        ap = new("ap", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        alu_command_transaction instr;
        forever begin
            @(posedge alu_vif.clk);
            instr = alu_command_transaction::type_id::create("instr");

            instr.opr_a_i       =   alu_vif.opr_a_i;
            instr.opr_b_i       =   alu_vif.opr_b_i;
            instr.alu_valid_i   =   alu_vif.alu_valid_i;
            instr.alu_func_i    =   alu_vif.alu_func_i;
            instr.word_op_i     =   alu_vif.word_op_i;
            instr.flush_i       =   alu_vif.flush_i;

            `uvm_info("COMMAND_MONITOR", instr.convert2string(), UVM_HIGH)
            ap.write(instr);
        end
    endtask : run_phase

endclass : alu_command_monitor