class alu_coverage extends uvm_subscriber #(alu_command_transaction);
    `uvm_component_utils(alu_coverage)

    logic [63:0]    opr_a_i;
    logic [63:0]    opr_b_i;
    logic           alu_valid_i;
    alu_op_t        alu_func_i;
    logic           word_op_i;
    logic           flush_i;

    covergroup basic_cov;

        all_alu_funcs : coverpoint alu_func_i {
            bins ops[] = {OP_ADD, OP_SUB, OP_SLL, OP_SRL, OP_SRA, OP_OR, OP_AND, OP_XOR, OP_SLTU, OP_SLT, OP_CSRRW};
        }

        word_op : coverpoint word_op_i {
            bins double_word = {1'b0};
            bins single_word = {1'b1};
        }

        alu_valid : coverpoint alu_valid_i {
            bins invalid_op = {1'b0};
            bins valid_op = {1'b1};
        }

        flush : coverpoint flush_i {
            bins flush_inactive = {1'b0};
            bins flush_active = {1'b1};
        }

    endgroup

    covergroup boundary_cov;
        alu_funcs : coverpoint alu_func_i {
            bins add = {OP_ADD};
            bins sub = {OP_SUB};
            bins shift_ops[] = {OP_SLL, OP_SRL, OP_SRA};
            bins logic_ops[] = {OP_OR, OP_AND, OP_XOR};
            bins slt_ops[] = {OP_SLTU, OP_SLT};
        }

        opr_a : coverpoint opr_a_i {
            bins zero = {64'h0};
            bins one = {64'h1};
            bins max_pos_32b_s = {64'h0000_0000_7FFF_FFFF};
            bins min_neg_32b_s = {64'h0000_0000_8000_0000};
            bins max_pos_32b_us = {64'h0000_0000_FFFF_FFFF};
            bins max_pos_64b_s = {64'h7FFF_FFFF_FFFF_FFFF};
            bins min_neg_64b_s = {64'h8000_0000_0000_0000};
            bins all_ones = {64'hFFFF_FFFF_FFFF_FFFF};

            bins rest = default;
        }

        opr_b : coverpoint opr_b_i {
            bins zero = {64'h0};
            bins one = {64'h1};
            bins max_pos_32b_s = {64'h0000_0000_7FFF_FFFF};
            bins min_neg_32b_s = {64'h0000_0000_8000_0000};
            bins max_pos_32b_us = {64'h0000_0000_FFFF_FFFF};
            bins max_pos_64b_s = {64'h7FFF_FFFF_FFFF_FFFF};
            bins min_neg_64b_s = {64'h8000_0000_0000_0000};
            bins all_ones = {64'hFFFF_FFFF_FFFF_FFFF};

            wildcard bins shift_31 = {{59'b?, 5'b11111}};
            wildcard bins shift_32 = {{58'b?, 6'b100000}}; 
            wildcard bins shift_63 = {{58'b?, 6'b111111}};
            bins shift_mask = {[64'h40 : 64'hFFFF_FFFF_FFFF_FFFF]};

            bins rest = default;
        }

        word_op : coverpoint word_op_i {
            bins double_word = {1'b0};
            bins single_word = {1'b1};
        }

        arithmetic_funcs : cross alu_funcs, opr_a, opr_b, word_op {
            bins add_32b_overflow = binsof(alu_funcs.add) && binsof(opr_a.max_pos_32b_us) && binsof(opr_b.one) && binsof(word_op.single_word);
            bins add_32b_sign_overflow = binsof(alu_funcs.add) && binsof(opr_a.max_pos_32b_s) && binsof(opr_b.one) && binsof(word_op.single_word);

            bins add_64b_overflow = binsof(alu_funcs.add) && binsof(opr_a.all_ones) && binsof(opr_b.one) && binsof(word_op.double_word);
            bins add_64b_sign_overflow = binsof(alu_funcs.add) && binsof(opr_a.max_pos_64b_s) && binsof(opr_b.one) && binsof(word_op.double_word);

            bins sub_pos_to_neg = binsof(alu_funcs.sub) && binsof(opr_a.zero) && binsof(opr_b.one);

            bins sub_neg_to_pos_32b = binsof(alu_funcs.sub) && binsof(opr_a.min_neg_32b_s) && binsof(opr_b.one) && binsof(word_op.single_word);
            bins sub_pos_to_neg_32b = binsof(alu_funcs.sub) && binsof(opr_a.zero) && binsof(opr_b.max_pos_32b_s) && binsof(word_op.single_word);

            bins sub_neg_to_pos_64b = binsof(alu_funcs.sub) && binsof(opr_a.min_neg_64b_s) && binsof(opr_b.one) && binsof(word_op.double_word);
            bins sub_pos_to_neg_64b = binsof(alu_funcs.sub) && binsof(opr_a.zero) && binsof(opr_b.max_pos_64b_s) && binsof(word_op.double_word);
        }

        shift_funcs : cross alu_funcs, opr_a, opr_b, word_op {
            bins shift_0 = binsof(alu_funcs.shift_ops) && binsof(opr_b.zero);

            bins word_shift_31 = binsof(alu_funcs.shift_ops) && binsof(opr_b.shift_31) && binsof(word_op.single_word);
            bins word_shift_32 = binsof(alu_funcs.shift_ops) && binsof(opr_b.shift_32) && binsof(word_op.single_word);
            
            bins double_word_shift_32 = binsof(alu_funcs.shift_ops) && binsof(opr_b.shift_32) && binsof(word_op.double_word);
            bins double_word_shift_63 = binsof(alu_funcs.shift_ops) && binsof(opr_b.shift_63) && binsof(word_op.double_word);
            bins double_word_shift_mask = binsof(alu_funcs.shift_ops) && binsof(opr_b.shift_mask) && binsof(word_op.double_word);

            bins word_sra_min_neg_32 = binsof(alu_funcs) intersect {OP_SRA} && binsof(opr_a.min_neg_32b_s) && binsof(word_op.single_word);
            bins double_word_sra_all_ones = binsof(alu_funcs) intersect {OP_SRA} && binsof(opr_a.all_ones) && binsof(word_op.double_word);
            bins double_word_sra_min_neg_64 = binsof(alu_funcs) intersect {OP_SRA} && binsof(opr_a.min_neg_64b_s) && binsof(word_op.double_word);
        }

        logic_funcs : cross alu_funcs, opr_a, opr_b {
            bins logic_zero_a = binsof(alu_funcs.logic_ops) && binsof(opr_a.zero);
            bins logic_zero_b = binsof(alu_funcs.logic_ops) && binsof(opr_b.zero);
            bins logic_ones_a = binsof(alu_funcs.logic_ops) && binsof(opr_a.all_ones);
            bins logic_ones_b = binsof(alu_funcs.logic_ops) && binsof(opr_b.all_ones);
        }

        slt_funcs : cross alu_funcs, opr_a, opr_b {
            bins slt_equal = binsof(alu_funcs.slt_ops) && binsof(opr_a.all_ones) && binsof(opr_b.all_ones);

            bins slt_max_pos_min_neg = binsof(alu_funcs.slt_ops) intersect {OP_SLT} && binsof(opr_a.max_pos_64b_s) && binsof(opr_b.min_neg_64b_s);
            bins slt_min_neg_max_pos = binsof(alu_funcs.slt_ops) intersect {OP_SLT} && binsof(opr_a.min_neg_64b_s) && binsof(opr_b.max_pos_64b_s);

            bins sltu_max_min = binsof(alu_funcs.slt_ops) intersect {OP_SLTU} && binsof(opr_a.zero) && binsof(opr_b.all_ones);
            bins sltu_min_max = binsof(alu_funcs.slt_ops) intersect {OP_SLTU} && binsof(opr_a.all_ones) && binsof(opr_b.zero);
        }

    endgroup

    covergroup control_cov;
        all_alu_funcs : coverpoint alu_func_i {
            bins ops[] = {OP_ADD, OP_SUB, OP_SLL, OP_SRL, OP_SRA, OP_OR, OP_AND, OP_XOR, OP_SLTU, OP_SLT, OP_CSRRW};
        }

        alu_valid : coverpoint alu_valid_i {
            bins invalid_op = {1'b0};
            bins valid_op = {1'b1};
        }

        alu_flush : coverpoint flush_i {
            bins flush_inactive = {1'b0};
            bins flush_active = {1'b1};
        }

        control_cross : cross all_alu_funcs, alu_valid, alu_flush;

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        basic_cov = new();
        boundary_cov = new();
        control_cov = new();
    endfunction : new

    function void write(alu_command_transaction t);
        opr_a_i         =   t.opr_a_i;
        opr_b_i         =   t.opr_b_i;
        alu_valid_i     =   t.alu_valid_i;
        alu_func_i      =   t.alu_func_i;
        word_op_i       =   t.word_op_i;
        flush_i         =   t.flush_i;

        basic_cov.sample();
        boundary_cov.sample();
        control_cov.sample();
    endfunction : write

endclass : alu_coverage