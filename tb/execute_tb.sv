`timescale 1ns/1ps
import cpu_consts::*;

module tb_execute;

    logic [63:0] opr_a_i;
    logic [63:0] opr_b_i;
    logic [3:0]  alu_func_i;
    logic [63:0] alu_res_o;

    //DUT
    execute dut(
        .opr_a_i    (opr_a_i),
        .opr_b_i    (opr_b_i),
        .alu_func_i (alu_func_i),
        .alu_res_o  (alu_res_o)
    );

    typedef struct packed {
        logic [63:0] opr_a;
        logic [63:0] opr_b;
        logic [3:0]  alu_func;
        logic [63:0] alu_res_expected;
    } test_vect_t;

    //testcases - TODO
    test_vect_t test_vect[:] = '{
        '{},    //OP_ADD
        '{},    //OP_SUB
        '{},    //OP_SLL
        '{},    //OP_SRL
        '{},    //OP_SRA
        '{},    //OP_OR 
        '{},    //OP_AND
        '{},    //OP_XOR
        '{},    //OP_SLTU
        '{},    //OP_SLT
    };

    typdef struct packed {
        logic [63:0] alu_res_got;
    } got_vect_t;

    got_vect_t got_vect;

    typedef struct packed {
        logic [63:0] alu_res_expected;
    } exp_vect_t;

    exp_vect_t exp_vect;

    initial begin
        $display("-------- Starting ALU Tests --------");

        foreach(test_vect[i]) begin
            //drive inputs
            opr_a_i = test_vect[i].opr_a;
            opr_b_i = test_vect[i].opr_b;
            alu_func_i = test_vect[i].alu_func;

            //update expected values
            exp_vect = '{
                test_vect[i].alu_res_expected
            };

            #1ns //TODO - TBD

            //capture results
            got_vect = '{
                alu_res_o
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