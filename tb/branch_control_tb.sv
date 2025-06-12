`timescale 1ns/1ps
import cpu_consts::*;

module tb_branch_control;

    logic [63:0]    opr_a_i;
    logic [63:0]    opr_b_i;
    logic           is_b_type_i;
    logic [2:0]     instr_funct3_i;
    logic           branch_taken_o;

    //DUT
    branch_control dut(
        .opr_a_i            (opr_a_i),
        .opr_b_i            (opr_b_i),
        .is_b_type_i        (is_b_type_i),
        .instr_funct3_i     (instr_funct3_i),
        .branch_taken_o     (branch_taken_o)
    );

    typedef struct packed {
        logic [63:0]    opr_a;
        logic [63:0]    opr_b;
        logic [2:0]     instr_funct3;
        logic           is_b_type;
        logic           branch_taken_expected;
    } test_vect_t;

    //testcases - TODO - include is_b_type = 0 cases
    test_vect_t test_vect[0:17] = '{        
        '{};    //BEQ
        '{};    //BEQ

        '{};    //BNE
        '{};    //BNE

        '{};    //BLT 
        '{};    //BLT 
        '{};    //BLT 
        '{};    //BLT 

        '{};    //BGE
        '{};    //BGE
        '{};    //BGE
        '{};    //BGE
        '{};    //BGE

        '{};    //BLTU
        '{};    //BLTU

        '{};    //BGEU
        '{};    //BGEU
        '{};    //BGEU
    };

    typedef struct packed {
        logic branch_taken_got;
    } got_vect_t;

    //capture DUT outputs for each test
    got_vect_t got_vect;

    typedef struct packed { 
        logic branch_taken_expected;
    } exp_vect_t;

    //capture expected values for each test
    exp_vect_t exp_vect;

    initial begin
        $display("-------- Starting Branch Control Tests --------");

        foreach(test_vect[i]) begin
            //drive inputs
            opr_a_i         = test_vect[i].a;
            opr_b_i         = test_vect[i].b;
            is_b_type_i     = test_vect[i].is_b_type;
            instr_funct3_i  = test_vect[i].funct;

            //update expected values
            exp_vect = '{
                test_vect[i].branch_taken_expected;
            };
            
            #1ns;                                   //TODO - TBD

            //capture results
            got_vect = '{
                branch_taken_o;
            };

            if(got_vect !== exp_vect) begin
                $error("FAILED TESTCASE [%0d]:\n    got : %p\n    expected : %p",
                        i, got_vect, exp_vect);
            end else begin
                $display("PASSED TESTCASE [%0d]", i);
            end
        end

        $display("-------- Branch Control Tests Finished --------");
        $finish
    end

endmodule