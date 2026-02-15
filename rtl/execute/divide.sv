import cpu_consts::*;

module divide (
    input               clk,
    input               resetn,

    input logic [63:0]  opr_a_i,
    input logic [63:0]  opr_b_i,

    input logic         div_valid_i,
    input logic [3:0]   div_func_i,
    input logic         word_op_i,
    output logic        div_ready_o,

    input logic         flush_i,

    input logic         div_res_ready_i,
    output logic        div_res_valid_o,
    output logic [63:0] div_res_o
);

    logic [6:0]         count_q;
    logic [6:0]         nxt_count;

    logic [64:0]        m_q;
    logic [64:0]        nxt_m;

    logic [64:0]        a_q;
    logic [64:0]        nxt_a;

    logic [64:0]        q_q;
    logic [64:0]        nxt_q;

    logic               word_op_ff;
    logic               rem_op_ff;
    logic               signed_op_ff;

    logic               correct_qnt_ff;
    logic               correct_rem_ff;

    logic [63:0]        div_res_ff;

    logic [64:0]        opr_a_mask;
    logic [64:0]        opr_b_mask;

    logic [64:0]        dividend_abs;

    logic [128:0]       a_shift;
    
    logic [64:0]        a_pshift;

    logic [64:0]        m_abs;
    
    logic [5:0]         shift_amnt;
    logic [7:0]         shift_1h;

    logic [3:0]         div_flags;

    logic               loop_en;
    logic               sc_output_en;

    logic               div_done;

    logic               rem_correct;
    logic               m_neg;
    logic               add;

    logic [63:0]        q_correct;
    logic [63:0]        a_correct;
    logic [63:0]        div_res;

    logic [2:0]         a_pos;
    logic [2:0]         b_pos;

    logic [3:0]         pos_diff;

    logic [6:0]         a_vals;
    logic [6:0]         b_vals;

    logic [63:0]        small_op_qnt;
    logic [63:0]        small_op_rem;

    logic               dividend_neg_in;
    logic               divisor_neg_in;

    logic               rem_op_in;
    logic               signed_op_in;

    logic               correct_qnt;
    logic               correct_rem;

    div_state_t         state;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            word_op_ff                      <= 1'b0;
            rem_op_ff                       <= 1'b0;
            signed_op_ff                    <= 1'b0;

            correct_qnt_ff                  <= 1'b0;
            correct_rem_ff                  <= 1'b0;

            count_q                         <= 7'd0;

            m_q                             <= 65'h0;
            a_q                             <= 65'h0;
            q_q                             <= 65'h0;

            div_res_ff                      <= 64'h0;

            state                           <= S_DIV_IDLE;
        end else begin
            case (state)
                S_DIV_IDLE: begin
                    if (sc_output_en & ~div_res_ready_i) begin
                        div_res_ff          <= div_res;

                        state               <= S_DIV_OUT_SC;
                    end else if (loop_en) begin
                        word_op_ff          <= word_op_i;
                        rem_op_ff           <= rem_op_in;
                        signed_op_ff        <= signed_op_in;

                        correct_qnt_ff      <= correct_qnt;
                        correct_rem_ff      <= correct_rem;

                        m_q                 <= nxt_m;
                        a_q                 <= nxt_a;
                        q_q                 <= nxt_q;

                        count_q             <= {1'b0, shift_amnt};

                        state               <= S_DIV_RUN;
                    end
                end
                S_DIV_OUT_SC: begin
                    if (flush_i | div_res_ready_i) begin
                        div_res_ff          <= 64'h0;

                        state               <= S_DIV_IDLE;
                    end
                end
                S_DIV_RUN: begin
                    if (flush_i) begin    
                        count_q             <= 7'd0;

                        word_op_ff          <= 1'b0;
                        rem_op_ff           <= 1'b0;
                        signed_op_ff        <= 1'b0;

                        correct_qnt_ff      <= 1'b0;
                        correct_rem_ff      <= 1'b0;

                        m_q                 <= 65'h0;
                        a_q                 <= 65'h0;
                        q_q                 <= 65'h0;      

                        state               <= S_DIV_IDLE; 
                    end else if (div_done) begin            
                        if (div_res_ready_i) begin
                            count_q         <= 7'd0;

                            word_op_ff      <= 1'b0;
                            rem_op_ff       <= 1'b0;
                            signed_op_ff    <= 1'b0;

                            correct_qnt_ff  <= 1'b0;
                            correct_rem_ff  <= 1'b0;

                            m_q             <= 65'h0;
                            a_q             <= 65'h0;
                            q_q             <= 65'h0; 

                            state           <= S_DIV_IDLE;
                        end else begin
                            div_res_ff      <= div_res;

                            state           <= S_DIV_OUT_CC;
                        end
                    end else begin                          
                        count_q             <= nxt_count;

                        a_q                 <= nxt_a;
                        q_q                 <= nxt_q;
                    end
                end
                S_DIV_OUT_CC: begin
                    if (flush_i | div_res_ready_i) begin
                        count_q             <= 7'd0;

                        div_res_ff          <= 64'h0;

                        word_op_ff          <= 1'b0;
                        rem_op_ff           <= 1'b0;
                        signed_op_ff        <= 1'b0;

                        correct_qnt_ff      <= 1'b0;
                        correct_rem_ff      <= 1'b0;

                        m_q                 <= 65'h0;
                        a_q                 <= 65'h0;
                        q_q                 <= 65'h0;

                        state               <= S_DIV_IDLE;
                    end
                end
                default: begin
                    state                   <= S_DIV_IDLE;
                end
            endcase
        end
    end 

    always_comb begin

        rem_correct             =   1'b0;
        add                     =   1'b0;

        m_abs                   =   65'h0;

        a_pshift                =   65'h0;

        q_correct               =   64'h0;
        a_correct               =   64'h0;

        shift_1h                =   8'b0;
        div_flags               =   4'b0;

        nxt_count               =   count_q;

        nxt_m                   =   m_q;
        nxt_a                   =   a_q;
        nxt_q                   =   q_q;

        div_ready_o             =   1'b0;
        div_res_valid_o         =   1'b0;
        div_res_o               =   64'h0;
        div_done                =   1'b0;

        case (state)
            S_DIV_IDLE: begin
                div_ready_o         =   1'b1;

                rem_op_in           =   (div_func_i == REM | div_func_i == REMU);
                signed_op_in        =   (div_func_i == DIV | div_func_i == REM);
                dividend_neg_in     =   signed_op_in & (word_op_i ? opr_a_i[31] : opr_a_i[63]);
                divisor_neg_in      =   signed_op_in & (word_op_i ? opr_b_i[31] : opr_b_i[63]);

                opr_a_mask[63:0]    =   ({64{~word_op_i}}                 & opr_a_i)                            | 
                                        ({64{ word_op_i & ~signed_op_in}} & {32'h0, opr_a_i[31:0]})             | 
                                        ({64{ word_op_i &  signed_op_in}} & {{32{opr_a_i[31]}}, opr_a_i[31:0]}); 

                opr_b_mask[63:0]    =   ({64{~word_op_i}}                 & opr_b_i[63:0])                      |
                                        ({64{ word_op_i & ~signed_op_in}} & {32'h0, opr_b_i[31:0]})             |
                                        ({64{ word_op_i &  signed_op_in}} & {{32{opr_b_i[31]}}, opr_b_i[31:0]});

                //zero divisor
                div_flags[0]        =   (word_op_i & (opr_b_i[31:0] == 32'h0)) | (~word_op_i & (opr_b_i == 64'h0));

                //overflow
                div_flags[1]        =   ( word_op_i & signed_op_in & (opr_a_i[31:0] == 32'h8000_0000) & (opr_b_i[31:0] == 32'hFFFF_FFFF)) | 
                                        (~word_op_i & signed_op_in & (opr_a_i == 64'h8000_0000_0000_0000) & (opr_b_i == 64'hFFFF_FFFF_FFFF_FFFF));

                //zero dividend
                div_flags[2]        =   (word_op_i & (opr_a_i[31:0] == 32'h0)) | (~word_op_i & (opr_a_i == 64'h0));

                //short circuit division
                div_flags[3]        =   ( word_op_i & ~|opr_a_i[31:4] & ~|opr_b_i[31:4]) | 
                                        (~word_op_i & ~|opr_a_i[63:4] & ~|opr_b_i[63:4]);

                small_op_qnt        =   ~div_flags[0] ? {60'h0, (opr_a_i[3:0] / opr_b_i[3:0])} : 64'hFFFF_FFFF_FFFF_FFFF;
                small_op_rem        =   ~div_flags[0] ? {60'h0, (opr_a_i[3:0] % opr_b_i[3:0])} : (word_op_i ? {{32{opr_a_i[31]}}, opr_a_i[31:0]} : opr_a_i);

                sc_output_en        =   div_valid_i & ~flush_i & |div_flags;

                if (div_flags[0]) begin
                    div_res             =   rem_op_in ? 
                                            (word_op_i ? {{32{opr_a_i[31]}}, opr_a_i[31:0]} : opr_a_i) : 
                                            64'hFFFF_FFFF_FFFF_FFFF;
                    div_res_valid_o     =   sc_output_en;
                end else if (div_flags[1]) begin
                    div_res             =   rem_op_in ? 64'h0 : 
                                            (word_op_i ? {{32{opr_a_i[31]}}, opr_a_i[31:0]} : opr_a_i);
                    div_res_valid_o     =   sc_output_en;
                end else if (div_flags[2]) begin
                    div_res             =   64'h0;
                    div_res_valid_o     =   sc_output_en;
                end else if (div_flags[3]) begin
                    div_res             =   rem_op_in ? small_op_rem : small_op_qnt;
                    div_res_valid_o     =   div_valid_i & ~flush_i;
                end else begin
                    div_res             =   64'h0;
                    div_res_valid_o     =   1'b0;
                end

                div_res_o           =   div_res;

                opr_a_mask[64]      =   opr_a_mask[63] & signed_op_in;
                opr_b_mask[64]      =   opr_b_mask[63] & signed_op_in;

                a_vals[6]           =   (~opr_a_mask[64] & (opr_a_mask[63:56] != 8'h0)) | (opr_a_mask[64] & (opr_a_mask[63:55] != 9'h1FF));
                a_vals[5]           =   (~opr_a_mask[64] & (opr_a_mask[55:48] != 8'h0)) | (opr_a_mask[64] & (opr_a_mask[54:47] != 8'hFF));
                a_vals[4]           =   (~opr_a_mask[64] & (opr_a_mask[47:40] != 8'h0)) | (opr_a_mask[64] & (opr_a_mask[46:39] != 8'hFF));
                a_vals[3]           =   (~opr_a_mask[64] & (opr_a_mask[39:32] != 8'h0)) | (opr_a_mask[64] & (opr_a_mask[38:31] != 8'hFF));
                a_vals[2]           =   (~opr_a_mask[64] & (opr_a_mask[31:24] != 8'h0)) | (opr_a_mask[64] & (opr_a_mask[30:23] != 8'hFF));
                a_vals[1]           =   (~opr_a_mask[64] & (opr_a_mask[23:16] != 8'h0)) | (opr_a_mask[64] & (opr_a_mask[22:15] != 8'hFF));
                a_vals[0]           =   (~opr_a_mask[64] & (opr_a_mask[15:8]  != 8'h0)) | (opr_a_mask[64] & (opr_a_mask[14:7]  != 8'hFF));

                b_vals[6]           =   (~opr_b_mask[64] & (opr_b_mask[63:56] != 8'h0)) | (opr_b_mask[64] & (opr_b_mask[63:56] != 8'hFF));
                b_vals[5]           =   (~opr_b_mask[64] & (opr_b_mask[55:48] != 8'h0)) | (opr_b_mask[64] & (opr_b_mask[55:48] != 8'hFF));
                b_vals[4]           =   (~opr_b_mask[64] & (opr_b_mask[47:40] != 8'h0)) | (opr_b_mask[64] & (opr_b_mask[47:40] != 8'hFF));
                b_vals[3]           =   (~opr_b_mask[64] & (opr_b_mask[39:32] != 8'h0)) | (opr_b_mask[64] & (opr_b_mask[39:32] != 8'hFF));
                b_vals[2]           =   (~opr_b_mask[64] & (opr_b_mask[31:24] != 8'h0)) | (opr_b_mask[64] & (opr_b_mask[31:24] != 8'hFF));
                b_vals[1]           =   (~opr_b_mask[64] & (opr_b_mask[23:16] != 8'h0)) | (opr_b_mask[64] & (opr_b_mask[23:16] != 8'hFF));
                b_vals[0]           =   (~opr_b_mask[64] & (opr_b_mask[15:8]  != 8'h0)) | (opr_b_mask[64] & (opr_b_mask[15:8]  != 8'hFF));

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

                pos_diff            =   $signed({1'b0, a_pos}) - $signed({1'b0, b_pos});

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

                loop_en             =   div_valid_i & ~flush_i & ~|div_flags;

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

                nxt_m               =   opr_b_mask;
                m_neg               =   signed_op_in & ((word_op_i & opr_b_i[31]) | (~word_op_i & opr_b_i[63]));

                dividend_abs        =   dividend_neg_in ? ~opr_a_mask + 65'b1 : opr_a_mask;

                a_shift             =   {65'b0, dividend_abs[63:0]} << shift_amnt;
                nxt_a               =   a_shift[128:64];

                nxt_q               =   dividend_abs << shift_amnt;

                correct_qnt         =   signed_op_in & (dividend_neg_in ^ divisor_neg_in); 
                correct_rem         =   signed_op_in & dividend_neg_in;
            end
            S_DIV_OUT_SC: begin
                div_res_o           =   div_res_ff;
                div_res_valid_o     =   ~flush_i;
            end
            S_DIV_RUN: begin
                nxt_count           =   count_q + 7'd1;

                rem_correct         =   (count_q[6:0] == 7'd64) & rem_op_ff & a_q[64];
                m_neg               =   (signed_op_ff & ((word_op_ff & m_q[31]) | (~word_op_ff & m_q[63])));
                add                 =   (a_q[64] | rem_correct) ^ m_neg;

                m_abs               =   add ? m_q : ~m_q;

                a_pshift            =   rem_correct ? a_q : {a_q[63:0], q_q[63]};
                nxt_a               =   a_pshift + m_abs + {64'b0, ~add};

                nxt_q               =   {q_q[63:0], ~nxt_a[64]};   

                div_done            =   ~flush_i & ((rem_op_ff & (count_q == 7'd65)) | (~rem_op_ff & (count_q == 7'd64)));

                q_correct           =   correct_qnt_ff ? ~q_q[63:0] + 64'b1 : q_q[63:0];
                a_correct           =   correct_rem_ff ? ~a_q[63:0] + 64'b1 : a_q[63:0];


                div_res             =   ({64{ rem_op_ff &  word_op_ff}} & {{32{a_correct[31]}}, a_correct[31:0]})   | 
                                        ({64{~rem_op_ff &  word_op_ff}} & {{32{q_correct[31]}}, q_correct[31:0]})   | 
                                        ({64{ rem_op_ff & ~word_op_ff}} & a_correct[63:0])                          |
                                        ({64{~rem_op_ff & ~word_op_ff}} & q_correct[63:0]);

                div_res_valid_o     =   div_done;
                div_res_o           =   div_res;
            end
            S_DIV_OUT_CC: begin
                div_res_valid_o     =   1'b1;
                div_res_o           =   div_res_ff;
            end
        endcase
    end
endmodule