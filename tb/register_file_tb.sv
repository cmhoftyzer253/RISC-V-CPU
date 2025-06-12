`timescale 1ns/1ps
import cpu_consts::*;

module tb_register_file;

    logic        clk;
    logic        reset;
    logic [4:0]  rs1_addr_i;
    logic [4:0]  rs2_addr_i;
    logic [63:0] rs1_data_o;
    logic [63:0] rs2_data_o;
    logic [4:0]  rd_addr_i;
    logic        wr_en_i;
    logic [63:0] wr_data_i;

    register_file dut(
        .clk        (clk),
        .reset      (reset),
        .rs1_addr_i (rs1_addr_i),
        .rs2_addr_i (rs2_addr_i),
        .rs1_data_o (rs1_data_o),
        .rs2_data_o (rs2_data_o),
        .rd_addr_i  (rd_addr_i),
        .wr_en_i    (wr_en_i),
        .wr_data_i  (wr_data_i)
    );

    typedef struct packed {
        logic        reset;
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [4:0]  rd_addr;
        logic        wr_en;
        logic        wr_data;
        logic [63:0] rs1_data_expected;
        logic [63:0] rs2_data_expected;
    } test_vect_t;

    //testcases - TODO
    test_vect_t test_vect = '{
        '{},
        '{}
    };

    typedef struct packed {
        logic [63:0] rs1_data_got;
        logic [63:0] rs2_data_got;
    } got_vect_t;

    got_vect_t got_vect;

    typedef struct packed {
        logic [63:0] rs1_data_expected;
        logic [63:0] rs2_data_expected;
    } exp_vect_t;

    exp_vect_t exp_vect;

    //generate clock signal
    initial begin
         clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("-------- Starting Register File Tests --------");
        @(posedge clk);

        foreach(test_vect[i]) begin
            //drive inputs
            reset       = test_vect[i].reset;
            rs1_addr_i  = test_vect[i].rs1_addr,
            rs2_addr_i  = test_vect[i].rs2_addr,
            rd_addr_i   = test_vect[i].rd_addr,
            wr_en_i     = test_vect[i].wr_en,
            wr_data_i   = test_vect[i].wr_data

            //update expected values
            exp_vect = '{
                test_vect[i].rs1_data_expected,
                test_vect[i].rs2_data_expected
            };

            @(posedge clk);
            #1ns;   //TODO - TBD

            got_vect = '{
                rs1_data_o,
                rs2_data_o
            };


            if(got_vect !== exp_vect) begin
                $error("FAILED TESTCASE [%0d]:\n    got: %p\n   expected: %p\n",
                        i, got_vect, exp_vect);
            end else begin
                $display("PASSED TESTCASE [%0d]", i);
            end

        end

        $display("-------- Register File Tests Finished --------");
    end
    
endmodule