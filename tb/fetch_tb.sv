`timescale 1ns/1ps
import cpu_consts::*;

module tb_fetch;

    logic clk;
    logic reset;
    logic [63:0] pc_i;

    logic           instr_mem_req_o;
    logic [63:0]    instr_mem_addr_o;

    logic [31:0]    fetch_instr_i;
    logic [31:0]    fetch_instr_o;

    //DUT
    fetch dut(
        .clk                (clk),
        .reset              (reset),
        .pc_i               (pc_i),
        .instr_mem_req_o    (instr_mem_req_o),
        .instr_mem_addr_o   (instr_mem_addr_o),
        .fetch_instr_i      (fetch_instr_i),
        .fetch_instr_o      (fetch_instr_o)
    );

    typedef struct packed {
        logic           reset;
        logic [63:0]    pc;
        logic [31:0]    fetch_instr;
        logic           instr_mem_req_expected;
        logic           instr_mem_addr_expected;
        logic [31:0]    fetch_instr_expected;
    } test_vect_t;

    //testcases - TODO
    test_vect_t test_vect [:]= '{
        '{};
    };

    typedef struct packed {
        logic           instr_mem_req_got;
        logic [63:0]    instr_mem_addr_got;
        logic [31:0]    fetch_instr_got;
    } got_vect_t;

    got_vect_t got_vect;

    typedef struct packed {
        logic           instr_mem_req_expected;
        logic [63:0]    instr_mem_addr_expected;
        logic [31:0]    fetch_instr_expected;
    } exp_vect_t;

    exp_vect_t exp_vect;

    //generate clock signal
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("-------- Starting ALU Tests --------");
        @(posedge clk);

        foreach(test_vect[i]) begin
            //drive inputs
            reset = test_vect[i].reset;
            pc_i = test_vect[i].pc;
            fetch_instr_i = test_vect[i].fetch_instr;

            //update expected values
            exp_vect = '{
                test_vect[i].instr_mem_req_expected,
                test_vect[i].instr_mem_addr_expected,
                test_vect[i].fetch_instr_expected
            };

            //wait 1CC for outputs to propogate
            @(posedge clk);

            //capture results
            got_vect = '{
                instr_mem_req_o,
                instr_mem_addr_o,
                fetch_instr_o
            };

            if(got_vect !== exp_vect) begin
                $error("FAILED TESTCASE [%0d]:\n    got:%p\n,   expected:%p",
                        i, got_vect, exp_vect);
            end else begin
                $display("PASSED TESTCASE [%0d]", i);
            end

        end
        $display("-------- Fetch Tests Finished --------");
    end

endmodule