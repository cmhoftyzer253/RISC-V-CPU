import cpu_defines::*;
import cpu_types::*;

module multiply (
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      opr_a_i,
    input logic [63:0]      opr_b_i,

    input logic             mul_valid_i,
    input logic [3:0]       mul_func_i,
    input logic             word_op_i,

    input logic             stallE_i,
    input logic             flushE_i,

    input logic             stallM_i,
    output logic [63:0]     mul_res_o,
    output logic            mul_res_valid_o
);

    logic [31:0]            a_high_q;
    logic [31:0]            a_low_q;
    logic [31:0]            b_high_q;
    logic [31:0]            b_low_q;

    logic                   negate_res;
    logic [3:0]             mul_func;
    logic                   word_op;

    logic [63:0]            p0_q;
    logic [63:0]            p1_q;
    logic [63:0]            p2_q;
    logic [63:0]            p3_q;

    logic [127:0]           part_sum_q;

    logic                   a_signedD;
    logic                   b_signedD;

    logic                   a_negate_dw;
    logic                   a_correct_dw;
    logic                   a_negate_w;
    logic                   a_correct_w;

    logic                   b_negate_dw;
    logic                   b_correct_dw;
    logic                   b_negate_w;
    logic                   b_correct_w;

    logic [63:0]            a_mag;
    logic [63:0]            b_mag;

    logic [31:0]            a_highD;
    logic [31:0]            a_lowD;
    logic [31:0]            b_highD;
    logic [31:0]            b_lowD;

    logic                   negate_resD;

    logic [63:0]            p0_in;
    logic [63:0]            p1_in;
    logic [63:0]            p2_in;
    logic [63:0]            p3_in;

    logic [64:0]            cross_terms;
    
    logic [127:0]           part_sum_in;

    logic [63:0]            mul_res_correct;

    logic [127:0]           full_sum;
    logic [127:0]           final_sum;

    mul_state_t             state;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            a_high_q                    <= 32'h0;
            a_low_q                     <= 32'h0;

            b_high_q                    <= 32'h0;
            b_low_q                     <= 32'h0;

            negate_res                  <= 1'b0;
            mul_func                    <= MUL;
            word_op                     <= 1'b0;

            p0_q                        <= 64'h0;
            p1_q                        <= 64'h0;
            p2_q                        <= 64'h0;
            p3_q                        <= 64'h0;

            part_sum_q                  <= 128'h0;

            state                       <= M_IDLE;
        end else begin
            case (state)
                M_IDLE: begin
                    if (mul_valid_i && !stallE_i) begin
                        a_high_q        <=  a_highD;
                        a_low_q         <=  a_lowD;
                        b_high_q        <=  b_highD;
                        b_low_q         <=  b_lowD;

                        negate_res      <=  negate_resD;
                        mul_func        <=  mul_func_i;
                        word_op         <=  word_op_i;

                        state           <=  M_RUN_1;
                    end
                end
                M_RUN_1: begin
                    if (flushE_i) begin
                        state           <=  M_IDLE;
                    end else begin
                        p0_q            <=  p0_in;
                        p1_q            <=  p1_in;

                        state           <=  M_RUN_2;
                    end
                end
                M_RUN_2: begin
                    if (flushE_i) begin
                        state           <=  M_IDLE;
                    end else if (word_op) begin
                        if (!stallM_i) begin
                            state       <=  M_IDLE;
                        end
                    end else begin
                        p2_q            <=  p2_in;
                        p3_q            <=  p3_in;

                        state           <=  M_RUN_3;
                    end
                end 
                M_RUN_3: begin
                    if (flushE_i) begin
                        state           <=  M_IDLE;
                    end else begin
                        part_sum_q      <=  part_sum_in;

                        state           <=  M_RUN_4;
                    end
                end 
                M_RUN_4: begin
                    if (flushE_i || !stallM_i) begin
                        state           <=  M_IDLE;
                    end 
                end
            endcase
        end
    end

    always_comb begin
        mul_res_o               =   64'h0;
        mul_res_valid_o         =   1'b0;

        a_signedD               =   1'b0;
        b_signedD               =   1'b0;
        negate_resD             =   1'b0;

        a_negate_dw             =   1'b0;
        a_correct_dw            =   1'b0;
        a_negate_w              =   1'b0;
        a_correct_w             =   1'b0;

        b_negate_dw             =   1'b0;
        b_correct_dw            =   1'b0;
        b_negate_w              =   1'b0;
        b_correct_w             =   1'b0;

        a_mag                   =   64'h0;
        b_mag                   =   64'h0;

        a_highD                 =   32'h0;
        a_lowD                  =   32'h0;
        b_highD                 =   32'h0;
        b_lowD                  =   32'h0;

        p0_in                   =   64'h0;
        p1_in                   =   64'h0;
        p2_in                   =   64'h0;
        p3_in                   =   64'h0;

        cross_terms             =   65'h0;
        part_sum_in             =   128'h0;

        mul_res_correct         =   64'h0;
        full_sum                =   128'h0;
        final_sum               =   128'h0;

        case (state)
            M_IDLE: begin
                a_signedD       =   (mul_func_i == MUL || mul_func_i == MULH || mul_func_i == MULHSU);
                b_signedD       =   (mul_func_i == MUL || mul_func_i == MULH);

                negate_resD     =   (!word_op_i && ((opr_a_i[63] && a_signedD) ^ (opr_b_i[63] && b_signedD))) ||
                                    ( word_op_i &&  (opr_a_i[31] ^ opr_b_i[31]));

                a_negate_dw     =   a_signedD && opr_a_i[63] && !word_op_i;
                a_correct_dw    =   (!a_signedD || !opr_a_i[63]) && !word_op_i;
                a_negate_w      =   word_op_i &&  opr_a_i[31];
                a_correct_w     =   word_op_i && !opr_a_i[31];

                a_mag           =   ({64{a_negate_dw}}  & (~opr_a_i + 64'b1))                   | 
                                    ({64{a_correct_dw}} & ( opr_a_i))                           |
                                    ({64{a_negate_w}}   & {32'h0, (~opr_a_i[31:0] + 32'b1)})    | 
                                    ({64{a_correct_w}}  & {32'h0, opr_a_i[31:0]});

                a_highD         =   a_mag[63:32];
                a_lowD          =   a_mag[31:0];

                b_negate_dw     =   b_signedD && opr_b_i[63] && !word_op_i;
                b_correct_dw    =   (!b_signedD || !opr_b_i[63]) && !word_op_i;
                b_negate_w      =   word_op_i &&  opr_b_i[31];
                b_correct_w     =   word_op_i && !opr_b_i[31];

                b_mag           =   ({64{b_negate_dw}}  & (~opr_b_i + 64'b1))                   | 
                                    ({64{b_correct_dw}} & ( opr_b_i))                           | 
                                    ({64{b_negate_w}}   & {32'h0, (~opr_b_i[31:0] + 32'b1)})    | 
                                    ({64{b_correct_w}}  & {32'h0, opr_b_i[31:0]});

                b_highD         =   b_mag[63:32];
                b_lowD          =   b_mag[31:0];
            end
            M_RUN_1: begin
                p0_in           =   a_low_q * b_low_q;
                p1_in           =   a_low_q * b_high_q;
            end
            M_RUN_2: begin
                p2_in           =   a_high_q * b_low_q;
                p3_in           =   a_high_q * b_high_q;

                if (word_op) begin
                    mul_res_correct         =   negate_res ? ~p0_q + 64'b1 : p0_q;
                    mul_res_o               =   {{32{mul_res_correct[31]}}, mul_res_correct[31:0]};
                    mul_res_valid_o         =   !flushE_i;
                end
            end
            M_RUN_3: begin
                cross_terms     =   {1'b0, p1_q} + {1'b0, p2_q};
                part_sum_in     =   {64'h0, p0_q} + {31'h0, cross_terms, 32'h0};
            end
            M_RUN_4: begin
                full_sum        =   part_sum_q + {p3_q, 64'h0};
                final_sum       =   negate_res ? ~full_sum + 128'b1 : full_sum;

                case (mul_func)
                    MUL:     mul_res_o      =   final_sum[63:0];
                    MULH,
                    MULHU, 
                    MULHSU:  mul_res_o      =   final_sum[127:64];
                    default: mul_res_o      =   64'h0;
                endcase
                
                mul_res_valid_o =   !flushE_i;
            end
        endcase
    end

endmodule