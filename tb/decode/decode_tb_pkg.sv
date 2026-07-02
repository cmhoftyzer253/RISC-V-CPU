package decode_tb_pkg;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import cpu_consts::*;

    import "DPI-C" function void decode_golden(
        input int unsigned      instr_i,
        output int unsigned     rs1_o,
        output int unsigned     rs2_o,
        output int unsigned     rd_o,
        output int unsigned     op_o,
        output int unsigned     funct3_o,
        output int unsigned     funct12_o,
        output int unsigned     csr_addr_o,
        output int unsigned     r_type_o,
        output int unsigned     i_type_o,
        output int unsigned     s_type_o,
        output int unsigned     b_type_o,
        output int unsigned     u_type_o,
        output int unsigned     j_type_o,
        output int unsigned     system_type_o,
        output longint unsigned imm_o,
        output int unsigned     exc_valid_o,
        output int unsigned     exc_code_o
    );

    `include "decode_command_transaction.svh"
    `include "decode_r_type_command_transaction.svh"
    `include "decode_i_type_command_transaction.svh"
    `include "decode_s_type_command_transaction.svh"
    `include "decode_b_type_command_transaction.svh"
    `include "decode_u_type_command_transaction.svh"
    `include "decode_j_type_command_transaction.svh"
    `include "decode_system_type_command_transaction.svh"
    `include "decode_exc_type_command_transaction.svh"
    `include "decode_result_transaction.svh"

    typedef uvm_sequencer #(decode_command_transaction) decode_sequencer;

    `include "decode_random_sequence.svh"
    `include "decode_driver.svh"
    `include "decode_command_monitor.svh"
    `include "decode_result_monitor.svh"
    `include "decode_coverage.svh"
    `include "decode_scoreboard.svh"
    `include "decode_agent_config.svh"
    `include "decode_agent.svh"
    `include "decode_env.svh"
    `include "decode_base_test.svh"
    `include "decode_random_test.svh"

endpackage : decode_tb_pkg