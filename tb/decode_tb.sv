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
    test_vect_t test_vect[0:36] = '{
        '{
            instr : 32'b0000_0001_1010_1000_0000_1110_0011_0011,
            rs1_expected : 5'b10000,
            rs2_expected : 5'b11010,
            rd_expected : 5'b11100,
            op_expected : 7'b0010011,
            funct3_expected : 3'b000,
            funct7_expected : 7'10000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //ADD

        '{
            instr : 32'b0000_0000_1011_1100_0111_1100_1011_0011,
            rs1_expected : 5'b11000,
            rs2_expected : 5'b01011,
            rd_expected : 5'b11001,
            op_expected : 7'b0110011,
            funct3_expected : 3'b111,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //AND

        '{
            instr : 32'b0000_0000_0010_1000_1110_1101_1011_0011,
            rs1_expected : 5'b10001,
            rs2_expected : 5'b00010,
            rd_expected : 5'b11011,
            op_expected : 7'b0110011,
            funct3_expected : 3'b110,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //OR

        '{
            instr : 32'b0000_0000_0001_0000_0001_1000_1011_0011,
            rs1_expected : 5'00000,
            rs2_expected : 5'b00001,
            rd_expected : 5'b10001,
            op_expected : 7'b0110011,
            funct3_expected : 3'b001,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //SLL

        '{
            instr : 32'b0000_0001_0010_0100_0010_1011_1011_0011,
            rs1_expected : 5'b01000,
            rs2_expected : 5'b10010,
            rd_expected : 5'b10111,
            op_expected : 7'b0110011,
            funct3_expected : 3'b010,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //SLT

        '{
            instr : 32'b0000_0001_0010_1111_0011_0110_0011_0011,
            rs1_expected : 5'b11110,
            rs2_expected : 5'b10010,
            rd_expected : 5'b01100,
            op_expected : 7'b0110011,
            funct3_expected : 3'b011,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //SLTU

        '{
            instr : 32'b0100_0000_1001_0101_0101_0001_1011_0011,
            rs1_expected : 5'b01010,
            rs2_expected : 5'b01001,
            rd_expected : 5'b00011,
            op_expected : 7'b0110011,
            funct3_expected : 3'b101,
            funct7_expected : 7'b0100000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //SRA

        '{
            instr : 32'b0000_0000_1111_1011_0101_1011_0011_0011,
            rs1_expected : 5'b10110,
            rs2_expected : 5'b01111,
            rd_expected : 5'b10110,
            op_expected : 7'b0110011,
            funct3_expected : 3'b101,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //SRL

        '{
            instr : 32'b0100_0001_1110_1011_0000_0010_1011_0011,
            rs1_expected : 5'b10110,
            rs2_expected : 5'b1110,
            rd_expected : 5'b00101,
            op_expected : 7'b0110011,
            funct3_expected : 3'b000,
            funct7_expected : 7'b0100000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //SUB

        '{
            instr : 32'b0000_0000_1111_0110_0100_0100_1011_0011,
            rs1_expected : 5'b01100,
            rs2_expected : 5'b01111,
            rd_expected : 5'b01001,
            op_expected : 7'b0110011,
            funct3_expected : 3'b100,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b1,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : 64'h0
        };    //XOR

        '{
            instr : 32'b0010_0010_1000_1101_1000_1000_0001_0011,
            rs1_expected : 5'b11011,
            rs2_expected : 5'b01000,
            rd_expected : 5'b10000,
            op_expected : 7'b0010011,
            funct3_expected : 3'b000,
            funct7_expected : 7'b0010001,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0010_0010_1000}
        };    //ADDI

        '{
            instr : 32'b0010_1001_1011_1111_0111_0011_0001_0011,
            rs1_expected : 5'b11110,
            rs2_expected : 5'b11011,
            rd_expected : 5'b00110,
            op_expected : 7'b0010011,
            funct3_expected : 3'b111,
            funct7_expected : 7'b0010100,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0010_1001_1011}
        };    //ANDI

        '{
            instr : 32'b1010_0110_0000_0000_0110_1000_1001_0011,
            rs1_expected : 5'b00000,
            rs2_expected : 5'b00000,
            rd_expected : 5'b10001,
            op_expected : 7'b0010011,
            funct3_expected : 3'b110,
            funct7_expected : 7'b0010011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 12'b1010_0110_0000}
        };    //ORI

        '{
            instr : 32'b0000_0000_1110_1010_0001_1001_1001_0011,
            rs1_expected : 5'b10100,
            rs2_expected : 5'b01110,
            rd_expected : 5'b10011,
            op_expected : 7'b0010011,
            funct3_expected : 3'b001,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 7'b0, 5'b01110}
        };    //SLLI

        '{
            instr : 32'b0100_0001_1010_1101_0101_1000_0001_0011,
            rs1_expected : 5'b11010,
            rs2_expected : 5'11010,
            rd_expected : 5'b10000,
            op_expected : 7'b0010011,
            funct3_expected : 3'b101,
            funct7_expected : 7'b0100000,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 7'b0100000, 5'b11010}
        };    //SRAI

        '{
            instr : 32'b0000_0001_1011_0110_1101_0001_0001_0011,
            rs1_expected : 5'b01101,
            rs2_expected : 5'b11011,
            rd_expected : 5'b00010,
            op_expected : 7'b0010011,
            funct3_expected : 3'b101,
            funct7_expected : 7'b0000000,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 7'b0000000, 5'b11011}
        };    //SRLI

        '{
            instr : 32'b0000_1010_1101_0011_0010_1111_1001_0011,
            rs1_expected : 5'b00110,
            rs2_expected : 5'b01101,
            rd_expected : 5'b11111,
            op_expected : 7'b0010011,
            funct3_expected : 3'b010,
            funct7_expected : 7'b0000101,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0000_1010_1101}
        };    //SLTI

        '{
            instr : 32'b0100_0111_0110_1101_1011_1110_1001_0011,
            rs1_expected : 5'b11011,
            rs2_expected : 5'b10110,
            rd_expected : 5'b11101,
            op_expected : 7'b0010011,
            funct3_expected : 3'b011,
            funct7_expected : 7'b0100011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0100_0111_0110}
        };    //SLTIU

        '{
            instr : 32'b1011_1111_0111_1100_0100_0001_1001_0011,
            rs1_expected : 5'b11000,
            rs2_expected : 5'b10111,
            rd_expected : 5'b00011,
            op_expected : 7'b0010011,
            funct3_expected : 3'b100,
            funct7_expected : 7'b1011111,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 12'b1011_1111_1100}
        };    //XORI

        '{
            instr : 32'b0010_1000_1111_0111_0000_1011_1000_0011,
            rs1_expected : 5'b01110,
            rs2_expected : 5'b01111,
            rd_expected : 5'b10111,
            op_expected : 7'b0011111,
            funct3_expected : 3'b000,
            funct7_expected : 7'b0010100,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0010_1000_1111}
        };    //LB

        '{
            instr : 32'0011_1111_1100_1100_1001_1111_1000_0011,
            rs1_expected : 5'b11001,
            rs2_expected : 5'b11100,
            rd_expected : 5'b11111,
            op_expected : 7'b0000011,
            funct3_expected : 3'b001,
            funct7_expected : 7'b0011111,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0011_1111_1100}
        };    //LH

        '{
            instr : 32'b0100_0001_1101_0110_1010_0110_1000_0011,
            rs1_expected : 5'b01101,
            rs2_expected : 5'b11101,
            rd_expected : 5'b01101,
            op_expected : 7'b0000011,
            funct3_expected : 3'b010,
            funct7_expected : 7'b0100000,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0100_0001_1101}
        };    //LW

        '{
            instr : 32'b1111_1000_0001_0111_1100_0011_1000_0011,
            rs1_expected : 5'b01111,
            rs2_expected : 5'b00001,
            rd_expected : 5'b00111,
            op_expected : 7'b0000011,
            funct3_expected : 3'b100,
            funct7_expected : 7'b1111100,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 12'b1111_1000_0001}
        };    //LBU

        '{
            instr : 32'b1110_0110_1111_0000_0101_1010_1000_0011,
            rs1_expected : 5'b00000,
            rs2_expected : 5'b01111,
            rd_expected : 5'b10101,
            op_expected : 7'b0000011,
            funct3_expected : 3'b101,
            funct7_expected : 7'b1110011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 12'b1110_0110_1111}
        };    //LHU

        '{
            instr : 32'b0111_0100_1101_0000_1000_1110_1110_0111,
            rs1_expected : 5'b00001,
            rs2_expected : 5'b01101,
            rd_expected : 5'b11101,
            op_expected : 7'b1100111,
            funct3_expected : 3'b000,
            funct7_expected : 7'b0111010,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b1,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 12'b0111_0100_1101}
        };    //JALR

        '{
            instr : 32'b1111_0110_0010_1111_0000_1110_0010_0011,
            rs1_expected : 5'b11110,
            rs2_expected : 5'b00010,
            rd_expected : 5'b11100,
            op_expected : 7'b0100011,
            funct3_expected : 3'b000,
            funct7_expected : 7'b1111011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b1,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 7'b1111011, 5'b11100}
        };    //SB

        '{
            instr : 32'b0101_0011_1001_1000_1001_0010_1010_0011,
            rs1_expected : 5'b10001,
            rs2_expected : 5'b11001,
            rd_expected : 5'b00001,
            op_expected : 7'b0100011,
            funct3_expected : 3'b001,
            funct7_expected : 7'b0100011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b1,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 7'b0101001, 5'b00101}
        };    //SH

        '{
            instr : 32'b1110_1000_1010_1000_1010_0000_1010_0011,
            rs1_expected : 5'b10001,
            rs2_expected : 5'b01010,
            rd_expected : 5'b00001,
            op_expected : 7'b0100011,
            funct3_expected : 3'b010,
            funct7_expected : 7'b1110100,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b1,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 7'b1110100, 5'b00001}
        };    //SW

        '{
            instr : 32'b1011_1011_1100_0101_1000_1011_1110_0011,
            rs1_expected : 5'b01011,
            rs2_expected : 5'b11100,
            rd_expected : 5'b10111,
            op_expected : 7'b1100011,
            funct3_expected : 3'b000,
            funct7_expected : 7'b1011101,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b1,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b1}, 1'b1, 6'b011101, 4'b1011, 1'b0}
        };    //BEQ

        '{
            instr : 32'b0100_0001_0000_1110_0001_1011_1110_0011,
            rs1_expected : 5'b11100,
            rs2_expected : 5'b10000,
            rd_expected : 5'b10111,
            op_expected : 7'b1100011,
            funct3_expected : 3'b001,
            funct7_expected : 7'b0100000,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b1,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 1'b1, 6'b100000, 4'b1011, 1'b0}
        };    //BNE

        '{
            instr : 32'b0011_0110_0111_0001_0100_1111_1110_0011,
            rs1_expected : 5'b00010,
            rs2_expected : 5'b0011,
            rd_expected : 5'b11111,
            op_expected : 7'b1100011,
            funct3_expected : 3'b100,
            funct7_expected : 7'b0011011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b1,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 1'b1, 6'b011011, 4'b1111, 1'b0}
        };    //BLT

        '{
            instr : 32'b0001_0110_0111_0100_1101_1011_1110_0011,
            rs1_expected : 5'b00111,
            rs2_expected : 5'b01001,
            rd_expected : 5'b10111,
            op_expected : 7'b1100011,
            funct3_expected : 3'b101,
            funct7_expected : 7'b0001011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b1,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 1'b1, 6'b001011, 4'b1011, 1'b0}
        };    //BGE

        '{
            instr : 32'b0100_0001_0101_0110_1110_1000_0110_0011,
            rs1_expected : 5'b01101,
            rs2_expected : 5'b10101,
            rd_expected : 5'b10000,
            op_expected : 7'b1100011,
            funct3_expected : 3'b110,
            funct7_expected : 7'b0100000,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b1,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 1'b0, 6'b100000, 4'b1000, 1'b0}
        };    //BLTU

        '{
            instr : 32'b0000_0101_0011_1010_0111_1000_0110_0011,
            rs1_expected : 5'b10100,
            rs2_expected : 5'b10011,
            rd_expected : 5'b10000,
            op_expected : 7'b1100011,
            funct3_expected : 3'b111,
            funct7_expected : 7'b0000010,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b1,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {52{1'b0}, 1'b0, 6'b000010, 4'b1000, 1'b0}
        };    //BGEU

        '{
            instr : 32'b0001_1110_1101_1010_1001_1110_0001_0111,
            rs1_expected : 5'b10101,
            rs2_expected : 5'b01101,
            rd_expected : 5'b11100,
            op_expected : 7'b0010111,
            funct3_expected : 3'b001,
            funct7_expected : 7'b0001111,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b1,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {32{1'b0}, 20'b0001_1110_1101_1010_1001, 12'b0}
        };    //AUIPC

        '{
            instr : 32'b0000_0100_1101_0100_0010_1110_0011_0111,
            rs1_expected : 5'b01000,
            rs2_expected : 5'b01101,
            rd_expected : 5'b11100,
            op_expected : 7'b0110111,
            funct3_expected : 3'b010,
            funct7_expected : 7'b0000010,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b1,
            j_type_instr_expected : 1'b0,
            instr_imm_expected : {32{1'b0}, 20'b0000_0100_1101_0100_0010, 12'b0}
        };    //LUI

        '{
            instr : 32'b1111_0110_0000_0000_0100_1100_0110_1111,
            rs1_expected : 5'b00000,
            rs2_expected : 5'b00000,
            rd_expected : 5'b11000,
            op_expected : 7'b1101111,
            funct3_expected : 3'b100,
            funct7_expected : 7'b1111011,
            r_type_instr_expected : 1'b0,
            i_type_instr_expected : 1'b0,
            s_type_instr_expected : 1'b0,
            b_type_instr_expected : 1'b0,
            u_type_instr_expected : 1'b0,
            j_type_instr_expected : 1'b1,
            instr_imm_expected : {44{1'b1}, 8'b0000_0100, 1'b0, 10'b11_1011_0000, 1'b0}
        };    //JAL

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
