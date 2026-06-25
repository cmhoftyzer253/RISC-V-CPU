package rf_tb_pkg;
    `include "uvm_macros.svh"

    import uvm_pkg::*;
    import cpu_consts::*;

    import "DPI-C" function void rf_golden(
        input int                   resetn, 
        input int                   rs1_addr_i;
        input int                   rs2_addr_i;
        output longint unsigned     rs1_data_o;
        output longint unsigned     rs2_data_o;
        input int                   rd_addr_i;
        input int                   wr_en_i;
        input longint unsigned      wr_data_i; 
    );

    `include "rf_command_transaction.svh"
    `include "rf_result_transaction.svh"
    `include "rf_reset_transaction.svh"

    typedef uvm_sequencer #(rf_command_transaction) rf_command_sequencer;
    typedef uvm_sequencer #(rf_reset_transaction) rf_reset_sequencer;

    `include "rf_agent_config.svh"
    `include "rf_reset_agent_config.svh"

    `include "rf_driver.svh"
    `include "rf_reset_driver.svh"

    `include "rf_command_monitor.svh"
    `include "rf_result_monitor.svh"
    `include "rf_reset_monitor.svh"

    `include "rf_agent.svh"
    `include "rf_reset_agent.svh"

    `include "rf_scoreboard.svh"

    `include "rf_virtual_sequencer.svh"
    `include "rf_env.svh"

    `include "rf_command_sequence.svh"
    `include "rf_reset_sequence.svh"
    `include "rf_virtual_sequence.svh"
    `include "rf_random_test.svh"
    
endpackage : rf_tb_pkg