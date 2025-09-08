import cpu_consts::*;
import cpu_modules::*;

module multiply (
    input logic clk,
    input logic reset,

    input logic [63:0] opr_a_i,     //multiplicand
    input logic [63:0] opr_b_i,     //multiplier

    input logic         mul_instr_i,
    input logic [3:0]   mul_func_i,
    input logic         word_op_i,

    input logic         flush_i,
    input logic         kill_i,

    output logic [63:0] mul_res_o,
    output logic        valid_res_o,
    output logic        mul_busy_o
);

    //valid signals
    logic v_s1;
    logic v_s2;
    logic v_s3;
    logic v_s4;

    logic v_s1_in;
    logic v_s2_in;
    logic v_s3_in;
    logic v_s4_in;

    assign v_s1_in = mul_instr_i & ~kill_i;
    assign v_s2_in = v_s1 & ~flush_i;
    assign v_s3_in = v_s2 & ~flush_i;
    assign v_s4_in = v_s3 & ~flush_i;

    always_ff @(posedge clk) begin
        if (reset) begin
            v_s1 <= 1'b0;
            v_s2 <= 1'b0;
            v_s3 <= 1'b0;
            v_s4 <= 1'b0;
        end else begin
            v_s1 <= v_s1_in;
            v_s2 <= v_s2_in;
            v_s3 <= v_s3_in;
            v_s4 <= v_s4_in;
        end
    end

    // stage 1 - register inputs & split operands
    logic a_signed_in;
    logic b_signed_in;
    logic negate_res_in;

    logic negate_res_s1;

    logic [63:0] a_correct;
    logic [63:0] b_correct;

    logic [31:0] a_high_in;
    logic [31:0] a_low_in;
    logic [31:0] b_high_in;
    logic [31:0] b_low_in;

    logic [31:0] a_high_s1;
    logic [31:0] a_low_s1;
    logic [31:0] b_high_s1;
    logic [31:0] b_low_s1;

    logic [3:0] mul_func_s1;
    logic       word_op_s1;

    assign a_signed_in      =   (mul_func_i == OP_MUL | mul_func_i == OP_MULH | mul_func_i == OP_MULHSU);    
    assign b_signed_in      =   (mul_func_i == OP_MUL | mul_func_i == OP_MULH);
    assign negate_res_in    =   (~word_op_i & ((opr_a_i[63] & a_signed_in) ^ (opr_b_i[63] & b_signed_in))) |
                                ( word_op_i & (opr_a_i[31] ^ opr_b_i[31]));                                


    assign a_correct[63:0]  =   ({64{a_signed_in & opr_a_i[63] & ~word_op_i}}     & twos_comp_64(opr_a_i[63:0])) |
                                ({64{(~a_signed_in | ~opr_a_i[63]) & ~word_op_i}} & opr_a_i[63:0]) |
                                ({64{word_op_i &  opr_a_i[31]}}                   & {32'h0, twos_comp_32(opr_a_i[31:0])}) |
                                ({64{word_op_i & ~opr_a_i[31]}}                   & {32'h0, opr_a_i[31:0]});

    assign b_correct[63:0]  =   ({64{b_signed_in & opr_b_i[63] & ~word_op_i}}     & twos_comp_64(opr_b_i[63:0])) |
                                ({64{(~b_signed_in | ~opr_b_i[63]) & ~word_op_i}} & opr_b_i[63:0]) |
                                ({64{word_op_i &  opr_b_i[31]}}                   & {32'h0, twos_comp_32(opr_b_i[31:0])}) |
                                ({64{word_op_i & ~opr_b_i[31]}}                   & {32'h0, opr_b_i[31:0]});

    assign a_high_in[31:0]  =   a_correct[63:32];
    assign b_high_in[31:0]  =   b_correct[63:32];

    assign a_low_in[31:0]   =   a_correct[31:0];
    assign b_low_in[31:0]   =   b_correct[31:0];

    always_ff @(posedge clk) begin
        if (reset) begin
            a_high_s1       <= 32'h0;
            a_low_s1        <= 32'h0;
            b_high_s1       <= 32'h0;
            b_low_s1        <= 32'h0;

            negate_res_s1   <= 1'b0;

            mul_func_s1     <= 4'b0;
            word_op_s1      <= 1'b0;
        end else begin
            a_high_s1       <= a_high_in;
            b_high_s1       <= b_high_in;
            a_low_s1        <= a_low_in;
            b_low_s1        <= b_low_in;

            negate_res_s1   <= negate_res_in;

            mul_func_s1     <= mul_func_i;
            word_op_s1      <= word_op_i;
        end
    end

    // stage 2 - calculate partial products
    logic [63:0] p0_in;
    logic [63:0] p1_in;
    logic [63:0] p2_in;
    logic [63:0] p3_in;

    logic [63:0] p0_s2;
    logic [63:0] p1_s2;
    logic [63:0] p2_s2;
    logic [63:0] p3_s2;

    logic       negate_res_s2;

    logic [3:0] mul_func_s2;
    logic       word_op_s2;

    assign p0_in[63:0] = a_low_s1[31:0]  * b_low_s1[31:0];
    assign p1_in[63:0] = a_low_s1[31:0]  * b_high_s1[31:0];
    assign p2_in[63:0] = a_high_s1[31:0] * b_low_s1[31:0];
    assign p3_in[63:0] = a_high_s1[31:0] * b_high_s1[31:0];

    always_ff @(posedge clk) begin
        if (reset) begin
            p0_s2 <= 64'h0;
            p1_s2 <= 64'h0;
            p2_s2 <= 64'h0;
            p3_s2 <= 64'h0;

            negate_res_s2   <= 1'b0;

            mul_func_s2     <= 4'b0;
            word_op_s2      <= 1'b0;
        end else begin
            p0_s2 <= p0_in;
            p1_s2 <= p1_in;
            p2_s2 <= p2_in;
            p3_s2 <= p3_in;

            negate_res_s2   <= negate_res_s1;

            mul_func_s2     <= mul_func_s1;
            word_op_s2      <= word_op_s1;
        end
    end

    // stage 3 - combine lower 96 bits (((p1 + p2) << 32) + p0)
    logic [64:0]    cross_terms;
    logic [127:0]   part_sum_in;

    logic [127:0]   part_sum_s3;
    logic [63:0]    p3_s3;

    logic       negate_res_s3;

    logic [3:0] mul_func_s3;
    logic       word_op_s3;

    assign cross_terms[64:0]        = {1'b0, p1_s2[63:0]} + {1'b0, p2_s2[63:0]};

    //if MULW instruction store result in lower 64 bits of part_sum_in
    assign  part_sum_in[127:0]      =   ({128{word_op_s2}} & {64'h0, p0_s2[63:0]}) |
                                        ({128{~word_op_s2}} & ({64'h0, p0_s2[63:0]} + ({63'h0, cross_terms[64:0]} << 32)));
                                                

    always_ff @(posedge clk) begin
        if (reset) begin
            part_sum_s3     <= 128'h0;
            p3_s3           <= 64'h0;

            negate_res_s3   <= 1'b0;

            mul_func_s3     <= 4'b0;
            word_op_s3      <= 1'b0;
        end else begin
            part_sum_s3     <= part_sum_in;
            p3_s3           <= p3_s2;

            negate_res_s3   <= negate_res_s2;

            mul_func_s3     <= mul_func_s2;
            word_op_s3      <= word_op_s2;
        end
    end

    // stage 4 - add p3 to lower 96 bits
    logic [127:0]   full_sum_in;
    logic [127:0]   full_sum_s4;
    
    logic       negate_res_s4;

    logic [3:0] mul_func_s4;
    logic       word_op_s4;     

    //if MULW instruction keep part_sum_s3 result
    assign full_sum_in[127:0]   =   ({128{word_op_s3}}  & part_sum_s3[127:0]) | 
                                    ({128{~word_op_s3}} & (part_sum_s3[127:0] + {p3_s3[63:0], 64'h0})); 

    always_ff @(posedge clk) begin
        if (reset) begin
            full_sum_s4     <= 128'h0;

            negate_res_s4   <= 1'b0;

            mul_func_s4     <= 4'b0;
            word_op_s4      <= 1'b0;
        end else begin
            full_sum_s4     <= full_sum_in;

            negate_res_s4   <= negate_res_s3;

            mul_func_s4    <= mul_func_s3;
            word_op_s4      <= word_op_s3;
        end
    end

    // stage 5 - output
    logic [127:0]   final_sum;
    logic [63:0]    mul_res;
    logic           mul_busy;

    assign mul_busy             =   v_s1 | v_s2 | v_s3 | v_s4;

    assign final_sum[127:0]     =   ({128{ negate_res_s4}} & twos_comp_128(full_sum_s4[127:0])) | 
                                    ({128{~negate_res_s4}} & full_sum_s4[127:0]);
    
    always_comb begin
        case(mul_func_s4)
            OP_MUL      :   mul_res =   ({64{ word_op_s4}} & {{32{final_sum[31]}}, final_sum[31:0]}) |
                                        ({64{~word_op_s4}} & final_sum[63:0]);
            OP_MULH,
            OP_MULHU,
            OP_MULHSU   :   mul_res =   final_sum[127:64];
            default     :   mul_res =   64'h0;
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            mul_res_o       <= 64'h0;
            valid_res_o     <= 1'b0;
            mul_busy_o      <= 1'b0;
        end else begin
            mul_res_o       <= mul_res;
            valid_res_o     <= v_s4;
            mul_busy_o      <= mul_busy;
        end
    end
endmodule