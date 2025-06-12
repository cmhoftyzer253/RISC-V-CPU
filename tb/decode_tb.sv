`timescale 1ns/1ps
import cpu_consts::*;

module tb_decode;

    logic [31:0]    instr_i;
    logic [4:0]     rs1_o;
    logic [4:0]     rs2_o;
    logic [4:0]     rd_o;
    logic [4:0]     op_o;
    logic [2:0]     funct3_o;
    logic [6:0]     funct7_o;
    logic           r_type_instr_o;
    logic           i_type_instr_o;
    logic           s_type_instr_o;
    logic           b_type_instr_o;
    logic           u_type_instr_o;
    logic           j_type_instr_o;
    logic [63:0]    instr_imm_o

    //DUT
    decode dut(
        .instr_i            (instr_i),
        .rs1_o              (rs1_o),
        .rs2_o              (rs2_o),
        .rd_o               (rd_o),
        .op_o               (op_o),
        .funct3_o           (funct3_o),
        .funct7_o           (funct7_o),
        .r_type_instr_o     (r_type_instr_o),
        .i_type_instr_o     (i_type_instr_o),
        .s_type_instr_o     (s_type_instr_o),
        .b_type_instr_o     (b_type_instr_o),
        .u_type_instr_o     (u_type_instr_o),
        .j_type_instr_o     (j_type_instr_o),
        .instr_imm_o        (instr_imm_o)
    );

    typedef struct packed {
        logic [31:0]    instr;
        logic [4:0]     rs1_expected;
        logic [4:0]     rs2_expected;
        logic [4:0]     rd_expected;
        logic [6:0]     op_expected;
        logic [2:0]     funct3_expected;
        logic [6:0]     funct7_expected;
        logic           r_type_instr_expected;
        logic           i_type_instr_expected;
        logic           s_type_instr_expected;
        logic           b_type_instr_expected;
        logic           u_type_instr_expected;
        logic           j_type_instr_expected;
        logic [63:0]    instr_imm_expected;
    } test_vect_t;

    //testcases - TODO
    test_vect_t test_vect[0:35] = '{
        '{};    //ADD
        '{};    //AND
        '{};    //OR
        '{};    //SLL
        '{};    //SLT
        '{};    //SLTU
        '{};    //SRA
        '{};    //SRL
        '{};    //SUB
        '{};    //XOR
        '{};    //ADDI
        '{};    //ANDI
        '{};    //ORI
        '{};    //SLLI
        '{};    //SRXI
        '{};    //SLTI
        '{};    //SLTIU
        '{};    //XORI
        '{};    //LB
        '{};    //LH
        '{};    //LW
        '{};    //LBU
        '{};    //LHU
        '{};    //JALR
        '{};    //SB
        '{};    //SH
        '{};    //SW
        '{};    //BEQ
        '{};    //BNE
        '{};    //BLT
        '{};    //BGE
        '{};    //BLTU
        '{};    //BGEU
        '{};    //AUIPC
        '{};    //LUI
        '{};    //JAL
    };

    typedef struct packed {
        logic           rs1_got;
        logic           rs2_got;
        logic           rd_got; 
        logic           op_got; 
        logic           funct3_got;
        logic           funct7_got;
        logic           r_type_instr_got;
        logic           i_type_instr_got;
        logic           s_type_instr_got;
        logic           b_type_instr_got;
        logic           u_type_instr_got;
        logic           j_type_instr_got;
        logic [63:0]    instr_imm_got;
    } got_vect_t;

    //capture DUT outputs for each test
    got_vect_t got_vect;

    typedef struct packed {
        logic           rs1_expected;
        logic           rs2_expected;
        logic           rd_expected;
        logic           op_expected;
        logic           funct3_expected;
        logic           funct7_expected;
        logic           r_type_instr_expected;
        logic           i_type_instr_expected;
        logic           s_type_instr_expected;
        logic           b_type_instr_expected;
        logic           u_type_instr_expected;
        logic           j_type_instr_expected;
        logic [63:0]    instr_imm_expected;
    } exp_vect_t;

    //capture expected values for each test
    exp_vect_t exp_vect;
    
    initial begin
        $display("-------- Starting Decode Tests --------");

        foreach(test_vect[i]) begin
            //drive input
            instr_i = test_vect[i].instr;
            
            //update expected values
            exp_vect = '{
                test_vect[i].rs1_expected,
                test_vect[i].rs2_expected,
                test_vect[i].rd_expected,
                test_vect[i].op_expected
                test_vect[i].funct3_expected,
                test_vect[i].funct7_expected,
                test_vect[i].r_type_instr_expected,
                test_vect[i].i_type_instr_expected,
                test_vect[i].s_type_instr_expected,
                test_vect[i].b_type_instr_expected,
                test_vect[i].u_type_instr_expected,
                test_vect[i].j_type_instr_expected,
                test_vect[i].instr_imm_expected
            };

            #1ns //TODO - TBD

            //capture results
            got_vect = '{
                rs1_o,
                rs2_o,
                rd_o,
                op_o,
                funct3_o,
                funct7_o,
                r_type_instr_o,
                i_type_instr_o,
                s_type_instr_o,
                b_type_instr_o,
                u_type_instr_o,
                j_type_instr_o,
                instr_imm_o
            };

            if(got_vect !== exp_vect) begin
                $error("FAILED TESTCASE [%0d]:\n    got : %p\n    expected : %p",
                        i, got_vect, exp_vect);
            end else begin
                $display("PASSED TESTCASE [%0d]", i);
            end
        end

        $display("-------- Decode Tests Finished --------")
    end
    
endmodule
