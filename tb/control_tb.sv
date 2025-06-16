`timescale 1ns/1ps
import cpu_consts::*;

module tb_control;

    logic       is_r_type_i;
    logic       is_i_type_i;
    logic       is_s_type_i;
    logic       is_b_type_i;
    logic       is_u_type_i;
    logic       is_j_type_i;
    logic [2:0] instr_funct3_i;
    logic       instr_funct7_bit5_i;
    logic [6:0] instr_opcode_i;

    logic       pc_sel_o;
    logic       op1_sel_o;
    logic       op2_sel_o;
    logic [3:0] alu_func_sel_o;
    logic [1:0] rf_wr_data_src_o;
    logic       data_req_o;
    logic [1:0] data_byte_o;
    logic       data_wr_o;
    logic       zero_extnd_o;
    logic       rf_wr_en_o;

    //DUT
    control dut(
        .is_r_type_i            (is_r_type_i),
        .is_i_type_i            (is_i_type_i),
        .is_s_type_i            (is_s_type_i),
        .is_b_type_i            (is_b_type_i),
        .is_u_type_i            (is_u_type_i),
        .is_j_type_i            (is_j_type_i),
        .instr_funct3_i         (instr_funct3_i),
        .instr_funct7_bit5_i    (instr_funct7_bit5_i),
        .instr_opcode_i         (instr_opcode_i),
        .pc_sel_o               (pc_sel_o),
        .op1_sel_o              (op1_sel_o),
        .op2_sel_o              (op2_sel_o),
        .alu_func_sel_o         (alu_func_sel_o),
        .rf_wr_data_src_o       (rf_wr_data_src_o),
        .data_req_o             (data_req_o),
        .data_byte_o            (data_byte_o),
        .data_wr_o              (data_wr_o),
        .zero_extnd_o           (zero_extnd_o),
        .rf_wr_en_o             (rf_wr_en_o)
    );

    typedef struct packed {
        logic       is_r_type;
        logic       is_i_type;
        logic       is_s_type;
        logic       is_b_type;
        logic       is_u_type;
        logic       is_j_type;
        logic [2:0] instr_funct3;
        logic       instr_funct7_bit5;
        logic [6:0] instr_opcode;
        logic       pc_sel_expected;
        logic       op1_sel_expected;
        logic       op2_sel_expected;
        logic [3:0] alu_func_sel_expected;
        logic [1:0] rf_wr_data_src_expected;
        logic       data_req_expected;
        logic [1:0] data_byte_expected;
        logic       data_wr_expected;
        logic       zero_extnd_expected;
    } test_vect_t;

    //testcases - TODO
    test_vect_t test_vect[0:36] = '{
        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b000,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //ADD

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b111,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_AND,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //AND

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b110,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_OR,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //OR

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b001,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_SLL,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SLL

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b010,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_SLT,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SLT

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b011,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_SLTU,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SLTU

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b101,
            instr_funct7_bit5 : 1'b1,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_SRA,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SRA

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b101,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_SRL,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SRL

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b000,
            instr_funct7_bit5 : 1'b1,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_SUB,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SUB

        '{
            is_r_type : 1'b1,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b100,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : R_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_XOR,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //XOR

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b000,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //ADDI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b111,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_AND,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //ANDI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b110,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_OR,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //ORI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b001,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_SLL,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SLLI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b101,
            instr_funct7_bit5 : 1'b1,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_SRAI,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SRAI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b101,
            instr_funct7_bit5 : 1'b0,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_SRLI,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SRLI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b010,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_SLT,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SLTI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b011,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_SLTU,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //SLTIU

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b100,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_XOR,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //XORI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b000,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_0,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : MEM,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //LB

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b001,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_0,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : MEM,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b01,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //LH

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b010,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_0,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : MEM,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b10,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //LW

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b100,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_0,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : MEM,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b1,
            rf_wr_en_expected : 1'b0
        };    //LBU

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b101,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_0,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : MEM,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b01,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b1,
            rf_wr_en_expected : 1'b0
        };    //LHU

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b1,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b000,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : I_TYPE_2,
            pc_sel_expected : 1'b1,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : PC,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //JALR

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b1,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b000,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : S_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b1,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //SB

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b1,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b001,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : S_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b01,
            data_wr_expected : 1'b1,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //SH

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b1,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b010,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : S_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b1,
            data_byte_expected : 2'b10,
            data_wr_expected : 1'b1,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //SW

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b1,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b000,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : B_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //BEQ

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b1,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b001,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : B_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //BNE

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b1,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b100,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : B_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //BLT

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b1,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b101,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : B_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //BGE

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b1,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b110,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : B_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //BLTU

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b1,
            is_u_type : 1'b0,
            is_j_type : 1'b0,
            instr_funct3 : 3'b111,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : B_TYPE,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b0
        };    //BGEU

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b1,
            is_j_type : 1'b0,
            instr_funct3 : 3'bxxx,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : U_TYPE_1,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : ALU,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //AUIPC

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b1,
            is_j_type : 1'b0,
            instr_funct3 : 3'bxxx,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : U_TYPE_0,
            pc_sel_expected : 1'b0,
            op1_sel_expected : 1'b0,
            op2_sel_expected : 1'b0,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : IMM,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //LUI

        '{
            is_r_type : 1'b0,
            is_i_type : 1'b0,
            is_s_type : 1'b0,
            is_b_type : 1'b0,
            is_u_type : 1'b0,
            is_j_type : 1'b1,
            instr_funct3 : 3'bxxx,
            instr_funct7_bit5 : 1'bx,
            instr_opcode : J_TYPE,
            pc_sel_expected : 1'b1,
            op1_sel_expected : 1'b1,
            op2_sel_expected : 1'b1,
            alu_func_sel_expected : OP_ADD,
            rf_wr_data_src_expected : PC,
            data_req_expected : 1'b0,
            data_byte_expected : 2'b00,
            data_wr_expected : 1'b0,
            zero_extnd_expected : 1'b0,
            rf_wr_en_expected : 1'b1
        };    //JAL
    };

    typedef struct packed {
        logic       pc_sel_got;
        logic       op1_sel_got;
        logic       op2_sel_got;
        logic [3:0] alu_func_sel_got;
        logic [1:0] rf_wr_data_src_got;
        logic       data_req_got;
        logic [1:0] data_byte_got;
        logic       data_wr_got;
        logic       zero_extnd_got;
        logic       rf_wr_en_got;
    } got_vect_t;

    //capture DUT outputs for each test
    got_vect_t got_vect;

    typedef struct packed {
        logic       pc_sel_expected;
        logic       op1_sel_expected;
        logic       op2_sel_expected;
        logic [3:0] alu_func_sel_expected;
        logic [1:0] rf_wr_data_src_expected;
        logic       data_req_expected;
        logic [1:0] data_byte_expected;
        logic       data_wr_expected;
        logic       zero_extnd_expected;
        logic       rf_wr_en_expected;
    } exp_vect_t;

    //capture expected values for each test
    exp_vect_t exp_vect;

    initial begin
        $display("-------- Starting Control Unit Tests --------");

        foreach(test_vect[i]) begin
            //drive inputs
            is_r_type_i               = test_vect[i].is_r_type;
            is_i_type_i               = test_vect[i].is_i_type;
            is_s_type_i               = test_vect[i].is_s_type;
            is_b_type_i               = test_vect[i].is_b_type;
            is_u_type_i               = test_vect[i].is_u_type;
            is_j_type_i               = test_vect[i].is_j_type;
            instr_funct3_i            = test_vect[i].instr_funct3;
            instr_funct7_bit5_i       = test_vect[i].instr_funct7_bit5;
            instr_opcode_i            = test_vect[i].instr_opcode;

            //update expected values
            exp_vect = '{
                test_vect[i].pc_sel_expected,
                test_vect[i].op1_sel_expected,
                test_vect[i].op2_sel_expected,
                test_vect[i].alu_func_sel_expected,
                test_vect[i].rf_wr_data_src_expected,
                test_vect[i].data_req_expected,
                test_vect[i].data_byte_expected,
                test_vect[i].data_wr_expected,
                test_vect[i].zero_extnd_expected,
                test_vect[i].rf_wr_en_expected
            };

            #1ns  //TODO - TBD

            //capture results
            got_vect = '{
                pc_sel_o,
                op1_sel_o,
                op2_sel_o,
                alu_func_sel_o,
                rf_wr_data_src_o,
                data_req_o,
                data_byte_o,
                data_wr_o,
                zero_extnd_o,
                rf_wr_en_o
            };

            if (got_vect !== exp_vect) begin
                $error("FAILED TESTCASE [%0d]:\n    got : %p\n    expected : %p",
                        i, got_vect, exp_vect);
            end else begin
                $display("PASSED TESTCASE [%0d]", i);           
            end
        end

        $display("-------- Control Unit Tests Finished --------");
        $finish        
    end

endmodule