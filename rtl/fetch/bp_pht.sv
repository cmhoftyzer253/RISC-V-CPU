import cpu_consts::*;
import cpu_modules::*;

module pht (
    input clk,
    input reset,

    input logic [7:0]   pc_slice_i,
    input logic [9:0]   bhr_i,
    
    input logic         update_en_i,
    input logic [7:0]   pc_slice_u_i,
    input logic [9:0]   bhr_u_i,
    input logic         taken_u_i,

    output bp_cnt_t     cnt_o
);

    //2^18 depth
    localparam int DEPTH = 1 << 18;

    //initialize entries to 01 - weakly not taken
    localparam bp_cnt_t INIT_CNT = 2'b01;

    (* ram_style = "distributed" *) bp_cnt_t pht[DEPTH];

    logic [17:0]    rd_idx;
    logic [17:0]    u_idx;

    bp_cnt_t        pht_rd;
    bp_cnt_t        u_old;
    bp_cnt_t        u_new;
    bp_cnt_t        cnt;

    initial begin
        for(int i=0; i<DEPTH; i++) pht[i] = INIT_CNT;
    end

    assign rd_idx   = {bhr_i[9:0], pc_slice_i[7:0]};
    assign u_idx    = {bhr_u_i[9:0], pc_slice_u_i[7:0]};

    assign pht_rd   = pht[rd_idx];

    assign u_old    = pht[u_idx];
    assign u_new    = taken_u_i ? pht_inc(u_old) : pht_dec(u_old);

    //include bypass in case of matches indices
    assign cnt      = (update_en_i & (rd_idx == u_idx)) ? u_new : pht_rd;

    always_ff @(posedge clk) begin
        if (update_en_i) begin
            pht[u_idx] <= u_new;
        end
    end

    //output assignment
    assign cnt_o = cnt;

endmodule