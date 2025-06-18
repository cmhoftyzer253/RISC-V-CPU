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

    test_vect_t test_vect[0:46] = '{ 

        //---------------------- BEQ ----------------------       
        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_1234,
            instr_funct_3 : 3'b000,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a == b

        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_5678,
            instr_funct_3 : 3'b000,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a != b
        
        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            instr_funct_3 : 3'b000,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b
        };    // a == 0 == 0 == b

        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_1234,
            instr_funct_3 : 3'b000,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    //a == b, not b instruction

        //---------------------- BNE ----------------------
        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_1234,
            instr_funct_3 : 3'b001,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a == b

        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_5678,
            instr_funct_3 : 3'b001,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1            
        };    // a != b

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            instr_funct_3 : 3'b001,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0            
        };    // a == 0 == 0 == b

        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_1234_0000,
            instr_funct_3 : 3'b001,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0            
        };    // a != b, not b instruction  

        //---------------------- BLT ----------------------
        '{
            opr_a : 64'h0000_0000_0000_00A0,
            opr_b : 64'h0000_0000_0000_0050,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0 
        };    // a > b, both positive

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFA0,
            opr_b : 64'hFFFF_FFFF_FFFF_FF10,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a > b, both negative

        '{
            opr_a : 64'h0000_0000_0000_0020,
            opr_b : 64'h0000_0000_0000_00F0,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a < b, both positive

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFA0,
            opr_b : 64'hFFFF_FFFF_FFFF_FF10,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a < b, both negative 

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FE00,
            opr_b : 64'h0000_0000_0000_0100,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // |a| > |b|, a negative, b positive

        '{
            opr_a : 64'h0000_0000_0000_0100,
            opr_b : 64'hFFFF_FFFF_FFFF_FFF50,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // |a| > |b|, a positive, b negative

        '{
            opr_a : 64'h0000_0000_0000_0010,
            opr_b : 64'hFFFF_FFFF_FFFF_FF80,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // |a| < |b|, a positive, b negative 

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFE0,
            opr_b : 64'h0000_0000_0000_0120,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // |a| < |b|, a negative, b positive 

        '{
            opr_a : 64'h0000_CBA9_8765_4321,
            opr_b : 64'h0000_CBA9_8765_4321,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a == b 

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a == 0 == 0 == b 

        '{
            opr_a : 64'h0000_0000_0000_0020,
            opr_b : 64'h0000_0000_0000_00F0,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    // a < b, both positive, not b instruction

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FE00,
            opr_b : 64'h0000_0000_0000_0100,
            instr_funct_3 : 3'b100,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    // |a| > |b|, a negative, b positive, not b instruction

        //---------------------- BGE ----------------------
        '{
            opr_a : 64'h0000_0000_0000_00A0,
            opr_b : 64'h0000_0000_0000_0050,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a > b, both positive

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FF00,
            opr_b : 64'hFFFF_FFFF_FFFF_FF80,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a > b, both negative

        '{
            opr_a : 64'h0000_0000_0000_0020,
            opr_b : 64'h0000_0000_0000_00F0,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a < b, both positive

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFA0,
            opr_b : 64'hFFFF_FFFF_FFFF_FF10,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a < b, both negative

        '{
            opr_a : 64'h0000_0000_0000_0020,
            opr_b : 64'hFFFF_FFFF_FFFF_FF80,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // |a| < |b|, a positive, b negative

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFF0,
            opr_b : 64'h0000_0000_0000_0080,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // |a| < |b|, a negative, b positive

        '{
            opr_a : 64'h0000_0000_0000_0200,
            opr_b : 64'hFFFF_FFFF_FFFF_FF80,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // |a| > |b|, a positive, b negative

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FE00,
            opr_b : 64'h0000_0000_0000_0100,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // |a| > |b|, a negative, b positive

        '{
            opr_a : 64'h0000_CBA9_8765_4321,
            opr_b : 64'h0000_CBA9_8765_4321,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a == b

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a == 0 == 0 == b

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FF00,
            opr_b : 64'hFFFF_FFFF_FFFF_FF80,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    // a > b, both negative, not b instruction

        '{
            opr_a : 64'h0000_0000_0000_0200,
            opr_b : 64'hFFFF_FFFF_FFFF_FF80,
            instr_funct_3 : 3'b101,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    // |a| > |b|, a positive, b negative, not b instruction

        //---------------------- BLTU ----------------------
        '{
            opr_a : 64'hF000_0000_0000_0000,
            opr_b : 64'h1000_0000_0000_0000,
            instr_funct_3 : 3'b110,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a > b

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'h0000_0000_0000_0001,
            instr_funct_3 : 3'b110,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a > b

        '{
            opr_a : 64'h1000_0000_0000_0000,
            opr_b : 64'hF000_0000_0000_0000,
            instr_funct_3 : 3'b110,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a < b

        '{
            opr_a : 64'h0000_0000_0000_0001,
            opr_b : 64'hFFFF_FFFF_FFFF_FFFF,
            instr_funct_3 : 3'b110,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a < b

        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_1234,
            instr_funct_3 : 3'b110,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a == b

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            instr_funct_3 : 3'b110,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a == 0 == 0 == b

        {
            opr_a : 64'h1000_0000_0000_0000,
            opr_b : 64'hF000_0000_0000_0000,
            instr_funct_3 : 3'b110,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    // a < b, not b instruction


        //---------------------- BGEU ----------------------
        '{
            opr_a : 64'hF000_0000_0000_0000,
            opr_b : 64'h1000_0000_0000_0000,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a > b

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'h0000_0000_0000_0001,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a > b

        '{
            opr_a : 64'h1000_0000_0000_0000,
            opr_b : 64'hF000_0000_0000_0000,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a < b

        '{
            opr_a : 64'h0000_0000_0000_1,
            opr_b : 64'hFFFF_FFFF_FFFF_FFFF,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b0
        };    // a < b

        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_1234,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a == b

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b1,
            branch_taken_expected : 1'b1
        };    // a == 0 == 0 == b

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'h0000_0000_0000_0001,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    // a > b, not b instruction

        '{
            opr_a : 64'h0000_0000_0000_1234,
            opr_b : 64'h0000_0000_0000_1234,
            instr_funct_3 : 3'b111,
            is_b_type : 1'b0,
            branch_taken_expected : 1'b0
        };    // a == b, not b instruction
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