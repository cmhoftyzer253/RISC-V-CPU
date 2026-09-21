package branch_control_tb_pkg;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import cpu_consts::*;

    import "DPI-C" function void branch_control_golden(
        input longint unsigned opr_a_i,
        input longint unsigned opr_b_i,
        input int unsigned b_type_i,
        input int unsigned instr_funct3_i,
        output int unsigned branch_taken_o
    );

    `include "branch_control_command_transaction.svh"
    `include "branch_control_result_transaction.svh"

    typedef uvm_sequencer #(branch_control_command_transaction) branch_control_sequencer;

    `include "branch_control_agent_config.svh"
    `include "branch_control_random_sequence.svh"
    `include "branch_control_driver.svh"
    `include "branch_control_command_monitor.svh"
    `include "branch_control_result_monitor.svh"
    `include "branch_control_coverage.svh"
    `include "branch_control_scoreboard.svh"
    `include "branch_control_agent.svh"
    `include "branch_control_env.svh"
    `include "branch_control_base_test.svh"
    `include "branch_control_random_test.svh"

endpackage : branch_control_tb_pkg