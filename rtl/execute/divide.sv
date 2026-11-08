module divide
    import cpu_defines::*;
    import cpu_types::*;
(
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      opr_a_i,
    input logic [63:0]      opr_b_i,

    input logic             div_valid_i,
    input logic [3:0]       div_func_i,
    input logic             word_op_i,
    output logic            div_ready_o,

    input logic             flushE_i,

    input logic             stallM_i,
    output logic            div_res_valid_o,
    output logic [63:0]     div_res_o
);

    logic [6:0]             count_ff;
    logic [6:0]             nxt_count;

    logic [64:0]            m_ff;
    logic [64:0]            m_init;

    logic [64:0]            a_ff;
    logic [64:0]            nxt_a;
    logic [64:0]            a_init;

    logic [64:0]            q_ff;
    logic [64:0]            nxt_q;
    logic [64:0]            q_init;

    logic [64:0]            opr_a_mask;
    logic [64:0]            opr_b_mask;
    logic [64:0]            dividend_abs;

    logic [128:0]           a_shift;
    logic [64:0]            a_pshift;
    logic [64:0]            m_abs;

    logic [5:0]             shift_amnt;
    logic [7:0]             shift_1h;

    logic [3:0]             div_flags;
    logic                   div_done;

    logic                   rem_correct;
    logic                   m_neg;
    logic                   add;

    logic [63:0]            q_correct;
    logic [63:0]            a_correct;

    logic sc_en;
    logic [63:0]            sc_res;
    logic [63:0]            div_res_iter;
    
    logic [2:0]             a_pos;
    logic [2:0]             b_pos;
    logic [3:0]             pos_diff;
    
    logic [6:0]             a_vals;
    logic [6:0]             b_vals;

    logic [63:0]            small_op_qnt;
    logic [63:0]            small_op_rem;

    logic                   dividend_neg;
    logic                   divisor_neg;

    logic                   rem_op;
    logic                   signed_op;

    logic                   correct_qnt;
    logic                   correct_rem;

    div_state_t             state;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            count_ff    <= 7'd0;

            m_ff        <= 65'h0;
            a_ff        <= 65'h0;
            q_ff        <= 65'h0;

            state       <= D_INIT;
        end else begin
            case (state) 
                D_INIT: begin
                    if (div_valid_i && !sc_en && !flushE_i) begin
                        m_ff        <=  m_init;
                        a_ff        <=  a_init;
                        q_ff        <=  q_init;

                        count_ff    <=  {1'b0, shift_amnt};

                        state       <=  D_ITER;
                    end
                end
                D_ITER: begin
                    if (flushE_i) begin
                        state       <=  D_INIT;
                    end else if (div_done) begin
                        if (!stallM_i) begin
                            state   <=  D_INIT;
                        end
                    end else begin
                        count_ff    <=  nxt_count;

                        a_ff        <=  nxt_a;
                        q_ff        <=  nxt_q;
                    end
                end
            endcase
        end
    end

    always_comb begin
        dividend_abs            =   65'h0;
        a_shift                 =   129'h0;

        div_res_iter            =   64'h0;

        rem_correct             =   1'b0;
        add                     =   1'b0;

        m_neg                   =   1'b0;
        m_abs                   =   65'h0;

        a_pshift                =   65'h0;

        q_correct               =   64'h0;
        a_correct               =   64'h0;

        nxt_count               =   count_ff;

        nxt_a                   =   a_ff;
        nxt_q                   =   q_ff;

        rem_op                  =   (div_func_i == REM) || (div_func_i == REMU);
        signed_op               =   (div_func_i == DIV) || (div_func_i == REM);
        dividend_neg            =   signed_op && (word_op_i ? opr_a_i[31] : opr_a_i[63]);
        divisor_neg             =   signed_op && (word_op_i ? opr_b_i[31] : opr_b_i[63]);

        opr_a_mask[63:0]        =   ({64{!word_op_i}}              & opr_a_i)                                 | 
                                    ({64{ word_op_i && !signed_op}} & {32'h0, opr_a_i[31:0]})                 | 
                                    ({64{ word_op_i &&  signed_op}} & {{32{opr_a_i[31]}}, opr_a_i[31:0]}); 

        opr_b_mask[63:0]        =   ({64{!word_op_i}}              & opr_b_i[63:0])                           |
                                    ({64{ word_op_i && !signed_op}} & {32'h0, opr_b_i[31:0]})                 |
                                    ({64{ word_op_i &&  signed_op}} & {{32{opr_b_i[31]}}, opr_b_i[31:0]});

        //zero divisor
        div_flags[0]            =   (word_op_i && (opr_b_i[31:0] == 32'h0)) || (!word_op_i && (opr_b_i == 64'h0));

        //overflow
        div_flags[1]            =   ( word_op_i && signed_op && (opr_a_i[31:0] == 32'h8000_0000) && (opr_b_i[31:0] == 32'hFFFF_FFFF)) || 
                                    (!word_op_i && signed_op && (opr_a_i == 64'h8000_0000_0000_0000) && (opr_b_i == 64'hFFFF_FFFF_FFFF_FFFF));

        //zero dividend
        div_flags[2]            =   (word_op_i && (opr_a_i[31:0] == 32'h0)) || (!word_op_i && (opr_a_i == 64'h0));

        //short circuit division
        div_flags[3]            =   ( word_op_i && ~|opr_a_i[31:4] && ~|opr_b_i[31:4]) || 
                                    (!word_op_i && ~|opr_a_i[63:4] && ~|opr_b_i[63:4]);

        sc_en                   =   |div_flags;

        small_op_qnt            =   !div_flags[0] ? {60'h0, (opr_a_i[3:0] / opr_b_i[3:0])} : 64'hFFFF_FFFF_FFFF_FFFF;
        small_op_rem            =   !div_flags[0] ? {60'h0, (opr_a_i[3:0] % opr_b_i[3:0])} : (word_op_i ? {{32{opr_a_i[31]}}, opr_a_i[31:0]} : opr_a_i);

        if (div_flags[0]) begin
            sc_res              =   rem_op ? 
                                    (word_op_i ? {{32{opr_a_i[31]}}, opr_a_i[31:0]} : opr_a_i) : 
                                    64'hFFFF_FFFF_FFFF_FFFF;
        end else if (div_flags[1]) begin
            sc_res              =   rem_op ? 64'h0 : 
                                    (word_op_i ? {{32{opr_a_i[31]}}, opr_a_i[31:0]} : opr_a_i);
        end else if (div_flags[2]) begin
            sc_res              =   64'h0;
        end else if (div_flags[3]) begin
            sc_res              =   rem_op ? small_op_rem : small_op_qnt;
        end else begin
            sc_res              =   64'h0;
        end

        opr_a_mask[64]          =   opr_a_mask[63] && signed_op;
        opr_b_mask[64]          =   opr_b_mask[63] && signed_op;

        a_vals[6]               =   (!opr_a_mask[64] && (opr_a_mask[63:56] != 8'h0)) || (opr_a_mask[64] && (opr_a_mask[63:55] != 9'h1FF));
        a_vals[5]               =   (!opr_a_mask[64] && (opr_a_mask[55:48] != 8'h0)) || (opr_a_mask[64] && (opr_a_mask[54:47] != 8'hFF));
        a_vals[4]               =   (!opr_a_mask[64] && (opr_a_mask[47:40] != 8'h0)) || (opr_a_mask[64] && (opr_a_mask[46:39] != 8'hFF));
        a_vals[3]               =   (!opr_a_mask[64] && (opr_a_mask[39:32] != 8'h0)) || (opr_a_mask[64] && (opr_a_mask[38:31] != 8'hFF));
        a_vals[2]               =   (!opr_a_mask[64] && (opr_a_mask[31:24] != 8'h0)) || (opr_a_mask[64] && (opr_a_mask[30:23] != 8'hFF));
        a_vals[1]               =   (!opr_a_mask[64] && (opr_a_mask[23:16] != 8'h0)) || (opr_a_mask[64] && (opr_a_mask[22:15] != 8'hFF));
        a_vals[0]               =   (!opr_a_mask[64] && (opr_a_mask[15:8]  != 8'h0)) || (opr_a_mask[64] && (opr_a_mask[14:7]  != 8'hFF));

        b_vals[6]               =   (!opr_b_mask[64] && (opr_b_mask[63:56] != 8'h0)) || (opr_b_mask[64] && (opr_b_mask[63:56] != 8'hFF));
        b_vals[5]               =   (!opr_b_mask[64] && (opr_b_mask[55:48] != 8'h0)) || (opr_b_mask[64] && (opr_b_mask[55:48] != 8'hFF));
        b_vals[4]               =   (!opr_b_mask[64] && (opr_b_mask[47:40] != 8'h0)) || (opr_b_mask[64] && (opr_b_mask[47:40] != 8'hFF));
        b_vals[3]               =   (!opr_b_mask[64] && (opr_b_mask[39:32] != 8'h0)) || (opr_b_mask[64] && (opr_b_mask[39:32] != 8'hFF));
        b_vals[2]               =   (!opr_b_mask[64] && (opr_b_mask[31:24] != 8'h0)) || (opr_b_mask[64] && (opr_b_mask[31:24] != 8'hFF));
        b_vals[1]               =   (!opr_b_mask[64] && (opr_b_mask[23:16] != 8'h0)) || (opr_b_mask[64] && (opr_b_mask[23:16] != 8'hFF));
        b_vals[0]               =   (!opr_b_mask[64] && (opr_b_mask[15:8]  != 8'h0)) || (opr_b_mask[64] && (opr_b_mask[15:8]  != 8'hFF));

        casez (a_vals)
            7'b1??????: a_pos       =   3'd7;
            7'b01?????: a_pos       =   3'd6;
            7'b001????: a_pos       =   3'd5;
            7'b0001???: a_pos       =   3'd4;
            7'b00001??: a_pos       =   3'd3;
            7'b000001?: a_pos       =   3'd2;
            7'b0000001: a_pos       =   3'd1;
            default: a_pos          =   3'd0;
        endcase

        casez (b_vals)
            7'b1??????: b_pos       =   3'd7;
            7'b01?????: b_pos       =   3'd6;
            7'b001????: b_pos       =   3'd5;
            7'b0001???: b_pos       =   3'd4;
            7'b00001??: b_pos       =   3'd3;
            7'b000001?: b_pos       =   3'd2;
            7'b0000001: b_pos       =   3'd1;
            default: b_pos          =   3'd0;
        endcase

        pos_diff                =   $signed({1'b0, a_pos}) - $signed({1'b0, b_pos});

        shift_1h                =   8'h0;
        case (pos_diff)
            4'd0: shift_1h[6]       =   1'b1;
            4'd1: shift_1h[5]       =   1'b1;
            4'd2: shift_1h[4]       =   1'b1;
            4'd3: shift_1h[3]       =   1'b1;
            4'd4: shift_1h[2]       =   1'b1;
            4'd5: shift_1h[1]       =   1'b1;
            4'd6: shift_1h[0]       =   1'b1;
            4'd7: shift_1h[0]       =   1'b1;
            default: shift_1h[7]    =   1'b1;
        endcase

        case (shift_1h)
            8'b1000_0000: shift_amnt        =   6'd63;
            8'b0100_0000: shift_amnt        =   6'd56;
            8'b0010_0000: shift_amnt        =   6'd48;
            8'b0001_0000: shift_amnt        =   6'd40;
            8'b0000_1000: shift_amnt        =   6'd32;
            8'b0000_0100: shift_amnt        =   6'd24;
            8'b0000_0010: shift_amnt        =   6'd16;
            8'b0000_0001: shift_amnt        =   6'd8;
            default: shift_amnt             =   6'd0;
        endcase

        correct_qnt             =   signed_op && (dividend_neg ^ divisor_neg);
        correct_rem             =   signed_op && dividend_neg;

        dividend_abs            =   dividend_neg ? ~opr_a_mask + 65'b1 : opr_a_mask;

        a_shift                 =   {65'b0, dividend_abs[63:0]} << shift_amnt;

        m_init                  =   opr_b_mask;
        a_init                  =   a_shift[128:64];
        q_init                  =   dividend_abs << shift_amnt;

        div_ready_o             =   1'b0;

        div_res_valid_o         =   1'b0;
        div_res_o               =   64'h0;
        div_done                =   1'b0;

        case (state)
            D_INIT: begin
                div_ready_o         =   !div_valid_i || sc_res;
                div_res_valid_o     =   div_valid_i && sc_en;
                div_res_o           =   sc_res;
            end
            D_ITER: begin
                nxt_count           =   count_ff + 7'd1;

                rem_correct         =   (count_ff[6:0] == 7'd64) && rem_op && a_ff[64];
                m_neg               =   (signed_op && ((word_op_i && m_ff[31]) || (!word_op_i && m_ff[63])));
                add                 =   (a_ff[64] || rem_correct) ^ m_neg;

                m_abs               =   add ? m_ff : ~m_ff;

                a_pshift            =   rem_correct ? a_ff : {a_ff[63:0], q_ff[63]};
                nxt_a               =   a_pshift + m_abs + {64'b0, !add};

                nxt_q               =   {q_ff[63:0], !nxt_a[64]};   

                div_done            =   (rem_op && (count_ff == 7'd65)) || ((!rem_op || !a_ff[64]) && (count_ff == 7'd64));

                q_correct           =   correct_qnt ? ~q_ff[63:0] + 64'b1 : q_ff[63:0];
                a_correct           =   correct_rem ? ~a_ff[63:0] + 64'b1 : a_ff[63:0];

                div_res_iter        =   ({64{ rem_op &&  word_op_i}} & {{32{a_correct[31]}}, a_correct[31:0]})   | 
                                        ({64{!rem_op &&  word_op_i}} & {{32{q_correct[31]}}, q_correct[31:0]})   | 
                                        ({64{ rem_op && !word_op_i}} & a_correct[63:0])                          |
                                        ({64{!rem_op && !word_op_i}} & q_correct[63:0]);

                div_ready_o         =   div_done;
                div_res_valid_o     =   div_done;
                div_res_o           =   div_res_iter;
            end
        endcase
    end

endmodule