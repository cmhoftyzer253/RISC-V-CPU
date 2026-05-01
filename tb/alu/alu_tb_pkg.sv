package alu_tb_pkg;
    `include "uvm_macros.svh"
    
    import uvm_pkg::*;
    import cpu_consts::*;

    `include "alu_command_transaction.svh"
    `include "alu_result_transaction.svh"

    typedef uvm_sequencer #(alu_command_transaction) alu_sequencer;

    `include "alu_random_sequence.svh"
    `include "alu_driver.svh"
    `include "alu_env.svh"
    `include "alu_base_test.svh"
    `include "alu_random_test.svh"

endpackage : alu_tb_pkg