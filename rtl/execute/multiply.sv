module multiply
    import cpu_defines::*;
    import cpu_types::*;
(
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      opr_a_i,
    input logic [63:0]      opr_b_i,

    input logic             mul_valid_i,
    input logic [3:0]       mul_func_i,
    input logic             word_op_i,
    output logic            mul_ready_o,

    input logic             flushE_i,
    
    input logic             stallM_i,
    output logic            mul_res_valid_o,
    output logic [63:0]     mul_res_o
);

    logic [63:0]            opr_a;
    logic [63:0]            opr_b;

    logic [3:0]             mul_func;
    logic                   word_op;

    logic [31:0]            opr_a_high_in;
    logic [31:0]            opr_a_low_in;
    logic [31:0]            opr_a_high;
    logic [31:0]            opr_a_low;

    logic [31:0]            opr_b_high_in;
    logic [31:0]            opr_b_low_in;
    logic [31:0]            opr_b_high;
    logic [31:0]            opr_b_low;

    logic [63:0]            p0_in;
    logic [63:0]            p1_in;
    logic [63:0]            p2_in;
    logic [63:0]            p3_in;

    logic [63:0]            p0_q;
    logic [63:0]            p1_q;
    logic [63:0]            p2_q;
    logic [63:0]            p3_q;

    logic [64:0]            cross_terms;

    logic [127:0]           part_sum_in;
    logic [127:0]           part_sum_q;

    logic [127:0]           full_sum;
    logic [127:0]           final_sum;

    logic                   a_signed;
    logic                   sum_sub_b;
    logic [63:0]            correction_b;

    logic                   b_signed;
    logic                   sum_sub_a;
    logic [63:0]            correction_a;

    mul_state_t             state;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            opr_a       <=  64'h0;
            opr_b       <=  64'h0;

            mul_func    <=  4'b0;
            word_op     <=  1'b0;

            p0_q        <=  64'h0;
            p1_q        <=  64'h0;
            p2_q        <=  64'h0;
            p3_q        <=  64'h0;

            part_sum_q  <=  128'h0;

            state       <=  M_IDLE;
        end else begin
            case (state)
                M_IDLE: begin
                    if (mul_valid_i && !flushE_i) begin
                        opr_a       <=  opr_a_i;
                        opr_b       <=  opr_b_i;

                        mul_func    <=  mul_func_i;
                        word_op     <=  word_op_i;

                        p0_q        <=  p0_in;
                        p1_q        <=  p1_in;

                        state       <=  M_RUN_1;
                    end
                end
                M_RUN_1: begin
                    if (flushE_i) begin
                        state       <=  M_IDLE;
                    end else if (word_op) begin
                        if (!stallM_i) begin
                            state   <=  M_IDLE;
                        end
                    end else begin
                        p2_q        <=  p2_in;
                        p3_q        <=  p3_in;

                        state       <=  M_RUN_2;
                    end
                end
                M_RUN_2: begin
                    if (flushE_i) begin
                        state       <=  M_IDLE;
                    end else begin
                        part_sum_q  <=  part_sum_in;

                        state       <=  M_RUN_3;
                    end
                end
                M_RUN_3: begin
                    if (flushE_i || !stallM_i) begin
                        state       <=  M_IDLE;
                    end
                end
            endcase
        end
    end

    always_comb begin
        mul_ready_o         =   1'b0;
        mul_res_valid_o     =   1'b0;
        mul_res_o           =   64'h0;

        opr_a_high_in       =   opr_a_i[63:32];
        opr_a_low_in        =   opr_a_i[31:0];

        opr_b_high_in       =   opr_b_i[63:32];
        opr_b_low_in        =   opr_b_i[31:0];

        opr_a_high          =   opr_a[63:32];
        opr_a_low           =   opr_a[31:0];

        opr_b_high          =   opr_b[63:32];
        opr_b_low           =   opr_b[31:0];

        p0_in               =   opr_a_low_in * opr_b_low_in;
        p1_in               =   opr_a_low_in * opr_b_high_in;
        p2_in               =   opr_a_high * opr_b_low;
        p3_in               =   opr_a_high * opr_b_high;

        cross_terms         =   {1'b0, p1_q} + {1'b0, p2_q};
        part_sum_in         =   {64'h0, p0_q} + {31'h0, cross_terms, 32'h0};

        a_signed            =   (mul_func == MULH || mul_func == MULHSU);
        sum_sub_b           =   a_signed && opr_a[63];
        correction_b        =   sum_sub_b ? opr_b : 64'h0;

        b_signed            =   (mul_func == MULH);
        sum_sub_a           =   b_signed && opr_b[63];
        correction_a        =   sum_sub_a ? opr_a : 64'h0;

        full_sum            =   part_sum_q + {p3_q, 64'h0};
        final_sum           =   {{full_sum[127:64] - correction_b - correction_a}, full_sum[63:0]};

        case (state)
            M_IDLE: begin
                mul_ready_o     =   1'b1;
            end
            M_RUN_1: begin
                if (word_op) begin
                    mul_ready_o         =   1'b1;
                    mul_res_valid_o     =   1'b1;
                    mul_res_o           =   {{32{p0_q[31]}}, p0_q[31:0]};
                end
            end
            M_RUN_3: begin
                mul_ready_o         =   1'b1;
                mul_res_valid_o     =   1'b1;

                case (mul_func)
                    MUL: mul_res_o      =   final_sum[63:0];
                    MULH, 
                    MULHU,
                    MULHSU: mul_res_o   =   final_sum[127:64];
                    default: mul_res_o  =   64'h0;
                endcase
            end
        endcase
    end

endmodule