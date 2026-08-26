import cpu_defines::*;
import cpu_types::*;
import cpu_utils::*;

module d_cache(

    input logic             clk,
    input logic             resetn,

    input logic             dc_valid_i,
    input logic [63:0]      dc_data_i,
    input logic             dc_ls_i,
    input logic [63:0]      dc_addr_i,
    input logic [7:0]       dc_mask_i,
    output logic            dc_ready_o,

    input logic             lsu_ready_i,        
    output logic            dc_rvalid_o,
    output logic [63:0]     dc_ldata_o,    

    output logic            validM_o,
    output logic [63:0]     dataM_o,
    output logic [63:0]     addrM_o,   
    output logic [7:0]      maskM_o,    

    //AXI4 Interface
    // load request (AR channel)
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

    // load response (R channel)
    input logic [3:0]       rid_i,
    input logic [63:0]      rdata_i,
    input logic [1:0]       rresp_i,
    input logic             rlast_i,
    input logic             rvalid_i,
    output logic            rready_o,

    // store request (AW, W channels)
    input logic             awready_i,
    input logic             wready_i,
    output logic [63:0]     awaddr_o,
    output logic            awvalid_o,
    output logic [2:0]      awsize_o,
    output logic [7:0]      awlen_o,
    output logic [1:0]      awburst_o,
    output logic            awlock_o,
    output logic [3:0]      awid_o,
    output logic [3:0]      awcache_o,
    output logic [2:0]      awprot_o,
    output logic [3:0]      awqos_o,
    output logic [63:0]     wdata_o,
    output logic [7:0]      wstrb_o,
    output logic            wvalid_o,
    output logic            wlast_o,

    // store response (B channel)
    input logic [1:0]       bresp_i,
    input logic             bvalid_i,
    input logic [3:0]       bid_i,
    output logic            bready_o,

    input logic             flushM_i,
    input logic             stop_cacheop_i,   

    input logic             clean_i,
    output logic            clean_done_o,

    output logic            exc_valid_o
);

    logic [51:0]        tag;
    logic [51:0]        tagM;
    logic [5:0]         index;
    logic [5:0]         indexM;
    logic [2:0]         offset;
    logic [2:0]         offsetM;
    logic [8:0]         data_index;
    logic [8:0]         data_indexM;

    logic [7:0]         hit_1h;
    logic [2:0]         hit_way;
    logic               hit_raw;
    logic               hit;
    logic               miss;

    logic               flush;
    logic               exc;
    logic               flush_ff;
    logic               exc_ff;

    logic [2:0]         beat_cnt;
    logic [2:0]         prefetch_cnt;

    logic [63:0]        data_hold;

    logic               bypass_active;
    logic               nxt_bypass_active;
    logic [63:0]        bypass_data;

    logic [2:0]         cur_way;

    logic [63:0]        load_data;
    logic [63:0]        load_data_eff;
    logic [63:0]        store_data;
    logic [63:0]        refill_data;
    logic [63:0]        refill_data_eff;

    logic [7:0]         valid_sets;
    logic [6:0]         PLRU_rd_set;
    logic [6:0]         nxt_PLRU_hit;
    logic [6:0]         nxt_PLRU_refill;
    logic [2:0]         way_fill_PLRU;
    logic [2:0]         way_fill_invalid;
    logic               way_fill_evict;
    logic [2:0]         nxt_way_fill;
    logic [2:0]         way_fill_q;
    logic               way_dirty;
    logic               wb_dirty;
    logic [51:0]        victim_tag;

    logic               way_clean_done;
    logic [5:0]         clean_line;
    logic [63:0]        cur_way_dirty;

    logic               validM;
    logic [63:0]        addrM;
    logic [63:0]        dataM;
    logic               lsM;
    logic [7:0]         maskM;

    logic [6:0]         PLRU_tree [63:0];

    logic [4:0]         state;

    logic [7:0][51:0]   tag_rd;
    logic [7:0][63:0]   data_rd;

    logic [7:0][63:0]   valid;
    logic [7:0][63:0]   dirty;

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
            validM          <=  1'b0;
            addrM           <=  64'h0;
            dataM           <=  64'h0;
            lsM             <=  DC_LOAD;
            maskM           <=  8'b0;

            bypass_active   <=  1'b0;
            bypass_data     <=  64'h0;

            flush_ff        <=  1'b0;
            exc_ff          <=  1'b0;

            way_fill_q      <=  3'd0;
            beat_cnt        <=  3'd0;
            data_hold       <=  64'h0;

            cur_way         <=  3'd0;

            valid           <=  '0;
            dirty           <=  '0;

            state           <=  DC_RUN;
        end else begin
            case (state)
                DC_RUN: begin
                    bypass_active   <=  nxt_bypass_active;
                    bypass_data     <=  store_data;

                    if (hit && lsu_ready_i) begin
                        PLRU_tree[indexM]  <=  nxt_PLRU_hit;

                        if (lsM == DC_STORE)
                            dirty[hit_way][indexM]          <=  1'b1;
                    end
                    if (!miss && lsu_ready_i) begin
                        validM      <=  dc_valid_i;
                        addrM       <=  dc_addr_i;
                        dataM       <=  dc_data_i;
                        lsM         <=  dc_ls_i;
                        maskM       <=  dc_mask_i;
                    end
                    if (miss) begin
                        way_fill_q                      <=  nxt_way_fill;
                        beat_cnt                        <=  3'd0;
                        valid[nxt_way_fill][indexM]     <=  1'b0;
                    end

                    //state updates
                    if (miss) begin
                        if (wb_dirty)
                            state   <=  DC_WRITEBACK_REQ;
                        else
                            state   <=  DC_REFILL_REQ;
                    end else if (clean_i && !flushM_i) begin
                        cur_way     <=  3'd0;

                        state       <=  DC_CLEAN;
                    end
                end
                DC_WRITEBACK_REQ: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (awready_i)
                        state   <=  DC_WRITEBACK;
                end
                DC_WRITEBACK: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (wready_i) begin
                        if (beat_cnt == 3'd7) begin
                            beat_cnt    <=  3'd0;

                            state       <=  DC_WRITEBACK_DONE;
                        end else begin
                            beat_cnt    <=  beat_cnt + 3'd1;
                        end
                    end
                end
                DC_WRITEBACK_DONE: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (bvalid_i) begin
                        dirty[way_fill_q][indexM]   <=  1'b0;

                        if (flush) begin
                            flush_ff    <=  1'b0;

                            state       <=  DC_RUN;
                        end else begin
                            beat_cnt    <=  3'd0;

                            state       <=  DC_REFILL_REQ;
                        end
                    end
                end
                DC_REFILL_REQ: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (arready_i)
                        state   <=  DC_REFILL;
                end
                DC_REFILL: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (rvalid_i) begin
                        exc_ff <= exc_ff || exc;

                        if (offsetM == beat_cnt)
                            data_hold   <=  refill_data_eff;

                        if ((beat_cnt == 3'd7) || rlast_i) begin
                            beat_cnt    <=  3'd0;

                            dirty[way_fill_q][indexM]   <=  (lsM == DC_STORE);

                            state       <=  DC_REFILL_DONE;
                        end else begin
                            beat_cnt    <=  beat_cnt + 3'd1;
                        end
                    end
                end
                DC_REFILL_DONE: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    //data registers
                    if (flush || lsu_ready_i) begin
                        validM          <= dc_valid_i;
                        addrM           <= dc_addr_i;
                        dataM           <= dc_data_i;
                        lsM             <= dc_ls_i;
                        maskM           <= dc_mask_i;

                        flush_ff        <=  1'b0;
                        exc_ff          <=  1'b0;
                        bypass_active   <=  1'b0;

                        if (!exc_ff) begin
                            PLRU_tree[indexM]           <=  nxt_PLRU_refill;

                            valid[way_fill_q][indexM]   <=  1'b1;
                        end

                        state           <=  DC_RUN;
                    end
                end
                DC_CLEAN: begin
                    if (flushM_i) begin
                        cur_way         <=  3'd0;

                        state           <=  DC_RUN;
                    end else if (way_clean_done) begin
                        if (cur_way == 3'd7) begin
                            cur_way     <=  3'd0;
                            state       <=  DC_RUN;
                        end else begin
                            cur_way     <=  cur_way + 3'd1;
                        end
                    end else begin
                        state           <=  DC_CLEAN_WRITEBACK_REQ;
                    end
                end
                DC_CLEAN_WRITEBACK_REQ: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (awready_i) begin
                        state   <=  DC_CLEAN_WRITEBACK;
                    end
                end
                DC_CLEAN_WRITEBACK: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (wready_i) begin
                        if (beat_cnt == 3'd7) begin
                            beat_cnt    <=  3'd0;

                            state       <=  DC_CLEAN_WRITEBACK_DONE;
                        end else begin
                            beat_cnt    <=  beat_cnt + 3'd1;
                        end
                    end
                end
                DC_CLEAN_WRITEBACK_DONE: begin
                    flush_ff    <=  flush_ff || flushM_i;

                    if (bvalid_i) begin
                        dirty[cur_way][clean_line]  <=  1'b0;

                        if (flush) begin
                            flush_ff    <=  1'b0;
                            cur_way     <=  3'd0;

                            state       <=  DC_RUN;
                        end else begin
                            state       <=  DC_CLEAN;
                        end
                    end
                end
            endcase
        end
    end

    //load/store logic 
    always_comb begin
        tag                 =   dc_addr_i[63:12];
        index               =   dc_addr_i[11:6];
        data_index          =   dc_addr_i[11:3];
        offset              =   dc_addr_i[5:3];

        tagM                =   addrM[63:12];
        indexM              =   addrM[11:6];
        data_indexM         =   addrM[11:3];
        offsetM             =   addrM[5:3];

        prefetch_cnt        =   beat_cnt + 3'd1;

        for (int w=0; w<8; w++)
            hit_1h[w] = valid[w][indexM] && (tagM == tag_rd[w]);

        hit_way = 3'd0;
        for (int w=0; w<8; w++)
            if (hit_1h[w]) hit_way = w[2:0];

        hit_raw             =   |hit_1h;
        hit                 =   hit_raw && validM && !flushM_i && !stop_cacheop_i;
        miss                =   !hit_raw && validM && !flushM_i && !stop_cacheop_i;

        nxt_bypass_active   =   dc_valid_i && (lsM == DC_STORE) && hit && (addrM[63:3] == dc_addr_i[63:3]);

        load_data           =   data_rd[hit_way];

        load_data_eff       =   bypass_active ? bypass_data : load_data;

        store_data[7:0]     =   maskM[0] ? dataM[7:0] : load_data_eff[7:0];
        store_data[15:8]    =   maskM[1] ? dataM[15:8] : load_data_eff[15:8];
        store_data[23:16]   =   maskM[2] ? dataM[23:16] : load_data_eff[23:16];
        store_data[31:24]   =   maskM[3] ? dataM[31:24] : load_data_eff[31:24];
        store_data[39:32]   =   maskM[4] ? dataM[39:32] : load_data_eff[39:32];
        store_data[47:40]   =   maskM[5] ? dataM[47:40] : load_data_eff[47:40];
        store_data[55:48]   =   maskM[6] ? dataM[55:48] : load_data_eff[55:48];
        store_data[63:56]   =   maskM[7] ? dataM[63:56] : load_data_eff[63:56];

        refill_data[7:0]    =   maskM[0] ? dataM[7:0] : rdata_i[7:0];
        refill_data[15:8]   =   maskM[1] ? dataM[15:8] : rdata_i[15:8];
        refill_data[23:16]  =   maskM[2] ? dataM[23:16] : rdata_i[23:16];
        refill_data[31:24]  =   maskM[3] ? dataM[31:24] : rdata_i[31:24];
        refill_data[39:32]  =   maskM[4] ? dataM[39:32] : rdata_i[39:32];
        refill_data[47:40]  =   maskM[5] ? dataM[47:40] : rdata_i[47:40];
        refill_data[55:48]  =   maskM[6] ? dataM[55:48] : rdata_i[55:48];
        refill_data[63:56]  =   maskM[7] ? dataM[63:56] : rdata_i[63:56];

        refill_data_eff     =   ((lsM == DC_STORE) && (beat_cnt == offsetM)) ? refill_data : rdata_i; 
    end

    //select victim
    always_comb begin
        PLRU_rd_set         =   PLRU_tree[indexM];

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
            valid_sets[w] = valid[w][indexM];

        way_fill_evict      =   &valid_sets;

        way_fill_invalid    =   3'd0;
        for (int w=7; w >= 0; w--)
            if (!valid_sets[w]) way_fill_invalid = w[2:0];

        nxt_way_fill        =   way_fill_evict ? way_fill_PLRU : way_fill_invalid;

        way_dirty           =   dirty[nxt_way_fill][indexM];

        wb_dirty            =   way_fill_evict && way_dirty;

        victim_tag          =   tag_rd[way_fill_q];
    end

    //clean logic 
    always_comb begin
        cur_way_dirty   =   dirty[cur_way];
        way_clean_done  =   ~|cur_way_dirty;

        clean_line      =   6'd0;
        for (int i=63; i >= 0; i--)
            if (cur_way_dirty[i]) clean_line = i[5:0];
    end

    always_comb begin
        validM_o            =   validM;
        dataM_o             =   dataM;
        addrM_o             =   addrM;
        maskM_o             =   maskM;

        dc_ready_o          =   1'b0;
        dc_rvalid_o         =   1'b0;
        dc_ldata_o          =   64'h0;

        araddr_o            =   64'h0;
        arvalid_o           =   1'b0;
        arlen_o             =   8'd0;
        arsize_o            =   3'd0;
        arburst_o           =   2'b0;
        arid_o              =   4'b0;
        arcache_o           =   4'd0;
        arprot_o            =   3'b0;
        arqos_o             =   4'd0;
        
        rready_o            =   1'b0;

        awaddr_o            =   64'h0;
        awvalid_o           =   1'b0;
        awsize_o            =   3'd0;
        awlen_o             =   8'd0;
        awburst_o           =   2'b0;
        awlock_o            =   1'b0;
        awid_o              =   4'b0;
        awcache_o           =   4'b0;
        awprot_o            =   3'b0;
        awqos_o             =   4'b0;

        wdata_o             =   64'h0;
        wstrb_o             =   8'b0;
        wvalid_o            =   1'b0;
        wlast_o             =   1'b0;

        bready_o            =   1'b0;

        clean_done_o        =   1'b0;

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

        exc_valid_o         =   1'b0;

        flush               =   flush_ff || flushM_i;
        exc                 =   rvalid_i && ((rresp_i != 2'b00) || (rid_i != ID_LSU) || (rlast_i ^ (beat_cnt == 3'd7)));

        case (state)
            DC_RUN: begin
                data_wr_en      =   hit_1h & {8{hit & lsu_ready_i & (lsM == DC_STORE)}};
                data_wr_addr    =   data_indexM;
                data_wr_data    =   store_data;

                tag_rd_en       =   !miss && lsu_ready_i;
                tag_rd_addr     =   index;
                data_rd_en      =   !miss && lsu_ready_i;
                data_rd_addr    =   data_index;
                
                dc_rvalid_o     =   hit;
                dc_ready_o      =   !miss && lsu_ready_i;
                dc_ldata_o      =   load_data_eff;
            end
            DC_WRITEBACK_REQ: begin
                data_rd_en      =   awready_i;
                data_rd_addr    =   {indexM, 3'b000};

                awaddr_o        =   {victim_tag, indexM, 6'b0};
                awvalid_o       =   1'b1;
                awsize_o        =   SIZE_8B;
                awlen_o         =   8'd7;
                awburst_o       =   INCR;
                awlock_o        =   1'b0;
                awid_o          =   ID_LSU;
                awcache_o       =   CACHE_WB_RALLOC;
                awprot_o        =   PROT_LSU;
                awqos_o         =   4'b0000;
            end
            DC_WRITEBACK: begin
                data_rd_en      =   wready_i;
                data_rd_addr    =   {indexM, prefetch_cnt};
                        
                wdata_o         =   data_rd[way_fill_q];
                wstrb_o         =   8'hFF;
                wvalid_o        =   1'b1;
                wlast_o         =   (beat_cnt == 3'd7);
            end
            DC_WRITEBACK_DONE: begin
                bready_o        =   1'b1;                
            end
            DC_REFILL_REQ: begin
                araddr_o        =   {addrM[63:6], 6'b0};
                arvalid_o       =   1'b1;
                arlen_o         =   8'd7;
                arsize_o        =   SIZE_8B;
                arburst_o       =   INCR;
                arlock_o        =   1'b0;
                arid_o          =   ID_LSU;
                arcache_o       =   CACHE_WB_RALLOC;
                arprot_o        =   PROT_LSU;
                arqos_o         =   4'b0000;
            end
            DC_REFILL: begin
                data_wr_en[way_fill_q]  =   rvalid_i;
                data_wr_addr            =   {indexM, beat_cnt};
                data_wr_data            =   refill_data_eff;

                tag_wr_en[way_fill_q]   =   rvalid_i && ((beat_cnt == 3'd7) || rlast_i);
                tag_wr_addr             =   indexM;
                tag_wr_data             =   tagM;

                rready_o                =   1'b1;
            end
            DC_REFILL_DONE: begin
                tag_rd_en       =   flush || lsu_ready_i;
                tag_rd_addr     =   index;
                data_rd_en      =   flush || lsu_ready_i;
                data_rd_addr    =   data_index;
                
                dc_rvalid_o     =   !flush;
                dc_ldata_o      =   data_hold;
                dc_ready_o      =   lsu_ready_i || flush;

                exc_valid_o     =   exc_ff && !flush;
            end
            DC_CLEAN: begin
                tag_rd_en       =   !flushM_i && !way_clean_done;
                tag_rd_addr     =   clean_line;

                clean_done_o    =   (cur_way == 3'd7) && way_clean_done;
            end
            DC_CLEAN_WRITEBACK_REQ: begin
                data_rd_en      =   awready_i;
                data_rd_addr    =   {clean_line, 3'b000};

                awaddr_o        =   {tag_rd[cur_way], clean_line, 6'b0};
                awvalid_o       =   1'b1;
                awsize_o        =   SIZE_8B;
                awlen_o         =   8'd7;
                awburst_o       =   INCR;
                awlock_o        =   1'b0;
                awid_o          =   ID_LSU;
                awcache_o       =   CACHE_WB_RALLOC;
                awprot_o        =   PROT_LSU;
                awqos_o         =   4'b0000;
            end
            DC_CLEAN_WRITEBACK: begin
                data_rd_en      =   wready_i;
                data_rd_addr    =   {clean_line, prefetch_cnt};        
                        
                wdata_o         =   data_rd[cur_way];
                wstrb_o         =   8'hFF;
                wvalid_o        =   1'b1;
                wlast_o         =   (beat_cnt == 3'd7);
            end
            DC_CLEAN_WRITEBACK_DONE: begin
                bready_o    =   1'b1;
            end
        endcase
    end

endmodule