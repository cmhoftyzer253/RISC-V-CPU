import cpu_consts::*;
import cpu_modules::*;

module btb(
    input logic clk,
    input logic reset,

    input logic [63:0]   pc_i,

    input logic         update_en_i,
    input logic [63:0]  pc_u_i,
    input logic [63:0]  target_u_i,
    input logic         taken_u_i,
    input btb_type_t    type_u_i,

    output logic        hit_o,
    output logic [63:0] target_o, 
    output btb_type_t   type_o
);

    //Tag Width: 53 (64-9-2)
    //IDXW: 9 ( log2(512) )

    logic [8:0]         set_rd;
    logic [52:0]        tag_rd;

    logic [8:0]         set_u;
    logic [52:0]        tag_u;

    btb_entry_t         r0;
    btb_entry_t         r1;

    btb_entry_t         entry_u;

    logic               update_en;

    logic               hit_w0_en;
    logic               hit_w1_en;

    logic               empty_w0_en;
    logic               empty_w1_en;

    logic               evict_w0_en;
    logic               evict_w1_en;
    
    logic               hit_r0;
    logic               hit_r1;
    logic               hit;

    logic [61:0]        target_upper;  
    logic [63:0]        target;

    btb_type_t          type;

    // 0 - way 0 LRU, evict next
    // 1 - way 1 LRU, evict next
    logic lru [512];

    // valid bits for way 0 & 1
    // synthesizes to registers not DRAM
    logic valid_w0[512];
    logic valid_w1[512];

    (* ram_style = "distributed" *) btb_entry_t w0 [512];
    (* ram_style = "distributed" *) btb_entry_t w1 [512];

    // -------------------- READ LOGIC -------------------------
    assign set_rd[8:0]  = pc_i[10:2];
    assign tag_rd[52:0] = pc_i[63:11];

    assign r0 = w0[set_rd];
    assign r1 = w1[set_rd];

    assign hit_r0   = valid_w0[set_rd] & (r0.tag == tag_rd);
    assign hit_r1   = valid_w1[set_rd] & (r1.tag == tag_rd);
    assign hit      = hit_r0 | hit_r1;

    assign target_upper[61:0]   =   ({62{hit_r0}} & r0.target[61:0]) |
                                    ({62{hit_r1}} & r1.target[61:0]);

    assign target               =   {target_upper[61:0], 2'b0};
 
    assign type                 =   ({2{hit_r0}} & r0.type) |
                                    ({2{hit_r1}} & r1.type);

    // -------------------- UPDATE LOGIC -------------------------
    assign set_u[8:0]  = pc_u_i[10:2];
    assign tag_u[52:0] = pc_u_i[63:11];

    assign entry_u.tag    = tag_u;
    assign entry_u.target = target_u_i[63:2];
    assign entry_u.type   = type_u_i;

    // -------------------- UPDATE TABLE -------------------------

    assign update_en = update_en_i & taken_u_i;

    assign hit_w0_en = update_en & valid_w0[set_u] & (w0[set_u].tag == tag_u);
    assign hit_w1_en = update_en & valid_w1[set_u] & (w1[set_u].tag == tag_u);

    assign empty_w0_en = update_en & ~valid_w0[set_u];
    assign empty_w1_en = update_en & ~valid_w1[set_u];

    assign evict_w0_en = update_en & valid_w0[set_u] & valid_w1[set_u] & (lru[set_u] == 1'b0);
    assign evict_w1_en = update_en & valid_w0[set_u] & valid_w1[set_u] & (lru[set_u] == 1'b1);

    assign same_set_wr = (set_rd == set_u);
    assign wr = hit_w0_en | hit_w1_en | empty_w0_en | empty_w1_en | evict_w0_en | evict_w1_en;

    always_ff @(posedge clk) begin
        if (reset) begin
            for(int i=0; i<512; i++) begin
                valid_w0[i] <= 1'b0;
                valid_w1[i] <= 1'b0;
                lru[i]      <= 1'b0;
            end
        end else if (hit_w0_en | empty_w0_en | evict_w0_en) begin
            w0[set_u]       <= entry_u;
            valid_w0[set_u] <= 1'b1;
            lru[set_u]      <= 1'b1;
        end else if (hit_w1_en | empty_w1_en | evict_w1_en) begin
            w1[set_u]       <= entry_u;
            valid_w1[set_u] <= 1'b1;
            lru[set_u]      <= 1'b0;
        end 

        if (hit & ~(same_set_wr & wr)) begin
            lru[set_rd]     <= hit_r0;
        end
    end

    //output assignments
    assign hit_o            = hit;
    assign target_o[63:0]   = target[63:0];
    assign type_o           = type;

endmodule