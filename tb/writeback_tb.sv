`timescale 1ns/1ps
import cpu_consts::*;

module tb_writeback;

    logic [63:0] alu_res_i;
    logic [63:0] data_mem_rd_i;
    logic [63:0] instr_imm_i;
    logic [63:0] pc_val_i;
    logic [1:0]  rf_wr_data_src_i;
    logic [1:0]  data_byte_en_i;
    logic        data_zero_extnd_i;
    logic [2:0]  data_mem_row_idx_i;
    logic [63:0] rf_wr_data_o;

    writeback dut(
        .alu_res_i          (alu_res_i),
        .data_mem_rd_i      (data_mem_rd_i),
        .instr_imm_i        (instr_imm_i),
        .pc_val_i           (pc_val_i),
        .rf_wr_data_src_i   (rf_wr_data_src_i),
        .data_byte_en_i     (data_byte_en_i),
        .data_zero_extnd_i  (data_zero_extnd_i),
        .data_mem_row_idx_i (data_mem_row_idx_i),
        .rf_wr_data_o       (rf_wr_data_o)
    );

    typedef struct packed {
        logic [63:0] alu_res;
        logic [63:0] data_mem_rd;
        logic [63:0] instr_imm;
        logic [63:0] pc_val;
        logic [1:0]  rf_wr_data_src;
        logic [1:0]  data_byte_en;
        logic        data_zero_extnd;
        logic [2:0]  data_mem_row_idx;
        logic [63:0] rf_wr_data_expected;
    } test_vect_t;

    //testcases - TODO
    test_vect_t test_vect [:] = '{  
        '{},
        '{}
    };

    typedef struct packed {
        logic [63:0] rf_wr_data_got;
    } got_vect_t;

    got_vect_t got_vect;

    typedef struct packed {
        logic [63:0] rf_wr_data_expected;
    } exp_vect_t;

    exp_vect_t exp_vect;

    initial begin
        $display("-------- Starting Writeback Tests --------");

        foreach(test_vect[i]) begin
            //drive inputs
            alu_res_i           = test_vect[i].alu_res;
            data_mem_rd_i       = test_vect[i].data_mem_rd;
            instr_imm_i         = test_vect[i].instr_imm;
            pc_val_i            = test_vect[i].pc_val;
            rf_wr_data_src_i    = test_vect[i].rf_wr_data_src;
            data_byte_en_i      = test_vect[i].data_byte_en;
            data_zero_extnd_i   = test_vect[i].data_zero_extnd;
            data_mem_row_idx_i  = test_vect[i].data_mem_row_idx_i;

            //update expected values
            exp_vect = '{
                test_vect[i].rf_wr_data_expected
            };

            #1ns //TODO - TBD

            //capture results
            got_vect = '{
                rf_wr_data_o
            };

            if(got_vect !== exp_vect) begin
                $error("FAILED TESTCASE [%0d]:\n    got: %p\n   expected: %p",
                        i, got_vect, exp_vect);
            end else begin
                $display("PASSED TESTCASE [%0d]", i);
            end
        end
        
        $display("-------- ALU Tests Finished --------");
    end
    
endmodule