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

    test_vect_t test_vect [0:21] = '{  
        //---------------------- Test rf_wr_data_src_i ----------------------
        '{
            alu_res : 64'hFFFF_0000_0000_0000,
            data_mem_rd : 64'h0000_FFFF_0000_0000,
            instr_imm : 64'h0000_0000_FFFF_0000,
            pc_val : 64'h0000_0000_0000_FFFF,
            rf_wr_data_src : 2'b00,
            data_byte_en : DOUBLE_WORD,
            data_zero_extnd : 1'bX,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'hFFFF_0000_0000_0000
        },    // data from ALU

        '{
            alu_res : 64'hFFFF_0000_0000_0000,
            data_mem_rd : 64'h0000_FFFF_0000_0000,
            instr_imm : 64'h0000_0000_FFFF_0000,
            pc_val : 64'h0000_0000_0000_FFFF,
            rf_wr_data_src : 2'b01,
            data_byte_en : DOUBLE_WORD,
            data_zero_extnd : 1'bX,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_FFFF_0000_0000
        },    // data from memory

        '{
            alu_res : 64'hFFFF_0000_0000_0000,
            data_mem_rd : 64'h0000_FFFF_0000_0000,
            instr_imm : 64'h0000_0000_FFFF_0000,
            pc_val : 64'h0000_0000_0000_FFFF,
            rf_wr_data_src : 2'b10,
            data_byte_en : DOUBLE_WORD,
            data_zero_extnd : 1'bX,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_FFFF_0000
        },    // data from immediate

        '{
            alu_res : 64'hFFFF_0000_0000_0000,
            data_mem_rd : 64'h0000_FFFF_0000_0000,
            instr_imm : 64'h0000_0000_FFFF_0000,
            pc_val : 64'h0000_0000_0000_FFFF,
            rf_wr_data_src : 2'b11,
            data_byte_en : DOUBLE_WORD,
            data_zero_extnd : 1'bX,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_0000_FFFF
        },    // data from PC

        //---------------------- Test sign/zero extension ----------------------
        '{
            alu_res : 64'h0000_0000_0000_009C,
            data_mem_rd : 64'hX,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b00,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'hFFFF_FFFF_FFFF_FF9C
        },    // sign extension, negative byte

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h0000_0000_0000_000F,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_0000_000F
        },    // sign extension, positive byte

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'hX,
            instr_imm : 64'h0000_0000_0000_00F0,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b10,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_0000_00F0
        },    // zero extension, leading zero

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'hX,
            instr_imm : 64'hX,
            pc_val : 64'h0000_0000_0000_004E,
            rf_wr_data_src : 2'b11,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_0000_004E
        },    // zero extension, leading one

        //---------------------- Test Byte shifting ----------------------
        '{
            alu_res : 64'hX,
            data_mem_rd : 64'hFBD2_67A6_10FF_4483, 
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b0,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_0000_0083
        },    // byte [7:0]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h33F0_D6DE_5453_AB57,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b001,
            rf_wr_data_expected : 64'hFFFF_FFFF_FFFF_FFAB
        },    // byte [15:8]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h9082_3E67_EB4D_08CD,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b0,
            data_mem_row_idx : 3'b010,
            rf_wr_data_expected : 64'h0000_0000_0000_004D
        },    // byte [23:16]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h7699_5CE5_DE59_45AC,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b011,
            rf_wr_data_expected : 64'hFFFF_FFFF_FFFF_FFDE
        },    // byte [31:24]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'hB7FA_1809_0b4E_3E61,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b0,
            data_mem_row_idx : 3'b100,
            rf_wr_data_expected : 64'h0000_0000_0000_0009
        },    // byte [39:32]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'hD065_3348_5235_983D,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b101,
            rf_wr_data_expected : 64'h0000_0000_0000_0033
        },    // byte [47:40]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'hC15C_7107_8232_B749,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b0,
            data_mem_row_idx : 3'b110,
            rf_wr_data_expected : 64'h0000_0000_0000_005C
        },    // byte [55:48]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h28FE_320D_FB19_CC8A,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : BYTE,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b111,
            rf_wr_data_expected : 64'h0000_0000_0000_0028
        },    // byte [63:56]

        //---------------------- Test Half Word shifting ----------------------
        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h5925_56B0_1DAC_E439,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : HALF_WORD,
            data_zero_extnd : 1'b0,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_0000_E439
        },    // half word [15:0]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h5877_C6D4_3AE2_88DF,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : HALF_WORD,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b010,
            rf_wr_data_expected : 64'h0000_0000_0000_3AE2
        },    // half word [31:16]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'hA8E9_102D_8E9B_5727,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : HALF_WORD,
            data_zero_extnd : 1'b0,
            data_mem_row_idx : 3'b100,
            rf_wr_data_expected : 64'h0000_0000_0000_102D
        },    // half word [47:32]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h896C_8048_EF9A_98F9,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : HALF_WORD,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b110,
            rf_wr_data_expected : 64'hFFFF_FFFF_FFFF_896C
        },    // half word [63:48]

        //---------------------- Test Word shifting ----------------------
        '{
           alu_res : 64'hX,
            data_mem_rd : 64'h059E_3F87_4026_4744,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : WORD,
            data_zero_extnd : 1'b0,
            data_mem_row_idx : 3'b000,
            rf_wr_data_expected : 64'h0000_0000_4026_4744
        },    // word [31:0]

        '{
            alu_res : 64'hX,
            data_mem_rd : 64'h37F3_A8CE_10DF_57BA,
            instr_imm : 64'hX,
            pc_val : 64'hX,
            rf_wr_data_src : 2'b01,
            data_byte_en : WORD,
            data_zero_extnd : 1'b1,
            data_mem_row_idx : 3'b100,
            rf_wr_data_expected : 64'h0000_0000_37F3_A8CE
        },    // word [63:32]
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