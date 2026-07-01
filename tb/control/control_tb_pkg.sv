package control_tb_pkg;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import cpu_consts::*;

    import "DPI-C" function void control_golden(
        input int unsigned r_type_i,
        input int unsigned i_type_i,
        input int unsigned s_type_i,
        input int unsigned b_type_i,
        input int unsigned u_type_i,
        input int unsigned j_type_i,
        input int unsigned system_type_i,
        input int unsigned instr_funct3_i,
        input int unsigned instr_funct12_i,
        input int unsigned instr_opcode_i,
        output int unsigned pc_sel_o,
        output int unsigned opa_sel_o,
        output int unsigned opb_sel_o,
        output int unsigned exu_func_sel_o,
        output int unsigned rd_src_o,
        output int unsigned csr_en_o,
        output int unsigned csr_rw_o,
        output int unsigned data_req_o,
        output int unsigned data_byte_o,
        output int unsigned bypass_avail_o,
        output int unsigned data_wr_o,
        output int unsigned zero_extnd_o,
        output int unsigned rf_wr_en_o,
        output int unsigned word_op_o,
        output int unsigned alu_instr_o,
        output int unsigned mul_instr_o,
        output int unsigned div_instr_o,
        output int unsigned mret_o,
        output int unsigned wfi_o,
        output int unsigned exc_valid_o,
        output int unsigned exc_code_o
    );

    `include "control_command_transaction.svh"
    `include "control_result_transaction.svh"

    typedef uvm_sequencer #(control_command_transaction) control_sequencer;

    `include "control_agent_config.svh"
    `include "control_random_sequence.svh"
    `include "control_driver.svh"
    `include "control_command_monitor.svh"
    `include "control_result_monitor.svh"
    `include "control_coverage.svh"
    `include "control_scoreboard.svh"
    `include "control_agent.svh"
    `include "control_env.svh"
    `include "control_base_test.svh"
    `include "control_random_test.svh"

endpackage : control_tb_pkg