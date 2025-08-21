import cpu_consts::*;
import cpu_modules::*;

module divide (
    input logic clk,
    input logic reset,

    input logic [63:0]  opr_a_i,     //dividend
    input logic [63:0]  opr_b_i,     //divisor

    input logic         div_instr_i,
    input logic [2:0]   div_func_i,
    input logic [4:0]   rd_addr_i,
    input logic         word_op_i,

    input logic         flush_i,
    input logic         kill_i,

    output logic [63:0] div_res_o,
    output logic        valid_res_o,
    output logic [4:0]  rd_addr_o,
    output logic        div_stall_o
);

    //TODO - add kill logic
    //TODO - add DIVW, DIVUW, REMW, REMUW instructions

    //mask upper 32 bits in case of word instruction
    logic [63:0]    opr_a_correct;
    logic [63:0]    opr_b_correct;

    //vector to track division flags
    // [0] - divide by zero
    // [1] - overflow
    // [2] - zero dividend
    // [3] - short division (both operands < 15)
    logic [3:0]     div_flags;
    div_status_t    div_status;

    logic[63:0]     sc_div_res;
    logic           sc_output_en;

    logic           valid_s2;

    logic [3:0]     small_op_res;

    logic           rem_op_in;
    logic           signed_op_in;
    logic           dividend_neg_in;
    logic           divisor_neg_in;

    logic           rem_op;
    logic           signed_op;
    logic           word_op;
    logic           dividend_neg;
    logic           divisor_neg;
    logic [4:0]     rd_addr_l;

    logic           nxt_loop_run;
    logic           loop_run_q;
    logic           loop_output_en;
    
    logic           flush_l;

    logic           update_cnt_s1;
    logic           update_cnt_l;
    logic           update_cnt;
    logic [6:0]     nxt_count;
    logic [6:0]     count_q;

    logic [64:0]    a_shift_check;
    logic [64:0]    b_shift_check;
    logic [2:0]     a_vals;
    logic [2:0]     b_vals;


    logic           shift_en_in;
    logic           shift_en_s2;
    logic [3:0]     shift_1h;
    logic [3:0]     shift_vec;
    logic [5:0]     shift_amnt_in;
    logic [5:0]     shift_amnt_s2;

    logic           a_op_sel;
    logic           add;

    logic [63:0]    dividend_tc;
    logic [63:0]    q_tc;
    logic [63:0]    a_tc;

    logic           correct_rem;

    logic [63:0]    dividend_correct;
    
    logic [64:0]    m_in;
    logic [64:0]    m;
    logic [64:0]    m_correct;

    logic           q_en;
    logic [64:0]    q_q;
    logic [64:0]    nxt_q;
    logic [63:0]    q_correct;

    logic           a_en;
    logic [64:0]    a_q;
    logic [64:0]    nxt_a;
    logic [128:0]   a_shift;
    logic [64:0]    a_val;
    logic [63:0]    a_correct;

    logic [63:0]    div_res;
    logic [4:0]     rd_addr;
    logic           valid_res;
    logic           div_stall;

    assign rem_op_in        =   (div_func_i == OP_REM | div_func_i == OP_REMU);
    assign signed_op_in     =   (div_func_i == OP_DIV | div_func_i == OP_REM);
    assign dividend_neg_in  =   (word_op_i) ? opr_a_i[31] : opr_a_i[63];
    assign divisor_neg_in   =   (word_op_i) ? opr_b_i[31] : opr_b_i[63];

    assign opr_a_correct[63:0]      =   ({64{~word_op_i}} & opr_a_i[63:0]) |
                                        ({64{word_op_i & ~signed_op_in}} & {32'h0, opr_a_i[31:0]}) |
                                        ({64{word_op_i & signed_op_in}}  & {{32{opr_a_i[31]}}, opr_a_i[31:0]});

    assign opr_b_correct[63:0]      =   ({64{~word_op_i}} & opr_b_i[63:0]) |
                                        ({64{word_op_i & ~signed_op_in}} & {32'h0, opr_b_i[31:0]}) | 
                                        ({64{word_op_i & signed_op_in}}  & {{32{opr_b_i[31]}}, opr_b_i[31:0]});

    //division by zero
    assign div_flags[0]     =   (word_op_i & (opr_b_i[31:0] == 32'h0)) | (~word_op_i & (opr_b_i[63:0] == 64'h0));

    //overflow
    assign div_flags[1]     =   ( word_op_i & signed_op_in & (opr_a_i[31:0] == 32'h8000_0000) & (opr_b_i[31:0] == 32'hFFFF_FFFF)) |
                                (~word_op_i & signed_op_in & (opr_a_i[63:0] == 64'h8000_0000_0000_0000) & (opr_b_i[63:0] == 64'hFFFF_FFFF_FFFF_FFFF));

    //zero dividend
    assign div_flags[2]     =   (word_op_i & (opr_a_i[31:0] == 32'h0)) | (~word_op_i & (opr_a_i[63:0] == 64'h0));

    //small division
    assign div_flags[3]     =   (~rem_op_in &  word_op_i & (opr_a_i[31:4] == 28'h0) & (opr_b_i[31:4] == 28'h0)) | 
                                (~rem_op_in & ~word_op_i & (opr_a_i[63:4] == 60'h0) & (opr_b_i[63:4] == 60'h0));

    //small division calculation
    assign small_op_res[3]  =   (opr_a_i[3] & ~opr_b_i[3] & ~opr_b_i[2] & ~opr_b_i[1] & opr_b_i[0]);

    assign small_op_res[2]  =   (opr_a_i[3] &  opr_a_i[2]  & ~opr_b_i[3] & ~opr_b_i[2] &  opr_b_i[0]) | 
                                (opr_a_i[3] & ~opr_b_i[3]  & ~opr_b_i[2] &  opr_b_i[1] & ~opr_b_i[0]) |
                                (opr_a_i[2] & ~opr_b_i[3]  & ~opr_b_i[2] & ~opr_b_i[1] &  opr_b_i[0]);

    assign small_op_res[1]  =   ( opr_a_i[3]  &  opr_a_i[2] & ~opr_b_i[3] &  opr_b_i[1] & ~opr_b_i[0]) | 
                                ( opr_a_i[3]  &  opr_a_i[1] & ~opr_b_i[3] & ~opr_b_i[1] &  opr_b_i[0]) |
                                (~opr_a_i[3]  &  opr_a_i[2] &  opr_a_i[1] & ~opr_b_i[3] & ~opr_b_i[2] & opr_b_i[0]) | 
                                ( opr_a_i[2]  & ~opr_b_i[3] & ~opr_b_i[2] &  opr_b_i[1] & ~opr_b_i[0]) | 
                                ( opr_a_i[1]  & ~opr_b_i[3] & ~opr_b_i[2] & ~opr_b_i[1] &  opr_b_i[0]) |
                                ( opr_a_i[3]  & ~opr_b_i[3] &  opr_b_i[2] & ~opr_b_i[1] & ~opr_b_i[0]) |
                                ( opr_a_i[3]  & ~opr_a_i[2] & ~opr_b_i[3] & ~opr_b_i[2] &  opr_b_i[1] & opr_b_i[0]) |
                                ( opr_a_i[3]  &  opr_a_i[2] & ~opr_b_i[3] &  opr_b_i[2] & ~opr_b_i[1]) | 
                                ( opr_a_i[3]  &  opr_a_i[2] &  opr_a_i[1] & ~opr_b_i[3] &  opr_b_i[2]);

    assign small_op_res[0]  =   ( opr_a_i[3] &  opr_a_i[2] &  opr_b_i[2] & ~opr_b_i[1] & ~opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_a_i[2] &  opr_b_i[2] & ~opr_b_i[1] & ~opr_b_i[0]) |
                                (~opr_a_i[3] &  opr_a_i[2] &  opr_a_i[0] & ~opr_b_i[3] & ~opr_b_i[1] &  opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_a_i[0] & ~opr_b_i[2] & ~opr_b_i[1] &  opr_b_i[0]) |
                                ( opr_a_i[2] &  opr_a_i[1] &  opr_a_i[0] & ~opr_b_i[3] & ~opr_b_i[2] &  opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_a_i[1] & ~opr_b_i[2] &  opr_b_i[1] & ~opr_b_i[0]) |
                                ( opr_a_i[2] &  opr_a_i[1] &  opr_a_i[0] & ~opr_b_i[3] & ~opr_b_i[1] &  opr_b_i[0]) |
                                ( opr_a_i[3] & ~opr_a_i[2] &  opr_a_i[0] & ~opr_b_i[3] &  opr_b_i[1] &  opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_a_i[1] &  opr_a_i[0] & ~opr_b_i[2] &  opr_b_i[0]) |
                                ( opr_a_i[2] & ~opr_b_i[3] &  opr_b_i[2] & ~opr_b_i[1] & ~opr_b_i[0]) |
                                ( opr_a_i[1] & ~opr_b_i[3] & ~opr_b_i[2] &  opr_b_i[1] & ~opr_b_i[0]) |
                                ( opr_a_i[0] & ~opr_b_i[3] & ~opr_b_i[2] & ~opr_b_i[1] &  opr_b_i[0]) |
                                (~opr_a_i[3] &  opr_a_i[2] & ~opr_a_i[1] & ~opr_b_i[3] & ~opr_b_i[2] &  opr_b_i[1] & opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_b_i[3] & ~opr_b_i[2] & ~opr_b_i[1] & ~opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_b_i[3] & ~opr_b_i[2] & ~opr_b_i[1] & ~opr_b_i[0]) |
                                ( opr_a_i[3] & ~opr_a_i[2] & ~opr_b_i[3] &  opr_b_i[2] &  opr_b_i[1]) |
                                (~opr_a_i[3] &  opr_a_i[2] &  opr_a_i[0] & ~opr_b_i[3] &  opr_b_i[2] & ~opr_b_i[1]) |
                                ( opr_a_i[3] & ~opr_a_i[2] & ~opr_a_i[0] & ~opr_b_i[3] &  opr_b_i[2] &  opr_b_i[0]) |
                                (~opr_a_i[3] &  opr_a_i[2] &  opr_a_i[1] &  opr_a_i[0] & ~opr_b_i[3] &  opr_b_i[2]) |
                                ( opr_a_i[3] &  opr_a_i[2] &  opr_b_i[3] & ~opr_b_i[2]) |
                                ( opr_a_i[3] &  opr_a_i[1] &  opr_b_i[3] & ~opr_b_i[2] & ~opr_b_i[1]) |
                                ( opr_a_i[3] & ~opr_a_i[1] & ~opr_b_i[3] &  opr_b_i[2] &  opr_b_i[1] &  opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_a_i[2] &  opr_a_i[1] &  opr_b_i[3] & ~opr_b_i[0]) |
                                ( opr_a_i[3] &  opr_a_i[2] &  opr_a_i[1] &  opr_b_i[3] & ~opr_b_i[1]) |
                                ( opr_a_i[3] &  opr_a_i[2] &  opr_a_i[0] &  opr_b_i[3] & ~opr_b_i[1]) |
                                ( opr_a_i[3] & ~opr_a_i[2] &  opr_a_i[1] & ~opr_b_i[3] &  opr_b_i[1]) |
                                ( opr_a_i[3] &  opr_a_i[2] &  opr_a_i[1] &  opr_a_i[0] &  opr_b_i[3]);

    always_comb begin
        case (1'b1)
            div_flags[0]:   div_status = ZERO_DIVISOR;
            div_flags[1]:   div_status = OVERFLOW;
            div_flags[2]:   div_status = ZERO_DIVIDEND;
            div_flags[3]:   div_status = SHORT_DIV;
            default:        div_status = NONE;
        endcase
    end

    always_comb begin
        case (div_status)
            ZERO_DIVISOR: begin
                sc_div_res  =   ({64{rem_op_in}} & opr_a_i) | 
                                ({64{~rem_op_in & (~word_op_i | (word_op_i & signed_op_in))}} & 64'hFFFF_FFFF_FFFF_FFFF) |
                                ({64{~rem_op_in & word_op_i & ~signed_op_in}} & 64'hFFFF_FFFF_FFFF_FFFF);
            end
            OVERFLOW:       sc_div_res =    ({64{~rem_op}} & 64'h8000_0000_0000_0000);
            ZERO_DIVIDEND:  sc_div_res =    64'h0;
            SHORT_DIV:      sc_div_res =    {60'h0, small_op_res[3:0]}; 
            NONE:           sc_div_res =    64'h0;
        endcase
    end

    assign a_shift_check[63:0]  = opr_a_correct[63:0];
    assign a_shift_check[64]    = opr_a_correct[63] & signed_op_in;

    assign b_shift_check[63:0]  = opr_b_correct[63:0];
    assign b_shift_check[64]    = opr_b_correct[63] & signed_op_in;

    assign a_vals[2] = (~a_shift_check[64] & (a_shift_check[63:48] != {16{1'b0}})) | (a_shift_check[64] & (a_shift_check[63:47] != {17{1'b1}}));
    assign a_vals[1] = (~a_shift_check[64] & (a_shift_check[47:32] != {16{1'b0}})) | (a_shift_check[64] & (a_shift_check[46:31] != {16{1'b1}}));
    assign a_vals[0] = (~a_shift_check[64] & (a_shift_check[31:16] != {16{1'b0}})) | (a_shift_check[64] & (a_shift_check[30:15] != {16{1'b1}}));

    assign b_vals[2] = (~b_shift_check[64] & (b_shift_check[63:48] != {16{1'b0}})) | (b_shift_check[64] & (b_shift_check[63:47] != {17{1'b1}}));
    assign b_vals[1] = (~b_shift_check[64] & (b_shift_check[47:32] != {16{1'b0}})) | (b_shift_check[64] & (b_shift_check[46:31] != {16{1'b1}}));
    assign b_vals[0] = (~b_shift_check[64] & (b_shift_check[31:16] != {16{1'b0}})) | (b_shift_check[64] & (b_shift_check[30:15] != {16{1'b1}}));

    //63 bit shift
    assign shift_1h[3] =    ((a_vals[2:0] == 3'b000) & (b_vals[0])) | 
                            ((a_vals[2:1] == 2'b00)  & (b_vals[1])) | 
                            ((a_vals[2])             & (b_vals[2]));

    //48 bit shift
    assign shift_1h[2] =    ((a_vals[2:0] == 3'b000) & (b_vals[2:0] == 3'b000)) | 
                            ((a_vals[2:0] == 3'b001) & (b_vals[2:0] == 3'b001)) |
                            ((a_vals[2:1] == 2'b01)  & (b_vals[2:1] == 2'b01))  |
                            ((a_vals[2])             & (b_vals[2]));

    //32 bit shift
    assign shift_1h[1] =    ((a_vals[2:0] == 3'b001) & (b_vals[2:0] == 3'b000)) |
                            ((a_vals[2:1] == 2'b01)  & (b_vals[2:0] == 3'b001)) | 
                            ((a_vals[2])             & (b_vals[2:1] == 2'b01));

    //16 bit shift
    assign shift_1h[0] =    ((a_vals[2:1] == 2'b01)  & (b_vals[2:0] == 3'b000)) | 
                            ((a_vals[2])             & (b_vals[2:0] == 3'b001));

    assign sc_output_en         =   |div_flags & div_instr_i;
    assign shift_en_in          =   |shift_1h & div_instr_i;

    assign shift_vec[3:0]       =   ({4{shift_en_in}} & shift_1h[3:0]);

    assign shift_amnt_in[5:0]   =   ({6{shift_vec[3]}} & 6'b111111) |
                                    ({6{shift_vec[2]}} & 6'b110000) |
                                    ({6{shift_vec[1]}} & 6'b100000) |
                                    ({6{shift_vec[0]}} & 6'b010000);

    assign a_op_sel             =   signed_op & divisor_neg;
    assign add                  =   (a_q[64] | correct_rem) ^ a_op_sel;
    assign correct_rem          =   (count_q == 7'd65) & rem_op & a_q[64];
    assign valid_s2             =   (div_instr_i & ~flush_l);

    assign nxt_loop_run         =   (loop_run_q | (div_instr_i & ~|div_flags)) & ~flush_i & ~flush_l & ~valid_res;
    assign loop_output_en       =   (rem_op) ? (count_q[6:0] == 7'd65) : (count_q[6:0] == 7'd64);

    assign update_cnt_s1        =   nxt_loop_run & div_instr_i & ~flush_i & ~shift_en_in;
    assign update_cnt_l         =   loop_run_q & ~flush_l & ~valid_res;
    assign update_cnt           =   update_cnt_s1 | update_cnt_l;
    assign nxt_count[6:0]       =   {7{update_cnt}} & (count_q[6:0] + {1'b0, shift_amnt_s2} + 7'b1);

    assign dividend_tc[63:0]    =   twos_comp(q_q[63:0]);
    assign q_tc[63:0]           =   twos_comp(q_q[63:0]);
    assign a_tc[63:0]           =   twos_comp(a_q[63:0]);

    assign dividend_correct     =   (signed_op & dividend_neg) ? dividend_tc[63:0] : q_q[63:0];

    assign m_in[64:0]           =   {signed_op & opr_b_correct[63], opr_b_correct[63:0]};
    assign m_correct[64:0]      =   (add) ? m[64:0] : ~m[64:0];


    assign q_en                 =   div_instr_i | (loop_run_q & ~shift_en_in);

    assign nxt_q[64:0]          =   ({65{~loop_run_q}} & {1'b0, opr_a_correct[63:0]}) |
                                    ({65{loop_run_q & (valid_s2 | shift_en_s2)}} & ({dividend_correct[63:0], ~nxt_a[64]} << shift_amnt_s2[5:0])) |
                                    ({65{loop_run_q & ~(valid_s2 | shift_en_s2)}} & ({q_q[63:0], ~nxt_a[64]}));

    assign q_correct[63:0]      =   (signed_op & (dividend_neg ^ divisor_neg)) ? q_tc[63:0] : q_q[63:0];


    assign a_en                 =   div_instr_i | (loop_run_q & shift_en_in & (count_q[6:0] != 7'd65)) | correct_rem;

    assign a_shift[128:0]       =   {65'b0, dividend_correct[63:0]} << shift_amnt_s2[5:0];

    assign a_val[64:0]          =   ({65{correct_rem}} & a_q[64:0]) |
                                    ({65{~correct_rem & ~shift_en_s2}} & {a_q[63:0], q_q[64]}) |
                                    ({65{~correct_rem & shift_en_s2}}  & a_shift[128:64]);

    assign a_correct[63:0]      =   (signed_op & dividend_neg) ? a_tc[63:0] : a_q[63:0];

    assign nxt_a[63:0]          =   {65{loop_run_q}} & (a_val[64:0] + m_correct[64:0] + {64'h0, ~add});

    //assign outputs
    assign div_res[63:0]        =   ({64{sc_output_en}} &  sc_div_res) |
                                    ({64{~sc_output_en  &  rem_op &  word_op}} & ({{32{a_correct[31]}}, a_correct[31:0]})) |
                                    ({64{~sc_output_en  & ~rem_op &  word_op}} & ({{32{q_correct[31]}}, q_correct[31:0]})) |
                                    ({64{~sc_output_en  &  rem_op & ~word_op}} & a_correct[63:0])  |
                                    ({64{~sc_output_en  & ~rem_op & ~word_op}} & q_correct[63:0]);

    assign rd_addr[5:0]         =   ({6{sc_output_en}} & rd_addr_i) | 
                                    ({6{loop_output_en}} & rd_addr_l);

    assign valid_res            =   sc_output_en | loop_output_en;

    assign div_stall            =   nxt_loop_run;

    //ffs - no enable pin
    always_ff @(posedge clk) begin
        if (reset) begin
            loop_run_q      <= 1'b0;
            flush_l         <= 1'b0;
            shift_en_s2     <= 1'b0;
            shift_amnt_s2   <= 6'b0;
        end else begin
            loop_run_q      <= nxt_loop_run;
            flush_l         <= flush_i;
            shift_en_s2     <= shift_en_in;
            shift_amnt_s2   <= shift_amnt_in;
        end
    end

    //ffs - enabled on div_instr_i
    always_ff @(posedge clk) begin
        if (reset) begin
            rem_op          <= 1'b0;
            signed_op       <= 1'b0;
            word_op         <= 1'b0;
            dividend_neg    <= 1'b0;
            divisor_neg     <= 1'b0;
            rd_addr_l       <= 5'b0;
        end else if (div_instr_i) begin
            rem_op          <= rem_op_in;
            signed_op       <= signed_op_in;
            word_op         <= word_op_i;
            dividend_neg    <= dividend_neg_in;
            divisor_neg     <= divisor_neg_in;
            rd_addr_l       <= rd_addr_i;
        end
    end

    //count ff
    always_ff @(posedge clk) begin
        if (reset) begin
            count_q <= 7'b0;
        end else begin
            count_q <= nxt_count;
        end
    end

    //m ff
    always_ff @(posedge clk) begin
        if (reset) begin
            m <= 65'h0;
        end else if (div_instr_i) begin
            m <= m_in;
        end
    end

    //a ff
    always_ff @(posedge clk) begin
        if (reset) begin
            a_q <= 65'h0;
        end else if (a_en) begin
            a_q <= nxt_a;
        end
    end

    //q ff
    always_ff @(posedge clk) begin
        if (reset) begin
            q_q <= 65'h0;
        end else if (q_en) begin
            q_q <= nxt_q;
        end
    end

    //output ff
    always_ff @(posedge clk) begin
        if (reset) begin
            div_res_o       <= 64'h0;
            valid_res_o     <= 1'b0;
            rd_addr_o       <= 5'b0;
            div_stall_o     <= 1'b0;
        end else begin
            div_res_o       <= div_res;
            valid_res_o     <= valid_res;
            rd_addr_o       <= rd_addr;
            div_stall_o     <= div_stall;
        end
    end

endmodule