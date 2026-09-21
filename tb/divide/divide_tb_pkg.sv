package divide_tb_pkg;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import cpu_consts::*;

    import "DPI-C" function void divide_golden();

    `include "divide_command_transaction.svh"
    `include "divide_result_transaction.svh"
    `include "divide_ready_transaction.svh"
    `include "divide_flush_transaction.svh"
    `include "divide_reset_transaction.svh"

    typedef uvm_sequencer #(divide_command_transaction)     divide_command_sequencer;
    typedef uvm_sequencer #(divide_ready_transaction)       divide_ready_sequencer;
    typedef uvm_sequencer #(divide_flush_transaction)       divide_flush_sequencer;
    typedef uvm_sequencer #(divide_reset_transaction)       divide_reset_sequencer;

    `include "divide_command_agent_config.svh"
    `include "divide_result_agent_config.svh"
    `include "divide_flush_agent_config.svh"
    `include "divide_reset_agent_config.svh"

    `include "divide_command_driver.svh"
    `include "divide_ready_driver.svh"
    `include "divide_flush_driver.svh"
    `include "divide_reset_driver.svh"

    `include "divide_command_monitor.svh"
    `include "divide_result_monitor.svh"
    `include "divide_flush_monitor.svh"
    `include "divide_reset_monitor.svh"

    `include "divide_command_agent.svh"
    `include "divide_result_agent.svh"
    `include "divide_flush_agent.svh"
    `include "divide_reset_agent.svh"

    `include "divide_scoreboard.svh"

    `include "divide_virtual_sequencer.svh"
    `include "divide_env.svh"

    `include "divide_command_sequence.svh"
    `include "divide_ready_sequence.svh"
    `include "divide_flush_sequence.svh"
    `include "divide_reset_sequence.svh"
    `include "divide_virtual_sequence.svh"

    `include "divide_base_test.svh"
    `include "divide_random_test.svh"
endpackage : divide_tb_pkg