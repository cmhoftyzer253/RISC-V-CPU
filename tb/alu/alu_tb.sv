import cpu_consts::*;

`timescale 1ns/1ps

module alu_tb;

    //dut
    alu_if          alu_vif();

    alu dut (
        .opr_a_i        (alu_vif.opr_a_i),
        .opr_b_i        (alu_vif.opr_b_i),
        .alu_valid_i    (alu_vif.alu_valid_i),
        .alu_func_i     (alu_vif.alu_func_i),
        .word_op_i      (alu_vif.word_op_i),
        .flush_i        (alu_vif.flush_i),
        .valid_res_o    (alu_vif.valid_res_o),
        .alu_res_o      (alu_vif.alu_res_o)
    );

    //test  
    int unsigned    seed;
    int unsigned    pass_cnt;
    int unsigned    fail_cnt;

    initial begin
        if (~$value$plusargs("SEED=%d", seed))
            seed = $urandom();
        $display("[TB] seed = %0d (replay with +SEED=%0d)", seed, seed);
        void'($urandom(seed));
    end

    initial begin
        if ($test$plusargs("WAVES")) begin
            $dumpfile("alu_tb.vcd");
            $dumpvars(0, alu_tb);
            $display("[TB] waveform -> alu_tb.vcd");
        end
    end

    //golden model 
    import "DPI-C" function void alu_golden (
        input longint   opr_a_i,
        input longint   opr_b_i,
        input int       alu_valid_i,
        input int       alu_func_i,
        input int       word_op_i,
        input int       flush_i,
        output int      valid_res_o,
        output longint  alu_res_o
    );

    task automatic apply_and_check (
        input string        label,
        input logic [63:0]  a,
        input logic [63:0]  b,
        input alu_op_t      op,
        input logic         word_op,
        input logic         valid,
        input logic         flush
    );

        int         exp_valid;
        longint     exp_res;

        alu_vif.opr_a_i         =   a;
        alu_vif.opr_b_i         =   b;
        alu_vif.alu_func_i      =   op;
        alu_vif.word_op_i       =   word_op;
        alu_vif.alu_valid_i     =   valid;
        alu_vif.flush_i         =   flush;
        #1;

        alu_golden (
            longint'(a), longint'(b), int'(valid), int'(op), int'(word_op), int'(flush),
            exp_valid, exp_res
        );

        if (alu_vif.valid_res_o !== exp_valid[0]) begin
            $display("FAIL %-48s | valid_res_o expected: %0b got: %0b", label, exp_valid[0], alu_vif.valid_res_o);
            fail_cnt++;
            return;
        end

        if (exp_valid[0] & (alu_vif.res_o !== exp_res)) begin
            $display("FAIL %-48s | a=%016h b=%016h op=%-6s word=%0b | expected %016h, got=%016h",
                    label, a, b, op.name(), word_op, exp_res, alu_vif.alu_res_o);
            fail_cnt++;
        end else begin
            pass_cnt++;
        end

    endtask

    localparam int NUM_TESTS = 500;

    task automatic random_tests();
        logic [63:0]    a;
        logic [63:0]    b;
        alu_op_t        op;
        logic           word_op;
        string          label;

        for (int i=0; i<NUM_TESTS; i++) begin
            a           =   {$urandom(), $urandom()};
            b           =   {$urandom(), $urandom()};
            op          =   alu_op_t'($urandom_range(0, 10));
            word_op     =   (op inside {OP_ADD, OP_SUB, OP_SLL, OP_SRL, OP_SRA}) ? $urandom_range(0, 1) : 1'b0;
            label       =   $sformatf("rand[%0d] %-6s word_op=%0b", i, op.name(), word_op);

            apply_and_check(label, a, b, op, word_op);
        end
    endtask

    //corner cases 
    task automatic corner_cases();
        apply_and_check("SLL64 shamt=0",            64'hDEAD_BEEF_CAFE_1234,    64'h00,                     OP_SLL, 1'b0, 1'b1, 1'b0);
        apply_and_check("SLL64 shamt=1",            64'hDEAD_BEEF_CAFE_1234,    64'h01,                     OP_SLL, 1'b0, 1'b1, 1'b0);
        apply_and_check("SLL64 shamt=31",           64'hDEAD_BEEF_CAFE_1234,    64'h1f,                     OP_SLL, 1'b0, 1'b1, 1'b0);
        apply_and_check("SLL64 shamt=32",           64'hDEAD_BEEF_CAFE_1234,    64'h20,                     OP_SLL, 1'b0, 1'b1, 1'b0);
        apply_and_check("SLL64 shamt=63",           64'hDEAD_BEEF_CAFE_1234,    64'h3f,                     OP_SLL, 1'b0, 1'b1, 1'b0);

        apply_and_check("SRL64 shamt=0",            64'hDEAD_BEEF_CAFE_1234,    64'h00,                     OP_SRL, 1'b0, 1'b1, 1'b0);
        apply_and_check("SRL64 shamt=1",            64'hDEAD_BEEF_CAFE_1234,    64'h01,                     OP_SRL, 1'b0, 1'b1, 1'b0);
        apply_and_check("SRL64 shamt=63",           64'hDEAD_BEEF_CAFE_1234,    64'h3f,                     OP_SRL, 1'b0, 1'b1, 1'b0);

        apply_and_check("SRA64 shamt=0",            64'hDEAD_BEEF_CAFE_1234,    64'h00,                     OP_SRA, 1'b0, 1'b1, 1'b0);
        apply_and_check("SRA64 shamt=1",            64'hDEAD_BEEF_CAFE_1234,    64'h01,                     OP_SRA, 1'b0, 1'b1, 1'b0);
        apply_and_check("SRA64 shamt=63",           64'hDEAD_BEEF_CAFE_1234,    64'h3f,                     OP_SRA, 1'b0, 1'b1, 1'b0);

        apply_and_check("SLL32 shamt=0",            64'hDEAD_BEEF_CAFE_1234,    64'h00,                     OP_SLL,  1'b1, 1'b1, 1'b0);
        apply_and_check("SLL32 shamt=1",            64'hDEAD_BEEF_CAFE_1234,    64'h01,                     OP_SLL,  1'b1, 1'b1, 1'b0);
        apply_and_check("SLL32 shamt=31",           64'hDEAD_BEEF_CAFE_1234,    64'h1f,                     OP_SLL,  1'b1, 1'b1, 1'b0);

        apply_and_check("SRL32 shamt=0",            64'hDEAD_BEEF_CAFE_1234,    64'h00,                     OP_SRL,  1'b1, 1'b1, 1'b0);
        apply_and_check("SRL32 shamt=31",           64'hDEAD_BEEF_CAFE_1234,    64'h1f,                     OP_SRL,  1'b1, 1'b1, 1'b0);

        apply_and_check("SRA32 MIN_INT>>31",        64'h0000_0000_8000_0000,    64'h1f,                     OP_SRA,  1'b1, 1'b1, 1'b0);
        apply_and_check("SRA32 pos>>31",            64'h0000_0000_7FFF_FFFF,    64'h1f,                     OP_SRA,  1'b1, 1'b1, 1'b0);

        apply_and_check("ADD64 max+1",              64'hFFFF_FFFF_FFFF_FFFF,    64'h1,                      OP_ADD,  1'b0, 1'b1, 1'b0);
        apply_and_check("ADD32 max+1",              64'h0000_0000_FFFF_FFFF,    64'h1,                      OP_ADD,  1'b1, 1'b1, 1'b0);
        apply_and_check("SUB64 0-1",                64'h0,                      64'h1,                      OP_SUB,  1'b0, 1'b1, 1'b0);
        apply_and_check("SUB32 0-1",                64'h0,                      64'h1,                      OP_SUB,  1'b1, 1'b1, 1'b0);

        apply_and_check("ADDW sign-ext  (bit31=1)", 64'h0000_0000_7FFF_FFFF,    64'h1,                      OP_ADD,  1'b1, 1'b1, 1'b0);
        apply_and_check("ADDW zero-ext  (bit31=0)", 64'h0000_0000_0FFF_FFFF,    64'h1,                      OP_ADD,  1'b1, 1'b1, 1'b0);
        apply_and_check("SUBW negative result",     64'h0000_0000_0000_0000,    64'h0000_0000_0000_0001,    OP_SUB,  1'b1, 1'b1, 1'b0);

        apply_and_check("SLT  -1 < 0",              64'hFFFF_FFFF_FFFF_FFFF,    64'h0,                      OP_SLT,  1'b0, 1'b1, 1'b0);
        apply_and_check("SLT   0 < -1",             64'h0,                      64'hFFFF_FFFF_FFFF_FFFF,    OP_SLT,  1'b0, 1'b1, 1'b0);
        apply_and_check("SLT  MIN<MAX",             64'h8000_0000_0000_0000,    64'h7FFF_FFFF_FFFF_FFFF,    OP_SLT,  1'b0, 1'b1, 1'b0);
        apply_and_check("SLT  MAX<MIN",             64'h7FFF_FFFF_FFFF_FFFF,    64'h8000_0000_0000_0000,    OP_SLT,  1'b0, 1'b1, 1'b0);
        apply_and_check("SLTU MAX_U > 0",           64'hFFFF_FFFF_FFFF_FFFF,    64'h0,                      OP_SLTU, 1'b0, 1'b1, 1'b0);
        apply_and_check("SLTU 0 < MAX_U",           64'h0,                      64'hFFFF_FFFF_FFFF_FFFF,    OP_SLTU, 1'b0, 1'b1, 1'b0);

        apply_and_check("AND all-0s",               64'hDEAD_BEEF_CAFE_1234,    64'h0,                      OP_AND,  1'b0, 1'b1, 1'b0);
        apply_and_check("AND all-1s",               64'hDEAD_BEEF_CAFE_1234,    64'hFFFF_FFFF_FFFF_FFFF,    OP_AND,  1'b0, 1'b1, 1'b0);
        apply_and_check("OR  all-0s",               64'hDEAD_BEEF_CAFE_1234,    64'h0,                      OP_OR,   1'b0, 1'b1, 1'b0);
        apply_and_check("OR  all-1s",               64'hDEAD_BEEF_CAFE_1234,    64'hFFFF_FFFF_FFFF_FFFF,    OP_OR,   1'b0, 1'b1, 1'b0);
        apply_and_check("XOR same",                 64'hDEAD_BEEF_CAFE_1234,    64'hDEAD_BEEF_CAFE_1234,    OP_XOR,  1'b0, 1'b1, 1'b0); 
        apply_and_check("XOR all-1s",               64'hDEAD_BEEF_CAFE_1234,    64'hFFFF_FFFF_FFFF_FFFF,    OP_XOR,  1'b0, 1'b1, 1'b0);

        apply_and_check("Flush test",               64'h1,                      64'h2,                      OP_ADD,  1'b0, 1'b1, 1'b1)

        apply_and_check("No request test",          64'hDEAD_BEEF_CAFE_1234,    64'hBEEF_DEAD_CAFE_1234,    OP_ADD,  1'b0, 1'b0, 1'b0);

    endtask

    initial begin
        alu_vif.opr_a_i         =   64'h0;
        alu_vif.opr_b_i         =   64'h0;
        alu_vif.alu_valid_i     =   1'b0;
        alu_vif.alu_func_i      =   4'b0;
        alu_vif.word_op_i       =   1'b0;
        alu_vif.flush_i         =   1'b0;
        pass_cnt                =   0;
        fail_cnt                =   0;
        #5;

        $display("[TB] ===== Random tests (%0d vectors) =====", NUM_TESTS);
        random_tests();

        $display("[TB] ===== Corner cases =====");
        corner_cases();

        $display("");
        $display("[TB] =========================================");
        $display("[TB] RESULTS  %0d passed  %0d failed   seed=%0d", pass_cnt, fail_cnt, seed);
        $display("[TB] =========================================");

        if (fail_cnt > 0) begin
            $display("[TB] *** FAIL ***");
            $fatal(1, "alu_tb: %0d test(s) FAILED (seed=%0d)", fail_cnt, seed);
        end else begin
            $display("[TB] ***PASS***");
        end

        $finish;
    end

endmodule