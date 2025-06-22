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

    test_vect_t test_vect[0:55] = '{

        //---------------------- OP_ADD ----------------------
        '{
            opr_a : 64'h4B67_1ABD_753D_4193,
            opr_b : 64'h56FA_B6F1_4917_F3D7,
            alu_func : 4'b0000,
            alu_res_expected : 64'hA261_D2C2_BE55_256A
        },    // positive + positive

        '{
            opr_a : 64'h40D4_A0CC_91F5_9E85,
            opr_b : 64'hCFB4_3C11_4688_4DBC,
            alu_func : 4'b0000,
            alu_res_expected : 64'h10B0_6CB2_4B6B_2481
        },    // positive + negative (|a| > |b|)

        '{
            opr_a : 64'h2764_C8D7_A164_6D51,
            opr_b : 64'h96C9_4910_867B_4A15,
            alu_func : 4'b0000,
            alu_res_expected : 64'hBE48_C916_E18F_8566 
        },    // positive + negative (|a| < |b|)

        '{
            opr_a : 64'hD089_9315_7DDC_D9FD,
            opr_b : 64'h8326_54C2_4ED1_70D3,
            alu_func : 4'b0000,
            alu_res_expected : 64'hEBFF_E0A8_3351_B453
        },    // negative + negative

        '{
            opr_a : 64'h1BB5_9614_9168_6696,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0000,
            alu_res_expected : 64'h1BB5_9614_9168_6696
        },    // positive + 0

        '{
            opr_a : 64'hBD12_AF8E_231B_8371,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0000,
            alu_res_expected : 64'hBD12_AF8E_231B_8371 
        },    // negative + 0

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0000,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // 0 + 0

        //---------------------- OP_SUB ----------------------
        '{
            opr_a : 64'h30A3_1F11_8F3B_EBCF,
            opr_b : 64'h276B_3FCA_90F5_606C,
            alu_func : 4'b0001,
            alu_res_expected : 64'h097C_DE06_6FEC_4AF3
        },    // positive - positive (a > b)

        '{
            opr_a : 64'h45F2_97CF_E63F_1EA5,
            opr_b : 64'h5685_55DE_8035_BD64,
            alu_func : 4'b0001,
            alu_res_expected : 64'hEF7D_41F0_65D9_D141
        },    // positive - positive (a < b)

        '{
            opr_a : 64'h150548E4FFC8D57F,
            opr_b : 64'hB7FB_1A90_84D3_456F,
            alu_func : 4'b0001,
            alu_res_expected : 64'h5CC0_9054_7B9B_1E30
        },    // positive - negative

        '{
            opr_a : 64'hB5DC_8C32_5451_3A5A,
            opr_b : 64'h05CA_B3F0_AF7E_D48F,
            alu_func : 4'b0001,
            alu_res_expected : 64'hB0A1_DC41_A4FD_05EB
        },    // negative - positive

        '{
            opr_a : 64'hAAD6_F276_B867_2D5A,
            opr_b : 64'hB38C_7A3D_BCCF_EB2C,
            alu_func : 4'b0001,
            alu_res_expected : 64'hF6D0_E898_FCC8_3DB2
        },    // negative - negative (a > b)

        '{
            opr_a : 64'hD2A4_B4C4_2908_F9A6,
            opr_b : 64'h93DB_36E0_64A5_37E3,
            alu_func : 4'b0001,
            alu_res_expected : 64'h3F29_425E_CAFA_B773
        },    // negative - negative (a < b)

        '{
            opr_a : 64'h5B6B_C938_FB0A_EAF6,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0001,
            alu_res_expected : 64'h5B6B_C938_FB0A_EAF6
        },    // positive - 0

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h300D_1B78_3E0A_E0A9,
            alu_func : 4'b0001,
            alu_res_expected : 64'h300D_1B78_3E0A_E0A9
        },    // 0 - positive

        '{
            opr_a : 64'hA6C0_CB07_30BE_D42E,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0001,
            alu_res_expected : 64'hA6C0_CB07_30BE_D42E
        },    // negative - 0

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h848F_7A07_B377_A6E7,
            alu_func : 4'b0001,
            alu_res_expected : 64'h848F_7A07_B377_A6E7
        },    // 0 - negative 

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0001,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // 0 - negative

        //---------------------- OP_SLL ----------------------
        '{
            opr_a : 64'h0000_0000_0000_0001,
            opr_b : 64'h0000_0000_0000_0005,
            alu_func : 4'b0010,
            alu_res_expected : 64'h0000_0000_0000_0020
        },    // shift 5 left

        '{
            opr_a : 64'h0000_0000_0000_0001,
            opr_b : 64'h0000_0000_0000_001F,
            alu_func : 4'b0010,
            alu_res_expected : 64'h0000_0000_8000_0000
        },    // shift 31 left

        '{
            opr_a : 64'h0000_0000_0000_0001,
            opr_b : 64'h0000_0000_0000_003F,
            alu_func : 4'b0010,
            alu_res_expected : 64'h8000_0000_0000_0000
        },    // shift 63 left

        '{
            opr_a : 64'h0000_0000_0000_0001,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0010,
            alu_res_expected : 64'h0000_0000_0000_0001
        },    // shift 0 left

        //---------------------- OP_SRL ----------------------
        '{
            opr_a : 64'h8000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0005,
            alu_func : 4'b0011,
            alu_res_expected : 64'h0400_0000_0000_0000
        },    // shift 5 right - logic

        '{
            opr_a : 64'h8000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_001F,
            alu_func : 4'b0011,
            alu_res_expected : 64'h0000_0001_0000_0000
        },    // shift 31 right - logic

        '{
            opr_a : 64'h8000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_003F,
            alu_func : 4'b0011,
            alu_res_expected : 64'h0000_0000_0000_0001
        },    // shift 63 right - logic

        '{
            opr_a : 64'h8000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0011,
            alu_res_expected : 64'h8000_0000_0000_0000
        },    // shift 0 right 

        //---------------------- OP_SRA ----------------------
        '{
            opr_a : 64'hFFFF_FFFF_FFFF_F000,
            opr_b : 64'h0000_00000_0000_0005,
            alu_func : 4'b0100,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_F000
        },    // shift 5 arithmetic - negative

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_F000,
            opr_b : 64'h0000_0000_0000_001F,
            alu_func : 4'b0100,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_FE00
        },    // shift 31 arithmetic - negative

        '{
            opr_a : 64'h8000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_003F,
            alu_func : 4'b0100,
            alu_res_expected : 64'FFFF_FFFF_FFFF_FFFF
        },    // shift 63 arithmetic - negative

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_F000,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0100,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_F000
        },    // shift 0 arithmetic - negative

        '{
            opr_a : 64'h0000_0000_0000_8000,
            opr_b : 64'h0000_0000_0000_0005,
            alu_func : 4'b0100,
            alu_res_expected : 64'h0000_0000_0000_0400
        },    // shift 5 arithmetic - positive

        '{
            opr_a : 64'h0000_0000_8000_0000,
            opr_b : 64'h0000_0000_0000_001F,
            alu_func : 4'b0100,
            alu_res_expected : 64'h0000_0000_0000_0001
        },    // shift 31 arithmetic - positive

        '{
            opr_a : 64'h4000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_003F,
            alu_func : 4'b0100,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // shift 63 arithmetic - positive

        '{
            opr_a : 64'h0000_0000_0000_8000,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0100,
            alu_res_expected : 64'h0000_0000_0000_8000
        },    // shift 0 arithmetic - positive

        //---------------------- OP_OR ----------------------
        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b0101,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_FFFF
        },

        '{
            opr_a : 64'hFFFF_0000_FFFF_0000,
            opr_b : 64'h0000_FFFF_0000_FFFF,
            alu_func : 4'b0101,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_FFFF
        },  

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'hFFFF_FFFF_FFFF_FFFF,
            alu_func : 4'b0101,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_FFFF
        },  

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_FFFF_0000,
            alu_func : 4'b0101,
            alu_res_expected : 64'h0000_0000_FFFF_0000

        },    

        //---------------------- OP_AND ----------------------
        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'hFFFF_FFFF_FFFF_FFFF,
            alu_func : 4'b0110,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_FFFF
        },

        '{
            opr_a : 64'hFFFF_0000_FFFF_0000,
            opr_b : 64'hFFFF_FFFF_FFFF_FFFF,
            alu_func : 4'b0110,
            alu_res_expected : 64'hFFFF_0000_FFFF_0000
        },    

        '{
            opr_a : 64'hFFFF_0000_FFFF_0000,
            opr_b : 64'h0000_FFFF_0000_FFFF,
            alu_func : 4'b0110,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    

        //---------------------- OP_XOR ----------------------
        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'h0F0F_0F0F_0F0F_0F0F,
            alu_func : 4'b0111,
            alu_res_expected : 64'hF0F0_F0F0_F0F0_F0F0
        },

        '{
            opr_a : 64'hFFFF_FFFF_FFFF_FFFF,
            opr_b : 64'hFFFF_FFFF_FFFF_FFFF,
            alu_func : 4'b0111,
            alu_res_expected : 64'h0000_0000_0000_0000
        },   

        '{
            opr_a : 64'hFFFF_0000_FFFF_0000,
            opr_b : 64'h0000_FFFF_0000_FFFF,
            alu_func : 4'b0111,
            alu_res_expected : 64'hFFFF_FFFF_FFFF_FFFF
        },    

        //---------------------- OP_SLTU ----------------------
        '{
            opr_a : 64'h2438_5200_69DB_92C2,
            opr_b : 64'h3900_F3B3_8D87_55FD,
            alu_func : 4'b1000,
            alu_res_expected : 64'h0000_0000_0000_0001
        },    // a < b

        '{
            opr_a : 64'hF53A_5E1A_9935_004C,
            opr_b : 64'h5419_2D44_F952_428C,
            alu_func : 4'b1000,
            alu_res_expected : 64'h0000_0000_0000_0000 
        },    // a > b

        '{
            opr_a : 64'h0FED_CBA9_8765_4321,
            opr_b : 64'h0FED_CBA9_8765_4321,
            alu_func : 4'b1000,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // a == b

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b1000,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // a == 0 == 0 == b

        //---------------------- OP_SLT ----------------------
        '{
            opr_a : 64'h519F_2CEC_A42F_BC63,
            opr_b : 64'h58C7_77C5_7F16_6316,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0001
        },    // a < b, both positive

        '{
            opr_a : 64'h2B74_5A5B_6727_1619,
            opr_b : 64'h25D1_59C1_EA64_0399,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // a > b, both positive

        '{
            opr_a : 64'hE834_9ECB_5170_B5DA,
            opr_b : 64'hE87D_B553_CCDF_36CA,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0001
        },    // a < b, both negative

        '{
            opr_a : 64'hF124_9FBB_D06F_1C13,
            opr_b : 64'h99F9_B207_28A0_24E4,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // a > b, both negative

        '{
            opr_a : 64'hE1D5_35F8_ED0F_EB04,
            opr_b : 64'h16FB_622B_C8CC_6052,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0001
        },    // |a| > |b|, a negative, b positive

        '{
            opr_a : 64'h0F39_CC6D_E473_D8A0,
            opr_b : 64'hB1A2_AF8B_F561_435E,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // |a| < |b|, a positive, b negative

        '{
            opr_a : 64'h0000_0000_8765_4321,
            opr_b : 64'h0000_0000_8765_4321,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // a == b

        '{
            opr_a : 64'h0000_0000_0000_0000,
            opr_b : 64'h0000_0000_0000_0000,
            alu_func : 4'b1001,
            alu_res_expected : 64'h0000_0000_0000_0000
        },    // a == 0 == 0 == b
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