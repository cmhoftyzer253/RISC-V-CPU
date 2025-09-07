import cpu_consts::*;
import cpu_modules::*;

module branch_predictor(
    input logic clk,
    input logic reset,

    input logic [63:0]  pc_i,

    input logic         update_en_i,
    input logic [63:0]  pc_u_i,
    input logic [63:0]  target_u_i,
    input logic         taken_u_i,
    input btb_type_t    type_u_i,
    input logic [63:0]  ret_addr_u_i,
    input logic [9:0]   bhr_u_i,
    
    output logic        pred_taken_o,
    output logic [63:0] pred_target_o,
    output btb_type_t   pred_type_o
);

    logic [9:0]     bhr;

    bp_cnt_t        pht_cnt;
    logic           pht_update_en;

    btb_type_t      btb_pred_type;
    logic           btb_hit;
    logic [63:0]    btb_target;

    logic           ras_push;
    logic [63:0]    ras_push_addr;

    logic           ras_pop;
    logic [63:0]    ras_pop_addr;

    logic           ras_empty;

    logic           pred_taken;
    logic [63:0]    pred_target;
    logic           ras_cmd;

    bhr_table u_bhr_table (
        .clk            (clk),
        .reset          (reset),
        .pc_i           (pc_i),
        .update_en_i    (update_en_i),
        .pc_u_i         (pc_u_i),
        .taken_u_i      (taken_u_i),
        .bhr_o          (bhr)
    );

    assign pht_update_en = update_en_i & (type_u_i == BRANCH);

    pht u_pht (
        .clk            (clk),
        .reset          (reset),
        .pc_slice_i     (pc_i[9:2]),
        .bhr_i          (bhr),
        .update_en_i    (pht_update_en),
        .pc_slice_u_i   (pc_u_i[9:2]),
        .bhr_u_i        (bhr_u_i),                    
        .taken_u_i      (taken_u_i),
        .cnt_o          (pht_cnt)
    );

    btb u_btb (
        .clk            (clk),
        .reset          (reset),
        .pc_i           (pc_i),
        .update_en_i    (update_en_i),
        .pc_u_i         (pc_u_i),
        .target_u_i     (target_u_i),
        .taken_u_i      (taken_u_i),
        .type_u_i       (type_u_i),
        .hit_o          (btb_hit),
        .target_o       (btb_target),
        .type_o         (btb_pred_type)
    );

    assign ras_push         = update_en_i & taken_u_i & (type_u_i == CALL);
    assign ras_pop          = update_en_i & taken_u_i & (type_u_i == RETURN);

    assign ras_push_addr    = ret_addr_u_i;

    ras u_ras (
        .clk            (clk),
        .reset          (reset),
        .push_i         (ras_push),
        .push_addr_i    (ras_push_addr),
        .pop_i          (ras_pop),
        .pop_addr_o     (ras_pop_addr),
        .empty_o        (ras_empty)
    );

    assign pred_taken           =   (btb_hit & (btb_pred_type == BRANCH) & pht_cnt[1]) |
                                    (btb_hit & ((btb_pred_type == CALL) | (btb_pred_type == RETURN) | (btb_pred_type == JUMP)));

    assign ras_cmd              =   btb_hit & (btb_pred_type == RETURN) & ~ras_empty;

    assign pred_target[63:0]    =   ({64{ ras_cmd}} & (ras_pop_addr[63:0])) |
                                    ({64{~ras_cmd}} & (btb_target));

    //output assignments
    assign pred_taken_o     = pred_taken;
    assign pred_target_o    = pred_target;
    assign pred_type_o      = btb_pred_type;

endmodule