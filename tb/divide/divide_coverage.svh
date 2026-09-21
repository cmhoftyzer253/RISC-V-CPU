`uvm_analysis_imp_decl(_cmd)
`uvm_analysis_imp_decl(_ready)
`uvm_analysis_imp_decl(_flush)
`uvm_anlaysis_imp_decl(_reset)

class divide_coverage extends uvm_component;
    `uvm_component_utils(divide_coverage)

    uvm_analysis_imp_cmd #(divide_command_transaction, divide_coverage)     cmd_export;
    uvm_analysis_imp_ready #(divide_ready_transaction, divide_coverage)     ready_export;
    uvm_analysis_imp_flush #(divide_flush_transaction, flush_coverage)      flush_export;
    uvm_analysis_imp_reset #(divide_reset_transaction, reset_coverage)      reset_export;

    logic [63:0]    opr_a_i;
    logic [63:0]    opr_b_i;
    logic           div_valid_i;
    r_type_m_t      div_func_i;
    logic           word_op_i;
    int unsigned    valid_delay;

    int unsigned    flush_delay;

    int unsigned    ready_delay;

    int unsigned    reset_delay;
    int unsigned    reset_duration;

    //TODO: covergroups

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cmd_export      =   new("cmd_export", this);
        ready_export    =   new("ready_export", this);
        flush_export    =   new("flush_export", this);
        reset_export    =   new("reset_export", this);
    endfunction : build_phase

    function void write_cmd(divide_command_transaction cmd);
        opr_a_i         =   cmd.opr_a_i;
        opr_b_i         =   cmd.opr_b_i;
        div_valid_i     =   cmd.div_valid_i;
        div_func_i      =   cmd.div_func_i;
        word_op_i       =   cmd.word_op_i;
        valid_delay     =   cmd.valid_delay;

        //TODO: sample each covergroup
    endfunction : write_cmd

    function void write_ready(divide_ready_transaction ready);
        ready_delay     =   ready.ready_delay;

        //TODO: sample each covergroup
    endfunction : write_ready

    function void write_flush(divide_flush_transaction flush);
        flush_delay     =   flush.flush_delay;

        //TODO: sample each covergroup
    endfunction : write_flush

    function void write_reset(divide_reset_transaction reset);
        reset_delay     =   reset.reset_delay;
        reset_duration  =   reset.reset_duration;

        //TODO: sample each covergroup
    endfunction : write_reset

endclass : divide_coverage