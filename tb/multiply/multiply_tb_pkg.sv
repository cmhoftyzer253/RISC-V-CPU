package multiply_tb_pkg;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import cpu_consts::*;

    import "DPI-C" function void multiply_golden(
        input longint       opr_a_i,
        input longint       opr_b_i,
        input int unsigned  mul_func_i,
        input int unsigned  word_op_i,
        output longint      mul_res_o
    );

    `include "multiply_command_transaction.svh"
    `include "multiply_result_transaction.svh"
    `include "multiply_ready_transaction.svh"
    `include "multiply_flush_transaction.svh"
    `include "multiply_reset_transaction.svh"

    typedef uvm_sequencer #(multiply_command_transaction)   multiply_command_sequencer;
    typedef uvm_sequencer #(multiply_ready_transaction)     multiply_ready_sequencer;
    typedef uvm_sequencer #(multiply_flush_transaction)     multiply_flush_sequencer;
    typedef uvm_sequencer #(multiply_reset_transaction)     multiply_reset_sequencer;

    `include "multiply_command_agent_config.svh"
    `include "multiply_result_agent_config.svh"
    `include "multiply_flush_agent_config.svh"
    `include "multiply_reset_agent_config.svh"

    `include "multiply_command_driver.svh"
    `include "multiply_ready_driver.svh"
    `include "multiply_flush_driver.svh"
    `include "multiply_reset_driver.svh"

    `include "multiply_command_monitor.svh"
    `include "multiply_result_monitor.svh"
    `include "multiply_flush_monitor.svh"
    `include "multiply_reset_monitor.svh"

    `include "multiply_command_agent.svh"
    `include "multiply_result_agent.svh"
    `include "multiply_flush_agent.svh"
    `include "multiply_reset_agent.svh"

    `include "multiply_virtual_sequencer.svh"
    `include "multiply_env.svh"
    
    `include "multiply_command_sequence.svh"
    `include "multiply_ready_sequence.svh"
    `include "multiply_flush_sequence.svh"
    `include "multiply_reset_sequence.svh"
    `include "multiply_virtual_sequence.svh"
    `include "multiply_random_test.svh"

endpackage : multiply_tb_pkg