import cpu_consts::*;

module multiply (
    input logic clk,
    input logic reset,

    input logic [63:0] opr_a_i,     //multiplicand
    input logic [63:0] opr_b_i,     //multiplier

    input logic         mult_instr_i;
    input logic [2:0]   mult_func_i,
    input logic [4:0]   rd_addr_i,

    input logic         stall_i,
    input logic         kill_i,

    output logic [63:0] mult_res_o,
    output logic        valid_res_o,
    output logic [4:0]  rd_addr_o,
    output logic        rd_wr_en_o
);

    //TODO - add stall/kill logic

    // stage 1 - register inputs & split operands
    logic [31:0] a_high_s1;
    logic [31:0] a_low_s1;
    logic [31:0] b_high_s1;
    logic [31:0] b_low_s1;

    logic a_signed_s1;
    logic b_signed_s1;
    logic negate_res_s1;

    logic [2:0] mult_func_s1;
    logic       mult_instr_s1;
    logic [4:0] rd_addr_s1;
    logic       rd_wr_en_s1;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            a_high_s1       <= 32'h0;
            a_low_s1        <= 32'h0;
            b_high_s1       <= 32'h0;
            b_low_s1        <= 32'h0;

            a_signed_s1     <= 1'b0;
            b_signed_s1     <= 1'b0;
            negate_res_s1   <= 1'b0;

            mult_func_s1    <= 3'b0;
            mult_instr_s1   <= 1'b0;
            rd_addr_s1      <= 5'b0;
            rd_wr_en_s1     <= 1'b0;
        end else begin
            a_signed_s1     <= (mult_func_i == MULH || mult_func_i == MULHSU);
            b_signed_s1     <= (mult_func_i == MULH);
            negate_res_s1   <= (a[63] && a_signed_s1) ^ (b[63] && b_signed_s1);

            a_high_s1   <= get_magnitude(opr_a[63:32], a_signed_s1, opr_a_i[63]);
            a_low_s1    <= get_magnitude(opr_a[31:0], a_signed_s1, opr_a_i[63]);
            b_high_s1   <= get_magnitude(opr_b[63:32], b_signed_s1, opr_b_i[63]);
            b_low_s1    <= get_magnitude(opr_b[31:0], b_signed_s1, opr_b_i[63]);

            mult_func_s1 <= mult_func_i;
            mult_instr_s1 <= mult_instr_i;
            rd_addr_s1 <= rd_addr_i;
            rd_wr_en_s1 <= rd_wr_en_i;
        end
    end

    // stage 2 - calculate partial products
    logic [63:0] p0_s2;
    logic [63:0] p1_s2;
    logic [63:0] p2_s2;
    logic [63:0] p3_s2;

    logic       negate_res_s2;

    logic [2:0] mult_func_s2;
    logic       mult_instr_s2;
    logic [4:0] rd_addr_s2;
    logic       rd_wr_en_s2;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            p0_s2 <= 64'h0;
            p1_s2 <= 64'h0;
            p2_s2 <= 64'h0;
            p3_s2 <= 64'h0;

            negate_res_s2 <= 1'b0;

            mult_func_s2    <= 3'b0;
            mult_instr_s2   <= 1'b0;
            rd_addr_s2      <= 5'b0;
            rd_wr_en_s2     <= 1'b0;
        end else begin
            p0_s2 <= a_low_s1 * b_low_s1;
            p1_s2 <= a_low_s1 * b_high_s1;
            p2_s2 <= a_high_s1 * b_low_s1;
            p3_s2 <= a_high_s1 * b_high_s1;

            negate_res_s2   <= negate_res_s1;

            mult_func_s2    <= mult_func_s1;
            mult_instr_s2   <= mult_instr_s1;
            rd_addr_s2      <= rd_addr_s1;
            rd_wr_en_s2     <= rd_wr_en_s1;
        end
    end

    // stage 3 - combine lower 96 bits (((p1 + p2) << 32) + p0)
    logic [64:0]    cross_terms_s3;
    logic [127:0]   part_sum_s3;

    logic       negate_res_s3;

    logic [2:0] mult_func_s3;
    logic       mult_instr_s3;
    logic [4:0] rd_addr_s3;
    logic       rd_wr_en_s3;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cross_terms_s3  <= 64'h0;
            part_sum_s3     <= 64'h0;

            negate_res_s3   <= 1'b0;

            mult_func_s3    <= 3'b0;
            mult_instr_s3   <= 1'b0;
            rd_addr_s3      <= 5'b0;
            rd_wr_en_s3     <= 1'b0;
        end else begin
            cross_terms_s3  <= p1_s2 + p2_s2;
            part_sum_s3     <= {{64{1'b0}}, p0_s2} + ({{63{1'b0}}, cross_terms_s3} << 32);

            negate_res_s3   <= negate_res_s2;

            mult_func_s3    <= mult_func_s2;
            mult_instr_s3   <= mult_instr_s2;
            rd_addr_s3      <= rd_addr_s2;
            rd_wr_en_s3     <= rd_wr_en_s2;
        end
    end

    // stage 4 - add p3 to lower 96 bits
    logic [127:0]   full_sum_s4;
    
    logic       negate_res_s4;

    logic [2:0] mult_func_s4;
    logic       mult_instr_s4;
    logic [4:0] rd_addr_s4;
    logic       rd_wr_en_s4;      

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            full_sum_s4     <= 128'h0;

            negate_res_s4 <= 1'b0;
        end else begin
            full_sum_s4     <= part_sum_s3 + ({{64{1'b0}}, p3_s2} << 64);

            result_neg_s4   <= result_neg_s3;

            mult_func_s4    <= mult_func_s3;
            mult_instr_s4   <= mult_instr_s3;
            rd_addr_s4      <= rd_addr_s3;
            rd_wr_en_s4     <= rd_wr_en_s3;
        end
    end

    // stage 5 - output
    logic [127:0]   final_sum_s5;
    logic [63:0]    mult_res_s5;
    logic [63:0]    mult_res_o;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            final_sum_s5    <= 128'h0;
            mult_res        <= 128'h0;
            mult_res_o      <= 64'h0;
        end else begin
            final_sum_s5 <= negate_res_s4 ? -full_sum_s4 : full_sum_s4;
            case (mult_func_s4) 
                MUL     : mult_res_s5 <= final_sum_s5[63:0];
                MULH, 
                MULHU,
                MULHSU  : mult_res_s5 <= final_sum_s5[127:64];
            endcase
            mult_res_o  <= mult_res_s5;
            rd_addr_o   <= rd_addr_s4;
            rd_wr_en_o  <= rd_wr_en_s4;
            valid_res_o <= mult_instr_s4; 
        end
    end
endmodule