`uvm_analysis_imp_decl(_cmd)
`uvm_analysis_imp_decl(_reset)

class rf_coverage extends uvm_component;
    `uvm_component_utils(rf_coverage)

    uvm_analysis_imp_cmd #(rf_command_transaction, rf_coverage)     cmd_export;
    uvm_analysis_imp_reset #(rf_reset_transaction, rf_coverage)     reset_export;

    logic [4:0]     rs1_addr_i;
    logic [4:0]     rs2_addr_i;
    logic [4:0]     rd_addr_i;
    logic           wr_en_i;
    logic [63:0]    wr_data_i;

    logic           reset_delay;
    logic           reset_duration;

    //TODO: covergroups

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cmd_export      =   new("cmd_export", this);
        reset_export    =   new("reset_export", this);
    endfunction : build_phase

    function void write_cmd(rf_command_transaction cmd);
        //TODO: sample each covergroup
    endfunction : write_cmd

    function void write_reset(rf_reset_transaction reset);
        //TODO: sample each covergroup
    endfunction : write_reset

endclass : rf_coverage