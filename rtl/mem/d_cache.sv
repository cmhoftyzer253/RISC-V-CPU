import cpu_consts::*;

module d_cache (
    parameter int ID_W = 1;
)(
    input logic clk,
    input logic resetn,

    //memory module request interface
    input logic                 data_mem_req_i,
    input logic [63:0]          data_mem_addr_i,
    input logic                 data_mem_wr_i,
    input logic [63:0]          data_mem_wr_data_i,
    input logic [7:0]           data_mem_mask_i,
    output logic                data_mem_ready_o,

    //memory module response interface
    input logic                 req_rd_ready_i,
    output logic                req_resp_valid_o,
    output logic [63:0]         req_rd_data_o,

    //AXI Interface to DDR3 main memory
    // load request
    input logic                 arready_i,
    output logic [63:0]         araddr_o,               //Byte address for read request  
    output logic [7:0]          arlen_o,                //burst length minus 1 (keep at 0 = 1 beat)
    output logic [2:0]          arsize_o,               //log2 of number of bytes per beat 0=1byte, 1=2byte, 2=4byte, 3=8byte
    output logic [1:0]          arburst_o,              // burst type
    output logic [ID_W-1:0]     arid_o,                 //
    output logic [2:0]          arprot_o,               //
    output logic                arvalid_o,              //read address is valid

    // load response
    input logic                 rvalid_i,               //asserted when rdata is valid
    input logic [127:0]         rdata_i,                //data from memory
    input logic [1:0]           rresp_i,                //response code (00 = OKAY, otherwise error)
    input logic                 rlast_i,                //last beat of burst 
    input logic [ID_W-1:0]      rid_i,
    output logic                rready_o,               //assert when ready to accept rdata

    // store request
    input logic                 awready_i,
    input logic                 wready_i,
    output logic [63:0]         awaddr_o,               //Byte address for write request
    output logic                awvalid_o,              //write address is valid
    output logic [2:0]          awsize_o,               //log2 of number of bytes per beat 0=1byte, 1=2byte, 2=4byte, 3=8byte
    output logic [7:0]          awlen_o,                //burst length minus 1 (keep at 0 = 1 beat)
    output logic [1:0]          awburst_o,              //burst type 
    output logic [ID_W-1:0]     awid_o,
    output logic [127:0]        wdata_o,                //data to be written
    output logic [15:0]         wstrb_o,                //byte write strobes
    output logic                wvalid_o,               //asserted when wdata valid
    output logic                wlast_o,                //last beat of burst (single beat - always 1 when wvalid = 1)

    // store response
    input logic [1:0]           bresp_i,                //response code (00 = OKAY, otherwise error)
    input logic                 bvalid_i,               //write response is avilable
    input logic [ID_W-1:0]      bid_i,
    output logic                bready_o,               //assert when ready to accept response

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o
);

    logic req_handshake;
    logic req_handshake_ff;

    logic [63:0]    data_mem_addr_ff;
    logic           data_mem_wr_ff;
    logic [63:0]    data_mem_wr_data_ff;
    logic [7:0]     data_mem_mask_ff;

    logic [50:0]    data_tag;
    logic [50:0]    data_tag_ff;
    logic [50:0]    victim_tag;

    logic [6:0]     tag_index;
    logic [6:0]     tag_index_ff;

    logic [6:0]     data_line;
    logic [2:0]     data_offset;
    logic [9:0]     data_index;
    logic [9:0]     data_index_ff;

    logic [3:0]     hit_1h;

    logic           data_hit;
    logic           cache_miss;

    logic [63:0]    fetch_data;
    logic [63:0]    store_data
    logic [63:0]    data_hold;

    logic [2:0]     PLRU_tree_q;
    logic [2:0]     nxt_PLRU_tree;

    logic [1:0]     way_fill_q;
    logic [1:0]     nxt_way_fill;

    logic           way_dirty;
    logic           wb_dirty;

    logic           way_fill_replace;

    logic [1:0]     way_fill_invalid;
    logic [1:0]     way_fill_PLRU;

    logic [63:0]    wb_lower;
    logic [63:0]    wb_upper;

    logic           bypass_reg_wr;
    logic           bypass_active;

    logic [63:0]    bypass_data;

    logic           error_ff;
    logic           id_error;

    logic [63:0]    data_rd_w0;
    logic [63:0]    data_rd_w1;
    logic [63:0]    data_rd_w2;
    logic [63:0]    data_rd_w3;
    
    d_cache_tag_t tags_w0 [127:0];
    d_cache_tag_t tags_w1 [127:0];
    d_cache_tag_t tags_w2 [127:0];
    d_cache_tag_t tags_w3 [127:0];

    d_cache_state_t             state;

    (* ram_style = "block" *) logic [63:0] data_w0 [1023:0];
    (* ram_style = "block" *) logic [63:0] data_w1 [1023:0];
    (* ram_style = "block" *) logic [63:0] data_w2 [1023:0];
    (* ram_style = "block" *) logic [63:0] data_w3 [1023:0];

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            req_handshake_ff                    <= 1'b0;

            data_mem_addr_ff                    <= 64'h0;
            data_mem_wr_ff                      <= 1'b0;
            data_mem_wr_data_ff                 <= 64'h0;
            data_mem_mask_ff                    <= 8'b0;

            tag_rd_w0                           <= '0;
            tag_rd_w1                           <= '0;
            tag_rd_w2                           <= '0;
            tag_rd_w3                           <= '0;

            data_rd_w0                          <= 64'h0;
            data_rd_w1                          <= 64'h0;
            data_rd_w2                          <= 64'h0;
            data_rd_w3                          <= 64'h0;

            PLRU_tree_q                         <= 3'b000;
            way_fill_q                          <= 2'b00;

            wb_lower                            <= 64'h0;
            wb_upper                            <= 64'h0;

            bypass_active                       <= 1'b0;
            bypass_data                         <= 64'h0;

            data_hold                           <= 64'h0;

            error_ff                            <= 1'b0;
            id_error                            <= 1'b0;

            for (i=0; i<128; i++) begin
                tags_w0[i].valid                <= 1'b0;
                tags_w1[i].valid                <= 1'b0;
                tags_w2[i].valid                <= 1'b0;
                tags_w3[i].valid                <= 1'b0;

                tags_w0[i].dirty                <= 1'b0;
                tags_w1[i].dirty                <= 1'b0;
                tags_w2[i].dirty                <= 1'b0;
                tags_w3[i].dirty                <= 1'b0;

                tags_w0[i].tag                  <= '0;
                tags_w1[i].tag                  <= '0;
                tags_w2[i].tag                  <= '0;
                tags_w3[i].tag                  <= '0;
            end

            state                               <= S_RUN;
        end else begin
            case (state)
                S_RUN: begin
                    req_handshake_ff            <= req_handshake;

                    if (data_hit) begin
                        if (data_mem_wr_ff) begin
                            case (hit_1h)
                                4'b0001: begin
                                    data_w0[data_index_ff]          <= store_data;
                                    tags_w0[tag_index_ff].dirty     <= 1'b1;
                                end
                                4'b0010: begin
                                    data_w1[data_index_ff]          <= store_data;
                                    tags_w1[tag_index_ff].dirty     <= 1'b1;
                                end 
                                4'b0100: begin
                                    data_w2[data_index_ff]          <= store_data;
                                    tags_w2[tag_index_ff].dirty     <= 1'b1;
                                end
                                4'b1000: begin
                                    data_w3[data_index_ff]          <= store_data;
                                    tags_w3[tag_index_ff].dirty     <= 1'b1;
                                end
                            endcase

                            if (bypass_reg_wr) begin
                                bypass_data     <= store_data;
                            end 
                        end 

                        PLRU_tree_q             <= nxt_PLRU_tree;
                    end 

                    if (req_handshake) begin
                        tag_rd_w0               <= tags_w0[tag_index];
                        tag_rd_w1               <= tags_w1[tag_index];
                        tag_rd_w2               <= tags_w2[tag_index];
                        tag_rd_w3               <= tags_w3[tag_index];

                        data_rd_w0              <= data_w0[data_index];
                        data_rd_w1              <= data_w1[data_index];
                        data_rd_w2              <= data_w2[data_index];
                        data_rd_w3              <= data_w3[data_index];

                        data_mem_addr_ff        <= data_mem_addr_i;
                        data_mem_wr_ff          <= data_mem_wr_i;
                        data_mem_wr_data_ff     <= data_mem_wr_data_i;
                        data_mem_mask_ff        <= data_mem_mask_i;

                        bypass_active           <= bypass_reg_wr;
                    end else begin
                        bypass_active           <= 1'b0;
                    end              

                    if (cache_miss) begin
                        way_fill_q              <= nxt_way_fill;

                        data_hold               <= 64'h0;

                        if (wb_dirty) begin
                            state               <= S_STORE_AW_WAIT;
                        end else begin
                            state               <= S_LOAD_REQUEST;
                        end
                    end
                end
                S_STORE_AW_WAIT: begin
                    if (awready_i) begin
                        case (way_fill_q)
                            2'b00: begin
                                wb_lower        <= data_w0[{tag_index_ff, 3'b000}];
                                wb_upper        <= data_w0[{tag_index_ff, 3'b001}];
                            end
                            2'b01: begin
                                wb_lower        <= data_w1[{tag_index_ff, 3'b000}];
                                wb_upper        <= data_w1[{tag_index_ff, 3'b001}];
                            end
                            2'b10: begin
                                wb_lower        <= data_w2[{tag_index_ff, 3'b000}];
                                wb_upper        <= data_w2[{tag_index_ff, 3'b001}];
                            end
                            2'b11: begin
                                wb_lower        <= data_w3[{tag_index_ff, 3'b000}];
                                wb_upper        <= data_w3[{tag_index_ff, 3'b001}];
                            end
                        endcase

                        state                   <= S_STORE_1;
                    end
                end
                S_STORE_1: begin
                    if (wready_i) begin
                        case (way_fill_q)
                            2'b00: begin
                                wb_lower        <= data_w0[{tag_index_ff, 3'b010}];
                                wb_upper        <= data_w0[{tag_index_ff, 3'b011}];
                            end
                            2'b01: begin
                                wb_lower        <= data_w1[{tag_index_ff, 3'b010}];
                                wb_upper        <= data_w1[{tag_index_ff, 3'b011}];
                            end
                            2'b10: begin
                                wb_lower        <= data_w2[{tag_index_ff, 3'b010}];
                                wb_upper        <= data_w2[{tag_index_ff, 3'b011}];
                            end 
                            2'b11: begin
                                wb_lower        <= data_w3[{tag_index_ff, 3'b010}];
                                wb_upper        <= data_w3[{tag_index_ff, 3'b011}];
                            end
                        endcase

                        state                   <= S_STORE_2;
                    end
                end
                S_STORE_2: begin
                    if (wready_i) begin
                        case (way_fill_q)
                            2'b00: begin
                                wb_lower        <= data_w0[{tag_index_ff, 3'b100}];
                                wb_upper        <= data_w0[{tag_index_ff, 3'b101}];
                            end
                            2'b01: begin
                                wb_lower        <= data_w1[{tag_index_ff, 3'b100}];
                                wb_upper        <= data_w1[{tag_index_ff, 3'b101}];
                            end
                            2'b10: begin
                                wb_lower        <= data_w2[{tag_index_ff, 3'b100}];
                                wb_upper        <= data_w2[{tag_index_ff, 3'b101}];
                            end
                            2'b11: begin
                                wb_lower        <= data_w3[{tag_index_ff, 3'b100}];
                                wb_upper        <= data_w3[{tag_index_ff, 3'b101}];
                            end
                        endcase

                        state                   <= S_STORE_3;
                    end
                end
                S_STORE_3: begin
                    if (wready_i) begin
                        case(way_fill_q)
                            2'b00: begin
                                wb_lower        <= data_w0[{tag_index_ff, 3'b110}];
                                wb_upper        <= data_w0[{tag_index_ff, 3'b111}];
                            end
                            2'b01: begin
                                wb_lower        <= data_w1[{tag_index_ff, 3'b110}];
                                wb_upper        <= data_w1[{tag_index_ff, 3'b111}];
                            end
                            2'b10: begin
                                wb_lower        <= data_w2[{tag_index_ff, 3'b110}];
                                wb_upper        <= data_w2[{tag_index_ff, 3'b111}];
                            end
                            2'b11: begin
                                wb_lower        <= data_w3[{tag_index_ff, 3'b110}];
                                wb_upper        <= data_w3[{tag_index_ff, 3'b111}];
                            end
                        endcase

                        state                   <= S_STORE_4;
                    end
                end
                S_STORE_4: begin
                    if (wready_i) begin
                        state                   <= S_STORE_DONE;
                    end
                end
                S_STORE_DONE: begin
                    if (bvalid_i) begin
                        state                   <= S_LOAD_REQUEST;
                    end
                end
                S_LOAD_REQUEST: begin
                    if (arready_i) begin
                        state                   <= S_LOAD_1;
                    end
                end
                S_LOAD_1: begin
                    if (rvalid_i) begin
                        case (data_offset)
                            3'b000: data_hold   <= rdata_i[63:0];
                            3'b001: data_hold   <= rdata_i[127:64];
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 3'b000}]    <= rdata_i[63:0];
                            data_w0[{data_line, 3'b001}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 3'b000}]    <= rdata_i[63:0];
                            data_w1[{data_line, 3'b001}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 3'b000}]    <= rdata_i[63:0];
                            data_w2[{data_line, 3'b001}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 3'b000}]    <= rdata_i[63:0];
                            data_w3[{data_line, 3'b001}]    <= rdata_i[127:64];
                        end

                        error_ff                <= (rresp_i != 2'b00);
                        id_error                <= (rid_i != '0);

                        state                   <= S_LOAD_2;
                    end
                end
                S_LOAD_2: begin
                    if (rvalid_i) begin
                        case (data_offset)
                            3'b010: data_hold   <= rdata_i[63:0];
                            3'b011: data_hold   <= rdata_i[127:64];
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 3'b010}]    <= rdata_i[63:0];
                            data_w0[{data_line, 3'b011}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 3'b010}]    <= rdata_i[63:0];
                            data_w1[{data_line, 3'b011}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 3'b010}]    <= rdata_i[63:0];
                            data_w2[{data_line, 3'b011}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 3'b010}]    <= rdata_i[63:0];
                            data_w3[{data_line, 3'b011}]    <= rdata_i[127:64];
                        end

                        error_ff                <= error_ff | (rresp_i != 2'b00);
                        id_error                <= id_error | (rid_i != '0);

                        state                   <= S_LOAD_3;
                    end
                end
                S_LOAD_3: begin
                    if (rvalid_i) begin
                        case (data_offset) 
                            3'b100: data_hold   <= rdata_i[63:0];
                            3'b101: data_hold   <= rdata_i[127:64];
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 3'b100}]    <= rdata_i[63:0];
                            data_w0[{data_line, 3'b101}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 3'b100}]    <= rdata_i[63:0];
                            data_w1[{data_line, 3'b101}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 3'b100}]    <= rdata_i[63:0];
                            data_w2[{data_line, 3'b101}]    <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 3'b100}]    <= rdata_i[63:0];
                            data_w3[{data_line, 3'b101}]    <= rdata_i[127:64];
                        end

                        error_ff                <= error_ff | (rresp_i != 2'b00);
                        id_error                <= id_error | (rid_i != '0);

                        state                   <= S_LOAD_4;
                    end
                end
                S_LOAD_4: begin
                    if (rvalid_i) begin
                        
                        case (data_offset)
                            3'b110: data_hold   <= rdata_i[63:0];
                            3'b111: data_hold   <= rdata_i[127:64];
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 3'b110}]        <= rdata_i[63:0];
                            data_w0[{data_line, 3'b111}]        <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 3'b110}]        <= rdata_i[63:0];
                            data_w1[{data_line, 3'b111}]        <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 3'b110}]        <= rdata_i[63:0];
                            data_w2[{data_line, 3'b111}]        <= rdata_i[127:64];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 3'b110}]        <= rdata_i[63:0];
                            data_w3[{data_line, 3'b111}]        <= rdata_i[127:64];
                        end

                        error_ff                <= error_ff | (rresp_i != 2'b00);
                        id_error                <= id_error | (rid_i != '0);

                        state                   <= S_LOAD_DONE;
                    end 
                end
                S_LOAD_DONE: begin
                    if (error_ff | id_error) begin
                        if (req_rd_ready_i) begin
                            if (way_fill_q == 2'b00) begin
                                tags_w0[data_line].valid        <= 1'b0;
                                tags_w0[data_line].dirty        <= 1'b0;
                            end else if (way_fill_q == 2'b01) begin
                                tags_w1[data_line].valid        <= 1'b0;
                                tags_w1[data_line].dirty        <= 1'b0;
                            end else if (way_fill_q == 2'b10) begin
                                tags_w2[data_line].valid        <= 1'b0;
                                tags_w2[data_line].dirty        <= 1'b0;
                            end else if (way_fill_q == 2'b11) begin
                                tags_w3[data_line].valid        <= 1'b0;
                                tags_w3[data_line].dirty        <= 1'b0;
                            end

                            error_ff            <= 1'b0;
                            id_error            <= 1'b0;

                            state               <= S_RUN;
                        end
                    end else begin
                        if (req_rd_ready_i) begin
                            if (way_fill_q == 2'b00) begin
                                tags_w0[data_line].valid        <= 1'b1;
                                tags_w0[data_line].tag          <= data_tag;
                                tags_w0[data_line].dirty        <= data_mem_wr_ff ? 1'b1 : 1'b0;
                            end else if (way_fill_q == 2'b01) begin
                                tags_w1[data_line].valid        <= 1'b1;
                                tags_w1[data_line].tag          <= data_tag;
                                tags_w1[data_line].dirty        <= data_mem_wr_ff ? 1'b1 : 1'b0;
                            end else if (way_fill_q == 2'b10) begin
                                tags_w2[data_line].valid        <= 1'b1;
                                tags_w2[data_line].tag          <= data_tag;
                                tags_w2[data_line].dirty        <= data_mem_wr_ff ? 1'b1 : 1'b0;
                            end else if (way_fill_q == 2'b11) begin
                                tags_w3[data_line].valid        <= 1'b1;
                                tags_w3[data_line].tag          <= data_tag;
                                tags_w3[data_line].dirty        <= data_mem_wr_ff ? 1'b1 : 1'b0;
                            end

                            if (data_mem_wr_ff) begin
                                if (way_fill_q == 2'b00) begin
                                    data_w0[data_index]         <= store_data;
                                end else if (way_fill_q == 2'b01) begin
                                    data_w1[data_index]         <= store_data;
                                end else if (way_fill_q == 2'b10) begin
                                    data_w2[data_index]         <= store_data;
                                end else if (way_fill_q == 2'b11) begin
                                    data_w3[data_index]         <= store_data;
                                end
                            end 

                            PLRU_tree_q         <= nxt_PLRU_tree;
                            data_hold           <= 64'h0;

                            error_ff            <= 1'b0;
                            id_error            <= 1'b0;

                            state               <= S_RUN;
                        end
                    end
                end
            endcase
        end
    end

    always_comb begin

        data_mem_ready_o            =   1'b0;
        req_resp_valid_o            =   1'b0;
        req_rd_data_o               =   64'h0;

        araddr_o                    =   64'h0;
        arlen_o                     =   8'b0;
        arsize_o                    =   3'b0;
        arburst_o                   =   2'b0;
        arid_o                      =   '0;
        arprot_o                    =   3'b0;
        arvalid_o                   =   1'b0;

        rready_o                    =   1'b0;

        awaddr_o                    =   64'h0;
        awlen_o                     =   8'b0;
        awsize_o                    =   3'b0;
        awburst_o                   =   2'b0;
        awid_o                      =   '0;
        awvalid_o                   =   1'b0;

        wdata_o                     =   128'h0;
        wstrb_o                     =   16'h0;
        wvalid_o                    =   1'b0;
        wlast_o                     =   1'b0;

        bready_o                    =   1'b1;

        exc_valid_o                 =   1'b0;
        exc_code_o                  =   5'b0;

        req_handshake               =   1'b0;

        bypass_reg_wr               =   1'b0;

        data_tag                    =   '0;
        tag_index                   =   '0;
        data_offset                 =   '0;
        data_index                  =   '0;

        data_tag_ff                 =   '0;
        data_index_ff               =   '0;
        tag_index_ff                =   '0;

        victim_tag                  =   '0;

        hit_1h                      =   4'b0000;
        data_hit                    =   1'b0;
        cache_miss                  =   1'b0;

        fetch_data                  =   64'h0;
        store_data                  =   64'h0;

        nxt_PLRU_tree               =   PLRU_tree_q;
        
        way_fill_replace            =   1'b0;
        way_fill_invalid            =   2'b00;
        way_fill_PLRU               =   2'b00;

        nxt_way_fill                =   way_fill_q;
        
        way_dirty                   =   1'b0;
        wb_dirty                    =   1'b0;

        case (state)
            S_RUN: begin
                data_tag            =   data_mem_addr_i[63:13];
                tag_index           =   data_mem_addr_i[12:6];
                data_offset         =   data_mem_addr_i[5:3];

                data_index          =   data_mem_addr_i[12:3];

                data_tag_ff         =   data_mem_addr_ff[63:13];
                data_index_ff       =   data_mem_addr_ff[12:3];
                tag_index_ff        =   data_mem_addr_ff[12:6];

                hit_1h[0]           =   (tag_rd_w0.valid) & (data_tag_ff == tag_rd_w0.tag);
                hit_1h[1]           =   (tag_rd_w1.valid) & (data_tag_ff == tag_rd_w1.tag);
                hit_1h[2]           =   (tag_rd_w2.valid) & (data_tag_ff == tag_rd_w2.tag);
                hit_1h[3]           =   (tag_rd_w3.valid) & (data_tag_ff == tag_rd_w3.tag);

                data_hit            =   |hit_1h & req_handshake_ff;
                cache_miss          =   req_handshake_ff & ~data_hit;

                data_mem_ready_o    =   ~cache_miss;

                req_handshake       =   data_mem_req_i & data_mem_ready_o;

                bypass_reg_wr       =   req_handshake & req_handshake_ff & ~data_mem_wr_i & data_mem_wr_ff & 
                                        (data_mem_addr_i[63:3] == data_mem_addr_ff[63:3]);

                case (hit_1h)
                    4'b0001: fetch_data     =   data_rd_w0;
                    4'b0010: fetch_data     =   data_rd_w1;
                    4'b0100: fetch_data     =   data_rd_w2;
                    4'b1000: fetch_data     =   data_rd_w3;
                    default: fetch_data     =   64'h0;
                endcase

                store_data[7:0]     =   data_mem_mask_ff[0] ? data_mem_wr_data_ff[7:0] : fetch_data[7:0];
                store_data[15:8]    =   data_mem_mask_ff[1] ? data_mem_wr_data_ff[15:8] : fetch_data[15:8];
                store_data[23:16]   =   data_mem_mask_ff[2] ? data_mem_wr_data_ff[23:16] : fetch_data[23:16];
                store_data[31:24]   =   data_mem_mask_ff[3] ? data_mem_wr_data_ff[31:24] : fetch_data[31:24];
                store_data[39:32]   =   data_mem_mask_ff[4] ? data_mem_wr_data_ff[39:32] : fetch_data[39:32];
                store_data[47:40]   =   data_mem_mask_ff[5] ? data_mem_wr_data_ff[47:40] : fetch_data[47:40];
                store_data[55:48]   =   data_mem_mask_ff[6] ? data_mem_wr_data_ff[55:48] : fetch_data[55:48];
                store_data[63:56]   =   data_mem_mask_ff[7] ? data_mem_wr_data_ff[63:56] : fetch_data[63:56];

                req_resp_valid_o    =   data_hit;
                req_rd_data_o       =   bypass_active ? bypass_data : fetch_data;

                case (hit_1h)
                    4'b0001: nxt_PLRU_tree  =   {2'b11, PLRU_tree_q[2]};
                    4'b0010: nxt_PLRU_tree  =   {2'b10, PLRU_tree_q[2]};
                    4'b0100: nxt_PLRU_tree  =   {1'b0, PLRU_tree_q[1], 1'b1};
                    4'b1000: nxt_PLRU_tree  =   {1'b0, PLRU_tree_q[1], 1'b0};
                    default: nxt_PLRU_tree  =   PLRU_tree_q;
                endcase

                way_fill_replace    =   tag_rd_w0.valid & tag_rd_w1.valid & tag_rd_w2.valid & tag_rd_w3.valid;

                way_fill_invalid    =   ~tag_rd_w0.valid ? 2'b00 : 
                                       (~tag_rd_w1.valid ? 2'b01 : 
                                       (~tag_rd_w2.valid ? 2'b10 : 
                                       (~tag_rd_w3.valid ? 2'b11 : 2'b00)));

                case (PLRU_tree_q)
                    3'b000, 3'b001: way_fill_PLRU   =   2'b00;
                    3'b010, 3'b011: way_fill_PLRU   =   2'b01;
                    3'b100, 3'b110: way_fill_PLRU   =   2'b10;
                    3'b101, 3'b111: way_fill_PLRU   =   2'b11;
                    default: way_fill_PLRU          =   2'b00;
                endcase

                nxt_way_fill        =   way_fill_replace ? way_fill_PLRU : way_fill_invalid;

                case (nxt_way_fill)
                    2'b00: way_dirty        =   tag_rd_w0.dirty;
                    2'b01: way_dirty        =   tag_rd_w1.dirty;
                    2'b10: way_dirty        =   tag_rd_w2.dirty;
                    2'b11: way_dirty        =   tag_rd_w3.dirty;
                    default: way_dirty      =   1'b0;
                endcase

                wb_dirty            =   way_fill_replace & way_dirty;
            end
            S_STORE_AW_WAIT: begin
                tag_index_ff        =   data_mem_addr_ff[12:6];

                case(way_fill_q)
                    2'b00: victim_tag       =   tag_rd_w0.tag;
                    2'b01: victim_tag       =   tag_rd_w1.tag;
                    2'b10: victim_tag       =   tag_rd_w2.tag;
                    2'b11: victim_tag       =   tag_rd_w3.tag;
                endcase

                awaddr_o            =   {victim_tag, tag_index_ff, 6'b0};
                awlen_o             =   8'd3;
                awsize_o            =   3'b100;
                awburst_o           =   2'b01;
                awid_o              =   1'b1;
                awvalid_o           =   1'b1;
            end
            S_STORE_1: begin
                tag_index_ff        =   data_mem_addr_ff[12:6];

                wvalid_o            =   1'b1;
                wdata_o             =   {wb_upper, wb_lower};
                wstrb_o             =   16'hFFFF;
                wlast_o             =   1'b0;
            end
            S_STORE_2: begin
                tag_index_ff        =   data_mem_addr_ff[12:6];

                wvalid_o            =   1'b1;
                wdata_o             =   {wb_upper, wb_lower};
                wstrb_o             =   16'hFFFF;
                wlast_o             =   1'b0;
            end
            S_STORE_3: begin
                tag_index_ff        =   data_mem_addr_ff[12:6];

                wvalid_o            =   1'b1;
                wdata_o             =   {wb_upper, wb_lower};
                wstrb_o             =   16'hFFFF;
                wlast_o             =   1'b0;
            end
            S_STORE_4: begin
                wvalid_o            =   1'b1;
                wdata_o             =   {wb_upper, wb_lower};
                wstrb_o             =   16'hFFFF;
                wlast_o             =   1'b1;
            end
            S_STORE_DONE: begin
                tag_index_ff        =   data_mem_addr_ff[12:6];

                if (bvalid_i & ((bresp_i != 2'b00) | (bid_i != '0))) begin
                    exc_valid_o     =   1'b1;
                    exc_code_o      =   5'd7;
                end
            end
            S_LOAD_REQUEST: begin
                araddr_o            =   {data_mem_addr_ff[63:6], 6'b0};
                arlen_o             =   8'd3;
                arsize_o            =   3'b100;
                arburst_o           =   2'b01;
                arid_o              =   1'b1;
                arprot_o            =   3'b000;
                arvalid_o           =   1'b1;
            end
            S_LOAD_1: begin
                data_offset         =   data_mem_addr_ff[5:3];
                data_line           =   data_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_LOAD_2: begin
                data_offset         =   data_mem_addr_ff[5:3];
                data_line           =   data_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_LOAD_3: begin
                data_offset         =   data_mem_addr_ff[5:3];
                data_line           =   data_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_LOAD_4: begin
                data_offset         =   data_mem_addr_ff[5:3];
                data_line           =   data_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_LOAD_DONE: begin
                exc_valid_o         =   error_ff | id_error;
                exc_code_o          =   data_mem_wr_ff ? 5'd7 : 5'd5;

                data_index          =   data_mem_addr_ff[12:3];
                data_line           =   data_mem_addr_ff[12:6];
                data_tag            =   data_mem_addr_ff[63:13];

                store_data[7:0]     =   data_mem_mask_ff[0] ? data_mem_wr_data_ff[7:0] : data_hold[7:0];
                store_data[15:8]    =   data_mem_mask_ff[1] ? data_mem_wr_data_ff[15:8] : data_hold[15:8];
                store_data[23:16]   =   data_mem_mask_ff[2] ? data_mem_wr_data_ff[23:16] : data_hold[23:16];
                store_data[31:24]   =   data_mem_mask_ff[3] ? data_mem_wr_data_ff[31:24] : data_hold[31:24];
                store_data[39:32]   =   data_mem_mask_ff[4] ? data_mem_wr_data_ff[39:32] : data_hold[39:32];
                store_data[47:40]   =   data_mem_mask_ff[5] ? data_mem_wr_data_ff[47:40] : data_hold[47:40];
                store_data[55:48]   =   data_mem_mask_ff[6] ? data_mem_wr_data_ff[55:48] : data_hold[55:48];
                store_data[63:56]   =   data_mem_mask_ff[7] ? data_mem_wr_data_ff[63:56] : data_hold[63:56];

                if (~(error_ff | id_error)) begin
                    req_rd_data_o           =   data_hold;
                    req_resp_valid_o        =   1'b1;
                end

                case (way_fill_q) 
                    2'b00: nxt_PLRU_tree    =   {2'b11, PLRU_tree_q[2]};
                    2'b01: nxt_PLRU_tree    =   {2'b10, PLRU_tree_q[2]};
                    2'b10: nxt_PLRU_tree    =   {1'b0, PLRU_tree_q[1], 1'b1};
                    2'b11: nxt_PLRU_tree    =   {1'b0, PLRU_tree_q[1], 1'b0};
                    default: nxt_PLRU_tree  =   PLRU_tree_q;
                endcase
            end
        endcase
    end

endmodule