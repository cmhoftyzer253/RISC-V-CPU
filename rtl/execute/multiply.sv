import cpu_consts::*;

module multiply (
    input logic clk,
    input logic reset,

    input logic [63:0] opr_a_i,     //multiplicand
    input logic [63:0] opr_b_i,     //multiplier

    input logic         mult_instr_i;
    input logic [2:0]   mult_func_i,
    input logic [4:0]   rd_addr_i,
    input logic         word_op_i,

    input logic         stall_i,
    input logic         kill_i,

    output logic [63:0] mult_res_o,
    output logic        valid_res_o,
    output logic [4:0]  rd_addr_o,
    output logic        rd_wr_en_o
);

    //TODO - add stall/kill logic
    //TODO - add MULW instruction

    // stage 1 - register inputs & split operands
    logic nxt_a_signed;
    logic nxt_b_signed;
    logic nxt_negate_res;
    logic nxt_mulw_negate;

    logic a_signed_s1;
    logic b_signed_s1;
    logic negate_res_s1;
    logic mulw_negate_s1;

    logic [31:0] nxt_a_high;
    logic [31:0] nxt_a_low;
    logic [31:0] nxt_b_high;
    logic [31:0] nxt_b_low;

    logic [31:0] a_high_s1;
    logic [31:0] a_low_s1;
    logic [31:0] b_high_s1;
    logic [31:0] b_low_s1;

    logic [2:0] mult_func_s1;
    logic       mult_instr_s1;
    logic [4:0] rd_addr_s1;
    logic       word_op_s1;

    assign nxt_a_signed     = (mult_func_i == MUL || mult_func_i == MULH || mult_func_i == MULHSU);
    assign nxt_b_signed     = (mult_func_i == MUL || mult_func_i == MULH);
    assign nxt_negate_res   = (opr_a_i[63] && nxt_a_signed) ^ (opr_b_i[63] && nxt_b_signed);
    assign nxt_mulw_negate  = (opr_a_i[31] ^ opr_b_i[31]);

    assign nxt_a_high   = get_magnitude(opr_a_i[63:32], nxt_a_signed, opr_a_i[63]);
    assign nxt_b_high   = get_magnitude(opr_b_i[63:32], nxt_b_signed, opr_b_i[63]);

    assign nxt_a_low    = (word_op_i) ?   get_magnitude(opr_a_i[31:0], 1'b1, opr_a_i[31]) : 
                                                    get_magnitude(opr_a_i[31:0], nxt_a_signed, opr_a_i[63]);

    assign nxt_b_low    = (word_op_i) ?   get_magnitude(opr_b_i[31:0], 1'b1, opr_b_i[31]) : 
                                                    get_magnitude(opr_b_i[31:0], nxt_b_signed, opr_b_i[63]);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            a_high_s1       <= 32'h0;
            a_low_s1        <= 32'h0;
            b_high_s1       <= 32'h0;
            b_low_s1        <= 32'h0;

            a_signed_s1     <= 1'b0;
            b_signed_s1     <= 1'b0;
            negate_res_s1   <= 1'b0;
            mulw_negate_s1  <= 1'b0;

            mult_func_s1    <= 3'b0;
            mult_instr_s1   <= 1'b0;
            rd_addr_s1      <= 5'b0;
            word_op_s1      <= 1'b0;
        end else begin
            a_signed_s1     <= nxt_a_signed;
            b_signed_s1     <= nxt_b_signed;
            negate_res_s1   <= nxt_negate_res;
            mulw_negate_s1  <= nxt_mulw_negate;

            a_high_s1   <= nxt_a_high;
            a_low_s1    <= nxt_a_low;
            b_high_s1   <= nxt_b_high;
            b_low_s1    <= nxt_b_low;

            mult_func_s1    <= mult_func_i;
            mult_instr_s1   <= mult_instr_i;
            rd_addr_s1      <= rd_addr_i;
            word_op_s1      <= word_op_i;
        end
    end

    // stage 2 - calculate partial products
    logic [63:0] nxt_p0;
    logic [63:0] nxt_p1;
    logic [63:0] nxt_p2;
    logic [63:0] nxt_p3;

    logic [63:0] p0_s2;
    logic [63:0] p1_s2;
    logic [63:0] p2_s2;
    logic [63:0] p3_s2;

    logic       negate_res_s2;
    logic       mulw_negate_s2;

    logic [2:0] mult_func_s2;
    logic       mult_instr_s2;
    logic [4:0] rd_addr_s2;
    logic       word_op_s2;

    assign nxt_p0 = a_low_s1 * b_low_s1;
    assign nxt_p1 = a_low_s1 * b_high_s1;
    assign nxt_p2 = a_high_s1 * b_low_s1;
    assign nxt_p3 = a_high_s1 * b_high_s1;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            p0_s2 <= 64'h0;
            p1_s2 <= 64'h0;
            p2_s2 <= 64'h0;
            p3_s2 <= 64'h0;

            negate_res_s2   <= 1'b0;
            mulw_negate_s2  <= 1'b0;

            mult_func_s2    <= 3'b0;
            mult_instr_s2   <= 1'b0;
            rd_addr_s2      <= 5'b0;
            word_op_s2      <= 1'b0;
        end else begin
            p0_s2 <= nxt_p0;
            p1_s2 <= nxt_p1;
            p2_s2 <= nxt_p2;
            p3_s2 <= nxt_p3;

            negate_res_s2   <= negate_res_s1;
            mulw_negate_s2  <= mulw_negate_s1;

            mult_func_s2    <= mult_func_s1;
            mult_instr_s2   <= mult_instr_s1;
            rd_addr_s2      <= rd_addr_s1;
            word_op_s2      <= word_op_s1;
        end
    end

    // stage 3 - combine lower 96 bits (((p1 + p2) << 32) + p0)
    logic [64:0]    cross_terms;
    logic [127:0]   nxt_part_sum;

    logic [127:0]   part_sum_s3;

    logic       negate_res_s3;
    logic       mulw_negate_s3;

    logic [2:0] mult_func_s3;
    logic       mult_instr_s3;
    logic [4:0] rd_addr_s3;
    logic       word_op_s3;

    assign cross_terms  = p1_s2 + p2_s2;

    //if MULW instruction store result in nxt_part sum
    assign nxt_part_sum     = (word_op_s2) ?  p0_s2 : 
                                                        {{64{1'b0}}, p0_s2} + ({{63{1'b0}}, cross_terms} << 32);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            part_sum_s3     <= 64'h0;

            negate_res_s3   <= 1'b0;
            mulw_negate_s3  <= 1'b0;

            mult_func_s3    <= 3'b0;
            mult_instr_s3   <= 1'b0;
            rd_addr_s3      <= 5'b0;
            word_op_s3      <= 1'b0;
        end else begin
            part_sum_s3     <= nxt_part_sum;

            negate_res_s3   <= negate_res_s2;
            mulw_negate_s3  <= mulw_negate_s2;

            mult_func_s3    <= mult_func_s2;
            mult_instr_s3   <= mult_instr_s2;
            rd_addr_s3      <= rd_addr_s2;
            word_op_s3      <= word_op_s2;
        end
    end

    // stage 4 - add p3 to lower 96 bits
    logic [127:0]   nxt_full_sum;

    logic [127:0]   full_sum_s4;
    
    logic       negate_res_s4;
    logic       mulw_negate_s4;

    logic [2:0] mult_func_s4;
    logic       mult_instr_s4;
    logic [4:0] rd_addr_s4;
    logic       word_op_s4;     

    //if MULW instruction store in bottom 64 bits of nxt_full_sum - sign extend
    assign nxt_full_sum = (word_op_s3) ?  {{64{part_sum_s3[63]}}, part_sum_s3} :
                                                    part_sum_s3 + ({{64{1'b0}}, p3_s2} << 64);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            full_sum_s4     <= 128'h0;

            negate_res_s4   <= 1'b0;

            mult_func_s4    <= 3'b0;
            mult_instr_s4   <= 1'b0;
            rd_addr_s4      <= 5'b0;
            word_op_s4      <= 1'b0;
        end else begin
            full_sum_s4     <= nxt_full_sum;

            negate_res_s4   <= negate_res_s3;
            mulw_negate_s4  <= mulw_negate_s3;

            mult_func_s4    <= mult_func_s3;
            mult_instr_s4   <= mult_instr_s3;
            rd_addr_s4      <= rd_addr_s3;
            word_op_s4      <= word_op_s3;
        end
    end

    // stage 5 - output
    logic [127:0]   final_sum;
    logic [63:0]    mult_res;
    logic [63:0]    mult_res_o;

    assign final_sum = (negate_res_s4 || mulw_negate_s4) ? -full_sum_s4 : full_sum_s4;
    
    always_comb begin
        case(mult_func_s4)
            MUL     : mult_res = (word_op_s4) ? {{32{final_sum[31]}}, final_sum[31:0]} : 
                                                final_sum[63:0];
            MULH,
            MULHU,
            MULHSU  : mult_res = final_sum[127:64];
            default : mult_res = 64'h0;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mult_res_o      <= 64'h0;
            rd_addr_o       <= 5'b0;
            rd_wr_en_o      <= 1'b0;
            valid_res_o     <= 1'b0;
        end else begin
            mult_res_o  <= mult_res;
            rd_addr_o   <= rd_addr_s4;
            rd_wr_en_o  <= mult_instr_s4;
            valid_res_o <= mult_instr_s4; 
        end
    end
endmodule