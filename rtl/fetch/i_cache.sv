import cpu_defines::*;
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

    logic [51:0]    tag;
    logic [51:0]    tag_q;
    logic [5:0]     index;
    logic [5:0]     index_q;
    logic [3:0]     offset;
    logic [8:0]     data_index;
    logic           data_sel;

    logic [7:0]     hit_1h;
    logic           hit_raw;
    logic           hit;
    logic           miss;

    logic           flush;
    logic           invalidate;

    logic [6:0]     PLRU_rd_set;
    logic [6:0]     nxt_PLRU_set;
    logic [2:0]     way_fill_PLRU;
    logic [2:0]     way_fill_invalid;
    logic           way_fill_replace;
    logic [2:0]     nxt_way_fill;

    logic [31:0]    instr_hold;
    logic [2:0]     beat_cnt;
    logic [2:0]     way_fill_q;

    logic           flush_ff;
    logic           invalidate_ff;
    logic           exc_ff;

    logic [6:0]     PLRU_tree [63:0];

    logic [63:0]    pc_q;

    ic_state_t      state;

    logic [51:0]    tag_rd_w0;
    logic [51:0]    tag_rd_w1;
    logic [51:0]    tag_rd_w2;
    logic [51:0]    tag_rd_w3;
    logic [51:0]    tag_rd_w4;
    logic [51:0]    tag_rd_w5;
    logic [51:0]    tag_rd_w6;
    logic [51:0]    tag_rd_w7;
    
    logic [63:0]    data_rd_w0;
    logic [63:0]    data_rd_w1;
    logic [63:0]    data_rd_w2;
    logic [63:0]    data_rd_w3;
    logic [63:0]    data_rd_w4;
    logic [63:0]    data_rd_w5;
    logic [63:0]    data_rd_w6;
    logic [63:0]    data_rd_w7;

    logic [63:0]    valid_w0;
    logic [63:0]    valid_w1;
    logic [63:0]    valid_w2;
    logic [63:0]    valid_w3;
    logic [63:0]    valid_w4;
    logic [63:0]    valid_w5;
    logic [63:0]    valid_w6;
    logic [63:0]    valid_w7;

    logic [51:0]    tags_w0 [63:0];
    logic [51:0]    tags_w1 [63:0];
    logic [51:0]    tags_w2 [63:0];
    logic [51:0]    tags_w3 [63:0];
    logic [51:0]    tags_w4 [63:0];
    logic [51:0]    tags_w5 [63:0];
    logic [51:0]    tags_w6 [63:0];
    logic [51:0]    tags_w7 [63:0];

    (* ram_style = "block" *) logic [63:0] data_w0 [511:0];
    (* ram_style = "block" *) logic [63:0] data_w1 [511:0];
    (* ram_style = "block" *) logic [63:0] data_w2 [511:0];
    (* ram_style = "block" *) logic [63:0] data_w3 [511:0];
    (* ram_style = "block" *) logic [63:0] data_w4 [511:0];
    (* ram_style = "block" *) logic [63:0] data_w5 [511:0];
    (* ram_style = "block" *) logic [63:0] data_w6 [511:0];
    (* ram_style = "block" *) logic [63:0] data_w7 [511:0];

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            flush_ff        <=  1'b0;
            invalidate_ff   <=  1'b0;
            exc_ff          <=  1'b0;

            beat_cnt        <=  3'd0;
            way_fill_q      <=  3'b0;
            instr_hold      <=  32'h0;

            pc_q            <=  64'h0;

            valid_w0        <=  64'h0;
            valid_w1        <=  64'h0;
            valid_w2        <=  64'h0;
            valid_w3        <=  64'h0;
            valid_w4        <=  64'h0;
            valid_w5        <=  64'h0;
            valid_w6        <=  64'h0;
            valid_w7        <=  64'h0;

            tag_rd_w0       <=  52'h0;
            tag_rd_w1       <=  52'h0;
            tag_rd_w2       <=  52'h0;
            tag_rd_w3       <=  52'h0;
            tag_rd_w4       <=  52'h0;
            tag_rd_w5       <=  52'h0;
            tag_rd_w6       <=  52'h0;
            tag_rd_w7       <=  52'h0;

            data_rd_w0      <=  64'h0;
            data_rd_w1      <=  64'h0;
            data_rd_w2      <=  64'h0;
            data_rd_w3      <=  64'h0;
            data_rd_w4      <=  64'h0;
            data_rd_w5      <=  64'h0;
            data_rd_w6      <=  64'h0;
            data_rd_w7      <=  64'h0;

            state           <=  IC_RUN;
        end else begin
            case (state) 
                IC_RUN: begin
                    if (!(miss && !stop_fillline_i) && ifu_ready_i) begin

                        if (hit) 
                            PLRU_tree[index_q]  <=  nxt_PLRU_set;

                        tag_rd_w0   <=  tags_w0[index];
                        tag_rd_w1   <=  tags_w1[index];
                        tag_rd_w2   <=  tags_w2[index];
                        tag_rd_w3   <=  tags_w3[index];
                        tag_rd_w4   <=  tags_w4[index];
                        tag_rd_w5   <=  tags_w5[index];
                        tag_rd_w6   <=  tags_w6[index];
                        tag_rd_w7   <=  tags_w7[index];

                        data_rd_w0  <=  data_w0[data_index];
                        data_rd_w1  <=  data_w1[data_index];
                        data_rd_w2  <=  data_w2[data_index];
                        data_rd_w3  <=  data_w3[data_index];
                        data_rd_w4  <=  data_w4[data_index];
                        data_rd_w5  <=  data_w5[data_index];
                        data_rd_w6  <=  data_w6[data_index];
                        data_rd_w7  <=  data_w7[data_index];

                        pc_q        <=  pc_i;
                    end else if (miss && !stop_fillline_i) begin
                        way_fill_q  <=  nxt_way_fill;

                        case (nxt_way_fill)
                            3'b000: valid_w0[index_q]   <=  1'b0;
                            3'b001: valid_w1[index_q]   <=  1'b0;
                            3'b010: valid_w2[index_q]   <=  1'b0;
                            3'b011: valid_w3[index_q]   <=  1'b0;
                            3'b100: valid_w4[index_q]   <=  1'b0;
                            3'b101: valid_w5[index_q]   <=  1'b0;
                            3'b110: valid_w6[index_q]   <=  1'b0;
                            3'b111: valid_w7[index_q]   <=  1'b0;
                        endcase

                        state       <=  IC_REFILL_REQ;
                    end

                    if (invalidate_i) begin
                        valid_w0    <=  64'h0;
                        valid_w1    <=  64'h0;
                        valid_w2    <=  64'h0;
                        valid_w3    <=  64'h0;
                        valid_w4    <=  64'h0;
                        valid_w5    <=  64'h0;
                        valid_w6    <=  64'h0;
                        valid_w7    <=  64'h0;
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
                        if (offset[3:1] == beat_cnt)
                            instr_hold  <=  offset[0] ? rdata_i[63:32] : rdata_i[31:0];

                        case (way_fill_q)
                            3'b000: data_w0[{index_q, beat_cnt}]    <=  rdata_i;
                            3'b001: data_w1[{index_q, beat_cnt}]    <=  rdata_i;
                            3'b010: data_w2[{index_q, beat_cnt}]    <=  rdata_i;
                            3'b011: data_w3[{index_q, beat_cnt}]    <=  rdata_i;
                            3'b100: data_w4[{index_q, beat_cnt}]    <=  rdata_i;
                            3'b101: data_w5[{index_q, beat_cnt}]    <=  rdata_i;
                            3'b110: data_w6[{index_q, beat_cnt}]    <=  rdata_i;
                            3'b111: data_w7[{index_q, beat_cnt}]    <=  rdata_i;
                        endcase

                        exc_ff <= exc_ff || (rresp_i != 2'b00) || (rid_i != ID_IFU) || (rlast_i ^ (beat_cnt == 3'd7));

                        if (rlast_i) begin
                            beat_cnt    <=  3'd0;

                            case (way_fill_q)
                                3'b000: tags_w0[index_q]    <= tag_q;
                                3'b001: tags_w1[index_q]    <= tag_q;
                                3'b010: tags_w2[index_q]    <= tag_q;
                                3'b011: tags_w3[index_q]    <= tag_q;
                                3'b100: tags_w4[index_q]    <= tag_q;
                                3'b101: tags_w5[index_q]    <= tag_q;
                                3'b110: tags_w6[index_q]    <= tag_q;
                                3'b111: tags_w7[index_q]    <= tag_q;
                            endcase

                            state       <=  IC_REFILL_DONE;
                        end else begin
                            beat_cnt    <=  beat_cnt + 3'd1;
                        end
                    end
                end
                IC_REFILL_DONE: begin
                    if (invalidate) begin
                        valid_w0        <=  64'h0;
                        valid_w1        <=  64'h0;
                        valid_w2        <=  64'h0;
                        valid_w3        <=  64'h0;
                        valid_w4        <=  64'h0;
                        valid_w5        <=  64'h0;
                        valid_w6        <=  64'h0;
                        valid_w7        <=  64'h0;

                        instr_hold      <=  32'h0;

                        invalidate_ff   <=  1'b0;
                        flush_ff        <=  1'b0;
                        exc_ff          <=  1'b0;

                        state           <=  IC_RUN;
                    end else if (flush) begin
                        instr_hold      <=  32'h0;

                        case (way_fill_q)
                            3'b000: valid_w0[index_q]   <=  !exc_ff;
                            3'b001: valid_w1[index_q]   <=  !exc_ff;
                            3'b010: valid_w2[index_q]   <=  !exc_ff;
                            3'b011: valid_w3[index_q]   <=  !exc_ff;
                            3'b100: valid_w4[index_q]   <=  !exc_ff;
                            3'b101: valid_w5[index_q]   <=  !exc_ff;
                            3'b110: valid_w6[index_q]   <=  !exc_ff;
                            3'b111: valid_w7[index_q]   <=  !exc_ff;
                        endcase
                        
                        if (!exc_ff)
                            PLRU_tree[index_q]          <= nxt_PLRU_set;

                        invalidate_ff   <=  1'b0;
                        flush_ff        <=  1'b0;
                        exc_ff          <=  1'b0;

                        state           <=  IC_RUN;
                    end else begin
                        if (ifu_ready_i) begin
                            if (!exc_ff) begin
                                case (way_fill_q) 
                                    3'b000: valid_w0[index_q]   <=  1'b1;
                                    3'b001: valid_w1[index_q]   <=  1'b1;
                                    3'b010: valid_w2[index_q]   <=  1'b1;
                                    3'b011: valid_w3[index_q]   <=  1'b1;
                                    3'b100: valid_w4[index_q]   <=  1'b1;
                                    3'b101: valid_w5[index_q]   <=  1'b1;
                                    3'b110: valid_w6[index_q]   <=  1'b1;
                                    3'b111: valid_w7[index_q]   <=  1'b1;
                                endcase

                                PLRU_tree[index_q]              <= nxt_PLRU_set;
                            end

                            instr_hold      <=  32'h0;

                            invalidate_ff   <=  1'b0;
                            flush_ff        <=  1'b0;
                            exc_ff          <=  1'b0;

                            state           <=  IC_RUN;
                        end
                    end

                    if (invalidate || flush || ifu_ready_i) begin
                        tag_rd_w0   <=  tags_w0[index];
                        tag_rd_w1   <=  tags_w1[index];
                        tag_rd_w2   <=  tags_w2[index];
                        tag_rd_w3   <=  tags_w3[index];
                        tag_rd_w4   <=  tags_w4[index];
                        tag_rd_w5   <=  tags_w5[index];
                        tag_rd_w6   <=  tags_w6[index];
                        tag_rd_w7   <=  tags_w7[index];

                        data_rd_w0  <=  data_w0[data_index];
                        data_rd_w1  <=  data_w1[data_index];
                        data_rd_w2  <=  data_w2[data_index];
                        data_rd_w3  <=  data_w3[data_index];
                        data_rd_w4  <=  data_w4[data_index];
                        data_rd_w5  <=  data_w5[data_index];
                        data_rd_w6  <=  data_w6[data_index];
                        data_rd_w7  <=  data_w7[data_index];

                        pc_q        <=  pc_i;
                    end
                end
            endcase
        end
    end

    always_comb begin
        ic_ready_o          =   1'b0;
        instr_valid_o       =   1'b0;
        instr_o             =   32'h0;
        pcF_o               =   pc_q;

        invalidate_done_o   =   1'b0;

        exc_valid_o         =   1'b0;
        exc_code_o          =   5'h0;

        arvalid_o           =   1'b0;
        arid_o              =   ID_IFU;
        araddr_o            =   {pc_q[63:6], 6'b0};
        arlen_o             =   8'd7;
        arsize_o            =   SIZE_8B;
        arburst_o           =   INCR;
        arlock_o            =   1'b0;
        arcache_o           =   CACHE_WB_RALLOC;
        arprot_o            =   PROT_IFU;
        arqos_o             =   4'b0000;

        rready_o            =   1'b0;

        tag                 =   pc_i[63:12];
        tag_q               =   pc_q[63:12];
        index               =   pc_i[11:6];
        index_q             =   pc_q[11:6];
        offset              =   pc_i[5:2];
        data_index          =   pc_i[11:3];
        data_sel            =   pc_q[2];

        hit_1h              =   8'b0;
        hit_raw             =   1'b0;
        hit                 =   1'b0;
        miss                =   1'b0;

        flush               =   flush_ff || flush_i;
        invalidate          =   invalidate_ff || invalidate_i;

        PLRU_rd_set         =   PLRU_tree[index_q];
        nxt_PLRU_set        =   PLRU_rd_set;
        way_fill_PLRU       =   3'd0;
        way_fill_invalid    =   3'd0;
        way_fill_replace    =   3'd0;
        nxt_way_fill        =   3'd0;

        case (state)
            IC_RUN: begin
                invalidate_done_o   =   invalidate_i;

                tag                 =   pc_i[63:12];
                index               =   pc_i[11:6];
                offset              =   pc_i[5:2];

                data_index          =   pc_i[11:3];

                data_sel            =   pc_q[2];

                tag_q               =   pc_q[63:12];
                index_q             =   pc_q[11:6];

                hit_1h[0]           =   valid_w0[index_q] && (tag_q == tag_rd_w0);
                hit_1h[1]           =   valid_w1[index_q] && (tag_q == tag_rd_w1);
                hit_1h[2]           =   valid_w2[index_q] && (tag_q == tag_rd_w2);
                hit_1h[3]           =   valid_w3[index_q] && (tag_q == tag_rd_w3);
                hit_1h[4]           =   valid_w4[index_q] && (tag_q == tag_rd_w4);
                hit_1h[5]           =   valid_w5[index_q] && (tag_q == tag_rd_w5);
                hit_1h[6]           =   valid_w6[index_q] && (tag_q == tag_rd_w6);
                hit_1h[7]           =   valid_w7[index_q] && (tag_q == tag_rd_w7);

                hit_raw             =   |hit_1h;
                hit                 =   hit_raw && !flush_i && !invalidate_i && resetn_q_i;
                miss                =   !hit_raw && !flush_i && !invalidate_i && resetn_q_i;

                instr_valid_o       =   hit && !stop_fillline_i;

                ic_ready_o          =   !(miss && !stop_fillline_i) && ifu_ready_i;

                case (hit_1h)
                    8'b0000_0001: instr_o   =   data_sel ? data_rd_w0[63:32] : data_rd_w0[31:0];
                    8'b0000_0010: instr_o   =   data_sel ? data_rd_w1[63:32] : data_rd_w1[31:0];
                    8'b0000_0100: instr_o   =   data_sel ? data_rd_w2[63:32] : data_rd_w2[31:0];
                    8'b0000_1000: instr_o   =   data_sel ? data_rd_w3[63:32] : data_rd_w3[31:0];
                    8'b0001_0000: instr_o   =   data_sel ? data_rd_w4[63:32] : data_rd_w4[31:0];
                    8'b0010_0000: instr_o   =   data_sel ? data_rd_w5[63:32] : data_rd_w5[31:0];
                    8'b0100_0000: instr_o   =   data_sel ? data_rd_w6[63:32] : data_rd_w6[31:0];
                    8'b1000_0000: instr_o   =   data_sel ? data_rd_w7[63:32] : data_rd_w7[31:0];
                    default: instr_o        =   32'h0;
                endcase

                PLRU_rd_set         =   PLRU_tree[index_q];

                case (hit_1h)
                    8'b0000_0001: nxt_PLRU_set  =   PLRU_rd_set | 7'b1101000;
                    8'b0000_0010: nxt_PLRU_set  =   (PLRU_rd_set | 7'b1100000) & 7'b1110111;
                    8'b0000_0100: nxt_PLRU_set  =   (PLRU_rd_set | 7'b1000100) & 7'b1011111;
                    8'b0000_1000: nxt_PLRU_set  =   (PLRU_rd_set | 7'b1000000) & 7'b1011011;
                    8'b0001_0000: nxt_PLRU_set  =   (PLRU_rd_set | 7'b0010010) & 7'b0111111;
                    8'b0010_0000: nxt_PLRU_set  =   (PLRU_rd_set | 7'b0010000) & 7'b0111101;
                    8'b0100_0000: nxt_PLRU_set  =   (PLRU_rd_set | 7'b0000001) & 7'b0101111;
                    8'b1000_0000: nxt_PLRU_set  =   (PLRU_rd_set | 7'b0000000) & 7'b0101110;
                    default: nxt_PLRU_set       =   PLRU_rd_set;
                endcase

                way_fill_replace    =   valid_w0[index_q] && valid_w1[index_q] && valid_w2[index_q] && valid_w3[index_q] &&
                                        valid_w4[index_q] && valid_w5[index_q] && valid_w6[index_q] && valid_w7[index_q];

                way_fill_invalid    =   ~valid_w0[index_q] ? 3'd0 : 
                                        (~valid_w1[index_q] ? 3'd1 : 
                                        (~valid_w2[index_q] ? 3'd2 : 
                                        (~valid_w3[index_q] ? 3'd3 : 
                                        (~valid_w4[index_q] ? 3'd4 : 
                                        (~valid_w5[index_q] ? 3'd5 : 
                                        (~valid_w6[index_q] ? 3'd6 : 
                                        (~valid_w7[index_q] ? 3'd7 : 3'd0)))))));

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

                nxt_way_fill    =   way_fill_replace ? way_fill_PLRU : way_fill_invalid;
            end
            IC_REFILL_REQ: begin
                araddr_o    =   {pc_q[63:6], 6'b0};
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
                offset      =   pc_q[5:2];
                index_q     =   pc_q[11:6];
                tag_q       =   pc_q[63:12];

                rready_o    =   1'b1;
            end
            IC_REFILL_DONE: begin
                flush                   =   flush_ff || flush_i;
                invalidate              =   invalidate_ff || invalidate_i;

                invalidate_done_o       =   invalidate;

                index_q                 =   pc_q[11:6];
                index                   =   pc_i[11:6];
                data_index              =   pc_i[11:3];

                ic_ready_o              =   flush || invalidate || ifu_ready_i;

                if (!(flush || invalidate)) begin
                    instr_o             =   instr_hold;
                    instr_valid_o       =   1'b1;

                    exc_valid_o         =   exc_ff;
                    exc_code_o          =   I_ACC_FAULT;
                end

                PLRU_rd_set             =   PLRU_tree[index_q];

                case (way_fill_q)
                    3'b000: nxt_PLRU_set    =   PLRU_rd_set | 7'b1101000;
                    3'b001: nxt_PLRU_set    =   (PLRU_rd_set | 7'b1100000) & 7'b1110111;
                    3'b010: nxt_PLRU_set    =   (PLRU_rd_set | 7'b1000100) & 7'b1011111;
                    3'b011: nxt_PLRU_set    =   (PLRU_rd_set | 7'b1000000) & 7'b1011011;
                    3'b100: nxt_PLRU_set    =   (PLRU_rd_set | 7'b0010010) & 7'b0111111;
                    3'b101: nxt_PLRU_set    =   (PLRU_rd_set | 7'b0010000) & 7'b0111101;
                    3'b110: nxt_PLRU_set    =   (PLRU_rd_set | 7'b0000001) & 7'b0101111;
                    3'b111: nxt_PLRU_set    =   (PLRU_rd_set | 7'b0000000) & 7'b0101110;
                    default: nxt_PLRU_set   =   PLRU_rd_set;
                endcase
            end
        endcase
    end

endmodule