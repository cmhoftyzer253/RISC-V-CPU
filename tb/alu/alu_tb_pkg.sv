package alu_tb_pkg;
    `include "uvm_macros.svh"
    
    import uvm_pkg::*;
    import cpu_consts::*;

    import "DPI-C" function void alu_golden(
        input longint   opr_a_i,
        input longint   opr_b_i,
        input int       alu_valid_i,
        input int       alu_func_i,
        input int       word_op_i,
        input int       flush_i,
        output int      valid_res_o,
        output longint  alu_res_o
    );

    `include "alu_command_transaction.svh"
    `include "alu_result_transaction.svh"

    typedef uvm_sequencer #(alu_command_transaction) alu_sequencer;

    `include "alu_random_sequence.svh"
    `include "alu_driver.svh"
    `include "alu_command_monitor.svh"
    `include "alu_result_monitor.svh"
    `include "alu_coverage.svh"
    `include "alu_scoreboard.svh"
    `include "alu_agent_config.svh"
    `include "alu_agent.svh"
    `include "alu_env.svh"
    `include "alu_base_test.svh"
    `include "alu_random_test.svh"

endpackage : alu_tb_pkg