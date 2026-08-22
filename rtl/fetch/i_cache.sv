import cpu_defines::*;
import cpu_utils::*;
import cpu_types::*;

module i_cache(
    input logic             clk,
    input logic             resetn,

    input logic             resetn_q_i,

    output logic            ic_ready_o,                              
    input logic [63:0]      pc_i,

    input logic             ifu_ready_i,
    output logic            instr_valid_o,
    output logic [31:0]     instr_o,

    output logic [63:0]     pcF_o,

    input logic             arready_i,
    output logic [63:0]     araddr_o,
    output logic [7:0]      arlen_o,
    output logic [2:0]      arsize_o,
    output logic [1:0]      arburst_o,
    output logic            arlock_o,
    output logic [3:0]      arid_o,
    output logic [3:0]      arcache_o,
    output logic [2:0]      arprot_o,
    output logic [3:0]      arqos_o,
    output logic            arvalid_o,

    input logic [3:0]       rid_i,
    input logic [63:0]      rdata_i,
    input logic [1:0]       rresp_i,
    input logic             rlast_i,
    input logic             rvalid_i,
    output logic            rready_o,

    input logic             flush_i,
    input logic             stop_fillline_i,

    input logic             invalidate_i,
    output logic            invalidate_done_o,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o
);

    logic [51:0]        tag;
    logic [51:0]        tagF;
    logic [5:0]         index;
    logic [5:0]         indexF;
    logic [3:0]         offset;
    logic [3:0]         offsetF;
    logic [8:0]         data_index;
    logic               data_sel;

    logic [7:0]         hit_1h;
    logic [2:0]         hit_way;
    logic [7:0]         valid_sets;
    logic               hit_raw;
    logic               hit;
    logic               miss;

    logic               flush;
    logic               exc;
    logic               invalidate;

    logic [6:0]         PLRU_rd_set;
    logic [6:0]         nxt_PLRU_hit;
    logic [6:0]         nxt_PLRU_refill;
    logic [2:0]         way_fill_PLRU;
    logic [2:0]         way_fill_invalid;
    logic               way_fill_evict;
    logic [2:0]         nxt_way_fill;

    logic [31:0]        instr_sel;

    logic [31:0]        instr_hold;
    logic [2:0]         beat_cnt;
    logic [2:0]         way_fill_q;

    logic               flush_ff;
    logic               invalidate_ff;
    logic               exc_ff;

    logic [6:0]         PLRU_tree [63:0];

    logic [63:0]        pcF;

    ic_state_t          state;

    logic [7:0][51:0]   tag_rd;
    logic [7:0][63:0]   data_rd;

    logic [7:0][63:0]   valid;

    logic               tag_rd_en;
    logic [5:0]         tag_rd_addr;
    logic [7:0]         tag_wr_en;
    logic [5:0]         tag_wr_addr;
    logic [51:0]        tag_wr_data;

    logic               data_rd_en;
    logic [8:0]         data_rd_addr;
    logic [7:0]         data_wr_en;
    logic [8:0]         data_wr_addr;
    logic [63:0]        data_wr_data;

    //tag, data RAM
    genvar w;
    generate
        for (w=0; w<8; w++) begin : tag_RAM
            xpm_memory_sdpram #(
                .MEMORY_SIZE            (64 * 52),
                .MEMORY_PRIMITIVE       ("auto"),
                .CLOCKING_MODE          ("common_clock"),
                .WRITE_DATA_WIDTH_A     (52),
                .ADDR_WIDTH_A           (6),
                .BYTE_WRITE_WIDTH_A     (52),
                .READ_DATA_WIDTH_B      (52),
                .ADDR_WIDTH_B           (6),
                .READ_LATENCY_B         (1),
                .READ_RESET_VALUE_B     ("0"),
                .WRITE_MODE_B           ("read_first"),
                .MEMORY_INIT_FILE       ("none"),
                .USE_MEM_INIT           (0),
                .ECC_MODE               ("no_ecc")
            ) u_tag_spdram (
                .clka                   (clk),
                .ena                    (1'b1),
                .wea                    (tag_wr_en[w]),
                .addra                  (tag_wr_addr),
                .dina                   (tag_wr_data),
                .clkb                   (clk),
                .enb                    (tag_rd_en),
                .addrb                  (tag_rd_addr),
                .doutb                  (tag_rd[w]),
                .rstb                   (1'b0),
                .regceb                 (1'b1),
                .sleep                  (1'b0),
                .injectsbiterra         (1'b0),
                .injectdbiterra         (1'b0),
                .sbiterrb               (),
                .dbiterrb               ()
            );
        end

        for (w=0; w<8; w++) begin : data_RAM
            xpm_memory_sdpram #(
                .MEMORY_SIZE            (512 * 64),
                .MEMORY_PRIMITIVE       ("block"),
                .CLOCKING_MODE          ("common_clock"),
                .WRITE_DATA_WIDTH_A     (64),
                .ADDR_WIDTH_A           (9),
                .BYTE_WRITE_WIDTH_A     (64),
                .READ_DATA_WIDTH_B      (64),
                .ADDR_WIDTH_B           (9),
                .READ_LATENCY_B         (1),
                .READ_RESET_VALUE_B     ("0"),
                .WRITE_MODE_B           ("read_first"),
                .MEMORY_INIT_FILE       ("none"),
                .USE_MEM_INIT           (0),
                .ECC_MODE               ("no_ecc")
            ) u_data_spdram (
                .clka                   (clk),
                .ena                    (1'b1),
                .wea                    (data_wr_en[w]),
                .addra                  (data_wr_addr),
                .dina                   (data_wr_data),
                .clkb                   (clk),
                .enb                    (data_rd_en),
                .addrb                  (data_rd_addr),
                .doutb                  (data_rd[w]),
                .rstb                   (1'b0),
                .regceb                 (1'b1),
                .sleep                  (1'b0),
                .injectsbiterra         (1'b0),
                .injectdbiterra         (1'b0),
                .sbiterrb               (),
                .dbiterrb               ()
            );
        end
    endgenerate

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            flush_ff        <=  1'b0;
            invalidate_ff   <=  1'b0;
            exc_ff          <=  1'b0;

            beat_cnt        <=  3'd0;
            way_fill_q      <=  3'b0;
            instr_hold      <=  32'h0;

            pcF             <=  64'h0;

            valid           <=  '0;

            state           <=  IC_RUN;
        end else begin
            case (state) 
                IC_RUN: begin
                    if (hit) begin
                        PLRU_tree[indexF]   <=  nxt_PLRU_hit;
                    end
                    if (!miss && ifu_ready_i) begin
                        pcF             <=  pc_i;
                    end
                    if (miss) begin
                        way_fill_q                      <=  nxt_way_fill;
                        valid[nxt_way_fill][indexF]     <=  1'b0;
                    end
                    if (invalidate_i) begin
                        valid   <=  '0;
                    end

                    if (miss) begin
                        state   <=  IC_REFILL_REQ;
                    end
                end
                IC_REFILL_REQ: begin
                    flush_ff        <=  flush_ff || flush_i;
                    invalidate_ff   <=  invalidate_ff || invalidate_i;

                    if (arready_i)
                        state       <=  IC_REFILL;
                end
                IC_REFILL: begin
                    flush_ff        <=  flush_ff || flush_i;
                    invalidate_ff   <=  invalidate_ff || invalidate_i;

                    if (rvalid_i) begin
                        if (offsetF[3:1] == beat_cnt)
                            instr_hold  <=  data_sel ? rdata_i[63:32] : rdata_i[31:0];

                        exc_ff  <=  exc_ff || exc;

                        if ((beat_cnt == 3'd7) || rlast_i) begin
                            beat_cnt    <=  3'd0;

                            state       <=  IC_REFILL_DONE;
                        end else begin
                            beat_cnt    <=  beat_cnt + 3'd1;
                        end
                    end
                end
                IC_REFILL_DONE: begin
                    if (invalidate || flush || ifu_ready_i) begin
                        instr_hold      <=  32'h0;
                        invalidate_ff   <=  1'b0;
                        flush_ff        <=  1'b0;
                        exc_ff          <=  1'b0;

                        pcF             <=  pc_i;

                        if (invalidate) begin
                            valid       <=  '0;
                        end else if (!exc_ff) begin
                            valid[way_fill_q][indexF]   <=  1'b1;

                            PLRU_tree[indexF]   <=  nxt_PLRU_refill;
                        end
                    end

                    if (invalidate || flush || ifu_ready_i)
                        state           <=  IC_RUN;
                end
            endcase
        end
    end

    //load/store logic 
    always_comb begin
        tag                 =   pc_i[63:12];
        index               =   pc_i[11:6];
        data_index          =   pc_i[11:3];
        offset              =   pc_i[5:2];

        tagF                =   pcF[63:12];
        indexF              =   pcF[11:6];
        offsetF             =   pcF[5:2];

        data_sel            =   pcF[2];

        for (int w=0; w<8; w++)
            hit_1h[w] = valid[w][indexF] && (tagF == tag_rd[w]);

        hit_way = 3'd0;
        for (int w=0; w<8; w++)
            if (hit_1h[w]) hit_way = w[2:0];

        hit_raw             =   |hit_1h;
        hit                 =   hit_raw && !stop_fillline_i && !flush_i && !invalidate_i && resetn_q_i;
        miss                =   !hit_raw && !stop_fillline_i && !flush_i && !invalidate_i && resetn_q_i;

        instr_sel           =   data_sel ? data_rd[hit_way][63:32] : data_rd[hit_way][31:0];
    end

    //select victim
    always_comb begin
        PLRU_rd_set         =   PLRU_tree[indexF];

        nxt_PLRU_hit        =   plru_update(PLRU_rd_set, hit_way);
        nxt_PLRU_refill     =   plru_update(PLRU_rd_set, way_fill_q);

        casez (PLRU_rd_set)
            7'b00?0???: way_fill_PLRU       =   3'd0;
            7'b00?1???: way_fill_PLRU       =   3'd1;
            7'b01??0??: way_fill_PLRU       =   3'd2;
            7'b01??1??: way_fill_PLRU       =   3'd3;
            7'b1?0??0?: way_fill_PLRU       =   3'd4;
            7'b1?0??1?: way_fill_PLRU       =   3'd5;
            7'b1?1???0: way_fill_PLRU       =   3'd6;
            7'b1?1???1: way_fill_PLRU       =   3'd7;
            default: way_fill_PLRU          =   3'd0;
        endcase

        for (int w=0; w<8; w++)
            valid_sets[w] = valid[w][indexF];

        way_fill_evict      =   &valid_sets;

        way_fill_invalid    =   3'd0;
        for (int w=7; w >= 0; w--)
            if (!valid_sets[w]) way_fill_invalid = w[2:0];

        nxt_way_fill        =   way_fill_evict ? way_fill_PLRU : way_fill_invalid;
    end

    always_comb begin
        ic_ready_o          =   1'b0;
        instr_valid_o       =   1'b0;
        instr_o             =   32'h0;
        pcF_o               =   pcF;

        tag_rd_en           =   1'b0;
        tag_rd_addr         =   6'b0;
        tag_wr_en           =   8'b0;
        tag_wr_addr         =   6'b0;
        tag_wr_data         =   52'h0;

        data_rd_en          =   1'b0;
        data_rd_addr        =   9'b0;
        data_wr_en          =   8'b0;
        data_wr_addr        =   9'b0;
        data_wr_data        =   64'h0;

        araddr_o            =   64'h0;
        arvalid_o           =   1'b0;
        arlen_o             =   8'd0;
        arsize_o            =   3'd0;
        arburst_o           =   2'b0;
        arlock_o            =   1'b0;
        arid_o              =   4'b0;
        arcache_o           =   4'b0;
        arprot_o            =   3'b0;
        arqos_o             =   4'b0;

        rready_o            =   1'b0;

        invalidate_done_o   =   1'b0;

        exc_valid_o         =   1'b0;
        exc_code_o          =   5'd0;

        flush               =   flush_ff || flush_i;
        exc                 =   rvalid_i && ((rresp_i != 2'b00) || (rid_i != ID_IFU) || (rlast_i ^ (beat_cnt == 3'd7)));
        invalidate          =   invalidate_ff || invalidate_i;

        case (state)
            IC_RUN: begin
                instr_o             =   instr_sel;
                instr_valid_o       =   hit;
                ic_ready_o          =   !miss && ifu_ready_i;

                tag_rd_en           =   !miss && ifu_ready_i;
                tag_rd_addr         =   index;
                data_rd_en          =   !miss && ifu_ready_i;
                data_rd_addr        =   data_index;

                invalidate_done_o   =   invalidate_i;
            end
            IC_REFILL_REQ: begin
                araddr_o    =   {pcF[63:6], 6'b0};
                arlen_o     =   8'd7;
                arsize_o    =   SIZE_8B;
                arburst_o   =   INCR;
                arlock_o    =   1'b0;
                arid_o      =   ID_IFU;
                arcache_o   =   CACHE_WB_RALLOC;
                arprot_o    =   PROT_IFU;
                arqos_o     =   4'b0000;
                arvalid_o   =   1'b1;
            end
            IC_REFILL: begin
                tag_wr_en[way_fill_q]   =   rvalid_i && (rlast_i || (beat_cnt == 3'd7));
                tag_wr_addr             =   indexF;
                tag_wr_data             =   tagF;

                data_wr_en[way_fill_q]  =   rvalid_i;
                data_wr_addr            =   {indexF, beat_cnt};
                data_wr_data            =   rdata_i;

                rready_o    =   1'b1;
            end
            IC_REFILL_DONE: begin
                tag_rd_en               =   invalidate || flush || ifu_ready_i;
                tag_rd_addr             =   index;
                data_rd_en              =   invalidate || flush || ifu_ready_i;
                data_rd_addr            =   data_index;

                invalidate_done_o       =   invalidate;

                ic_ready_o              =   flush || invalidate || ifu_ready_i;

                if (!(flush || invalidate)) begin
                    instr_o             =   instr_hold;
                    instr_valid_o       =   1'b1;

                    exc_valid_o         =   exc_ff;
                    exc_code_o          =   I_ACC_FAULT;
                end
            end
        endcase
    end

endmodule