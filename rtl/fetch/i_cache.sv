import cpu_consts::*;

module i_cache #(
    parameter int ID_W = 1
)(
    //cpu clock, reset
    input logic clk,
    input logic resetn,

    //fetch interface
    input logic                 instr_mem_req_i,
    input logic [63:0]          instr_mem_addr_i,
    output logic                instr_mem_ready_o,

    input logic                 instr_ready_i,
    output logic [31:0]         instr_o,
    output logic                instr_valid_o,

    //AXI interface
    //read address -> interconnect
    input logic                 arready_i,
    output logic [63:0]         araddr_o,
    output logic [7:0]          arlen_o,
    output logic [2:0]          arsize_o,
    output logic [1:0]          arburst_o,
    output logic [ID_W-1:0]     arid_o,
    output logic [2:0]          arprot_o,
    output logic                arvalid_o,

    //read data -> cache
    input logic                 rvalid_i,
    input logic [127:0]         rdata_i,
    input logic [1:0]           rresp_i,
    input logic                 rlast_i,
    input logic [ID_W-1:0]      rid_i,
    output logic                rready_o,

    //CPU control signals
    input logic                 kill_i, 

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o

);
    i_cache_tag_t         tag_rd_w0;
    i_cache_tag_t         tag_rd_w1;
    i_cache_tag_t         tag_rd_w2;
    i_cache_tag_t         tag_rd_w3;

    logic [31:0]        data_rd_w0;
    logic [31:0]        data_rd_w1;
    logic [31:0]        data_rd_w2;
    logic [31:0]        data_rd_w3;

    logic [50:0]        tag_ff;
    logic [50:0]        instr_tag;

    logic [6:0]         instr_index;
    logic [3:0]         instr_offset;
    logic [10:0]        data_index;
    logic [6:0]         data_line;

    logic               instr_hit;
    logic               cache_miss;
    logic               fetch_stall;
    logic               valid_instr;

    logic [1:0]         way_fill_q;
    logic [1:0]         nxt_way_fill;

    logic               way_fill_replace;

    logic [1:0]         way_fill_invalid;
    logic [1:0]         way_fill_PLRU;

    logic [31:0]        instr_hold;
    logic               kill_ff;
    logic               error_ff;
    logic               id_error;

    logic               valid_instr_ff;
    logic [63:0]        instr_mem_addr_ff;

    logic [2:0]         PLRU_tree_q;
    logic [2:0]         nxt_PLRU_tree;

    logic [3:0]         hit_1h;

    i_cache_state_t     state;

    //I-$ tags
    i_cache_tag_t tags_w0 [127:0];
    i_cache_tag_t tags_w1 [127:0];
    i_cache_tag_t tags_w2 [127:0];
    i_cache_tag_t tags_w3 [127:0];

    //I-$ data
    (* ram_style = "block" *) logic [31:0] data_w0 [2047:0];
    (* ram_style = "block" *) logic [31:0] data_w1 [2047:0];
    (* ram_style = "block" *) logic [31:0] data_w2 [2047:0];
    (* ram_style = "block" *) logic [31:0] data_w3 [2047:0];

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            PLRU_tree_q         <= 3'b0;

            tag_rd_w0           <= '0;
            tag_rd_w1           <= '0;
            tag_rd_w2           <= '0;
            tag_rd_w3           <= '0;

            data_rd_w0          <= 32'h0;
            data_rd_w1          <= 32'h0;
            data_rd_w2          <= 32'h0;
            data_rd_w3          <= 32'h0;

            valid_instr_ff      <= 1'b0;

            instr_mem_addr_ff   <= 64'h0;

            way_fill_q          <= 2'b0;

            instr_hold          <= 32'h0;

            kill_ff             <= 1'b0;
            error_ff            <= 1'b0;
            id_error            <= 1'b0;

            for(int i=0; i<128; i++) begin
                tags_w0[i].valid    <= 1'b0;
                tags_w1[i].valid    <= 1'b0;
                tags_w2[i].valid    <= 1'b0;
                tags_w3[i].valid    <= 1'b0;

                tags_w0[i].tag      <= 51'h0;
                tags_w1[i].tag      <= 51'h0;
                tags_w2[i].tag      <= 51'h0;
                tags_w3[i].tag      <= 51'h0;
            end

            state               <= S_IC_RUN;
        end else begin
            case (state)
                S_IC_RUN: begin
                    if (valid_instr & ~fetch_stall & ~cache_miss) begin
                        tag_rd_w0           <= tags_w0[instr_index];
                        tag_rd_w1           <= tags_w1[instr_index];
                        tag_rd_w2           <= tags_w2[instr_index];
                        tag_rd_w3           <= tags_w3[instr_index];

                        data_rd_w0          <= data_w0[data_index];
                        data_rd_w1          <= data_w1[data_index];
                        data_rd_w2          <= data_w2[data_index];
                        data_rd_w3          <= data_w3[data_index];

                        valid_instr_ff      <= valid_instr;

                        instr_mem_addr_ff   <= instr_mem_addr_i;
                    end else if (cache_miss) begin
                        way_fill_q          <= nxt_way_fill;

                        kill_ff             <= 1'b0;

                        instr_hold          <= 32'h0;

                        state               <= S_IC_LOAD_REQUEST;
                    end

                    if (instr_valid_o & instr_ready_i) begin
                        PLRU_tree_q         <= nxt_PLRU_tree;
                    end
                end
                S_IC_LOAD_REQUEST: begin
                    kill_ff                 <= kill_ff | kill_i;

                    if (arready_i) begin
                        state               <= S_IC_LOAD_WAIT;
                    end
                end
                S_IC_LOAD_WAIT: begin
                    kill_ff                 <= kill_ff | kill_i;

                    if (rvalid_i) begin
                        case(instr_offset)
                            4'b0000: instr_hold             <= rdata_i[31:0];
                            4'b0001: instr_hold             <= rdata_i[63:32];
                            4'b0010: instr_hold             <= rdata_i[95:64];
                            4'b0011: instr_hold             <= rdata_i[127:96];
                            default: instr_hold             <= instr_hold;
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 4'b0000}]   <= rdata_i[31:0];
                            data_w0[{data_line, 4'b0001}]   <= rdata_i[63:32];
                            data_w0[{data_line, 4'b0010}]   <= rdata_i[95:64];
                            data_w0[{data_line, 4'b0011}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 4'b0000}]   <= rdata_i[31:0];
                            data_w1[{data_line, 4'b0001}]   <= rdata_i[63:32];
                            data_w1[{data_line, 4'b0010}]   <= rdata_i[95:64];
                            data_w1[{data_line, 4'b0011}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 4'b0000}]   <= rdata_i[31:0];
                            data_w2[{data_line, 4'b0001}]   <= rdata_i[63:32];
                            data_w2[{data_line, 4'b0010}]   <= rdata_i[95:64];
                            data_w2[{data_line, 4'b0011}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 4'b0000}]   <= rdata_i[31:0];
                            data_w3[{data_line, 4'b0001}]   <= rdata_i[63:32];
                            data_w3[{data_line, 4'b0010}]   <= rdata_i[95:64];
                            data_w3[{data_line, 4'b0011}]   <= rdata_i[127:96];
                        end

                        error_ff            <= (rresp_i != 2'b00);
                        id_error            <= (rid_i != '0);

                        state               <= S_IC_LOAD_1;
                    end
                end
                S_IC_LOAD_1: begin
                    kill_ff                 <= kill_ff | kill_i;

                    if (rvalid_i) begin
                        case (instr_offset) 
                            4'b0100: instr_hold             <= rdata_i[31:0];
                            4'b0101: instr_hold             <= rdata_i[63:32];
                            4'b0110: instr_hold             <= rdata_i[95:64];
                            4'b0111: instr_hold             <= rdata_i[127:96];
                            default: instr_hold             <= instr_hold;
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 4'b0100}]   <= rdata_i[31:0];
                            data_w0[{data_line, 4'b0101}]   <= rdata_i[63:32];
                            data_w0[{data_line, 4'b0110}]   <= rdata_i[95:64];
                            data_w0[{data_line, 4'b0111}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 4'b0100}]   <= rdata_i[31:0];
                            data_w1[{data_line, 4'b0101}]   <= rdata_i[63:32];
                            data_w1[{data_line, 4'b0110}]   <= rdata_i[95:64];
                            data_w1[{data_line, 4'b0111}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 4'b0100}]   <= rdata_i[31:0];
                            data_w2[{data_line, 4'b0101}]   <= rdata_i[63:32];
                            data_w2[{data_line, 4'b0110}]   <= rdata_i[95:64];
                            data_w2[{data_line, 4'b0111}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 4'b0100}]   <= rdata_i[31:0];
                            data_w3[{data_line, 4'b0101}]   <= rdata_i[63:32];
                            data_w3[{data_line, 4'b0110}]   <= rdata_i[95:64];
                            data_w3[{data_line, 4'b0111}]   <= rdata_i[127:96];
                        end 

                        error_ff            <= error_ff | (rresp_i != 2'b00);
                        id_error            <= id_error | (rid_i != '0);

                        state               <= S_IC_LOAD_2;
                    end
                end
                S_IC_LOAD_2: begin
                    kill_ff                 <= kill_ff | kill_i;

                    if (rvalid_i) begin
                        case(instr_offset)
                            4'b1000: instr_hold             <= rdata_i[31:0];
                            4'b1001: instr_hold             <= rdata_i[63:32];
                            4'b1010: instr_hold             <= rdata_i[95:64];
                            4'b1011: instr_hold             <= rdata_i[127:96];
                            default: instr_hold             <= instr_hold;
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 4'b1000}]   <= rdata_i[31:0];
                            data_w0[{data_line, 4'b1001}]   <= rdata_i[63:32];
                            data_w0[{data_line, 4'b1010}]   <= rdata_i[95:64];
                            data_w0[{data_line, 4'b1011}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 4'b1000}]   <= rdata_i[31:0];
                            data_w1[{data_line, 4'b1001}]   <= rdata_i[63:32];
                            data_w1[{data_line, 4'b1010}]   <= rdata_i[95:64];
                            data_w1[{data_line, 4'b1011}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 4'b1000}]   <= rdata_i[31:0];
                            data_w2[{data_line, 4'b1001}]   <= rdata_i[63:32];
                            data_w2[{data_line, 4'b1010}]   <= rdata_i[95:64];
                            data_w2[{data_line, 4'b1011}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 4'b1000}]   <= rdata_i[31:0];
                            data_w3[{data_line, 4'b1001}]   <= rdata_i[63:32];
                            data_w3[{data_line, 4'b1010}]   <= rdata_i[95:64];
                            data_w3[{data_line, 4'b1011}]   <= rdata_i[127:96];
                        end 

                        error_ff            <= error_ff | (rresp_i != 2'b00);
                        id_error            <= id_error | (rid_i != '0);

                        state               <= S_IC_LOAD_3;
                    end
                end
                S_IC_LOAD_3: begin
                    kill_ff                 <= kill_ff | kill_i;

                    if (rvalid_i) begin

                        case(instr_offset)
                            4'b1100: instr_hold             <= rdata_i[31:0];
                            4'b1101: instr_hold             <= rdata_i[63:32];
                            4'b1110: instr_hold             <= rdata_i[95:64];
                            4'b1111: instr_hold             <= rdata_i[127:96];
                            default: instr_hold             <= instr_hold;
                        endcase

                        if (way_fill_q == 2'b00) begin
                            data_w0[{data_line, 4'b1100}]   <= rdata_i[31:0];
                            data_w0[{data_line, 4'b1101}]   <= rdata_i[63:32];
                            data_w0[{data_line, 4'b1110}]   <= rdata_i[95:64];
                            data_w0[{data_line, 4'b1111}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b01) begin
                            data_w1[{data_line, 4'b1100}]   <= rdata_i[31:0];
                            data_w1[{data_line, 4'b1101}]   <= rdata_i[63:32];
                            data_w1[{data_line, 4'b1110}]   <= rdata_i[95:64];
                            data_w1[{data_line, 4'b1111}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b10) begin
                            data_w2[{data_line, 4'b1100}]   <= rdata_i[31:0];
                            data_w2[{data_line, 4'b1101}]   <= rdata_i[63:32];
                            data_w2[{data_line, 4'b1110}]   <= rdata_i[95:64];
                            data_w2[{data_line, 4'b1111}]   <= rdata_i[127:96];
                        end else if (way_fill_q == 2'b11) begin
                            data_w3[{data_line, 4'b1100}]   <= rdata_i[31:0];
                            data_w3[{data_line, 4'b1101}]   <= rdata_i[63:32];
                            data_w3[{data_line, 4'b1110}]   <= rdata_i[95:64];
                            data_w3[{data_line, 4'b1111}]   <= rdata_i[127:96];
                        end 

                        error_ff            <= error_ff | (rresp_i != 2'b00);
                        id_error            <= id_error | (rid_i != '0);

                        state               <= S_IC_LOAD_DONE;
                    end 
                end
                S_IC_LOAD_DONE: begin
                    if (error_ff | id_error) begin
                        if (instr_ready_i) begin
                            if (way_fill_q == 2'b00) begin
                                tags_w0[instr_index].valid      <= 1'b0; 
                            end else if (way_fill_q == 2'b01) begin
                                tags_w1[instr_index].valid      <= 1'b0;
                            end else if (way_fill_q == 2'b10) begin
                                tags_w2[instr_index].valid      <= 1'b0;
                            end else if (way_fill_q == 2'b11) begin
                                tags_w3[instr_index].valid      <= 1'b0;
                            end

                            kill_ff             <= 1'b0;
                            error_ff            <= 1'b0;
                            id_error            <= 1'b0;
                        end
                    end else if (kill_ff) begin
                        if (way_fill_q == 2'b00) begin
                            tags_w0[instr_index].valid      <= 1'b0; 
                        end else if (way_fill_q == 2'b01) begin
                            tags_w1[instr_index].valid      <= 1'b0;
                        end else if (way_fill_q == 2'b10) begin
                            tags_w2[instr_index].valid      <= 1'b0;
                        end else if (way_fill_q == 2'b11) begin
                            tags_w3[instr_index].valid      <= 1'b0;
                        end

                        kill_ff                 <= 1'b0;
                    end else begin
                        if (instr_ready_i) begin
                            if (way_fill_q == 2'b00) begin
                                tags_w0[instr_index].valid  <= 1'b1;
                                tags_w0[instr_index].tag    <= instr_tag;
                            end else if (way_fill_q == 2'b01) begin
                                tags_w1[instr_index].valid  <= 1'b1;
                                tags_w1[instr_index].tag    <= instr_tag;
                            end else if (way_fill_q == 2'b10) begin
                                tags_w2[instr_index].valid  <= 1'b1;
                                tags_w2[instr_index].tag    <= instr_tag;
                            end else if (way_fill_q == 2'b11) begin
                                tags_w3[instr_index].valid  <= 1'b1;
                                tags_w3[instr_index].tag    <= instr_tag;
                            end

                            PLRU_tree_q     <= nxt_PLRU_tree;
                            instr_hold      <= 32'h0;

                            kill_ff         <= 1'b0;
                            error_ff        <= 1'b0;
                            id_error        <= 1'b0;
                        end
                    end

                    valid_instr_ff          <= 1'b0;

                    state                   <= S_IC_RUN;
                end
                default: begin
                    state                   <= S_IC_RUN;
                end
            endcase
        end
    end

    always_comb begin

        instr_mem_ready_o           =   1'b0;
        instr_o                     =   32'h0;
        instr_valid_o               =   1'b0;

        exc_valid_o                 =   1'b0;
        exc_code_o                  =   5'h00;

        araddr_o                    =   64'h0;
        arlen_o                     =   8'h0;
        arsize_o                    =   3'h0;
        arburst_o                   =   2'h0;
        arid_o                      =   '0;
        arprot_o                    =   3'h0;
        arvalid_o                   =   1'b0;

        rready_o                    =   1'b0;

        nxt_PLRU_tree               =   PLRU_tree_q;

        hit_1h                      =   4'b0;

        instr_tag                   =   51'h0;
        instr_index                 =   7'b0;
        instr_offset                =   4'b0;
        data_index                  =   11'b0;
        data_line                   =   7'b0;

        tag_ff                      =   instr_mem_addr_ff[63:13];

        instr_hit                   =   1'b0;
        cache_miss                  =   1'b0;
        fetch_stall                 =   1'b0;
        valid_instr                 =   1'b0;

        way_fill_replace            =   1'b0;
        way_fill_invalid            =   2'b00;
        way_fill_PLRU               =   2'b00;
        nxt_way_fill                =   way_fill_q;

        case (state)
            S_IC_RUN: begin
                instr_tag           =   instr_mem_addr_i[63:13];
                instr_index         =   instr_mem_addr_i[12:6];
                instr_offset        =   instr_mem_addr_i[5:2];

                data_index          =   instr_mem_addr_i[12:2];

                tag_ff              =   instr_mem_addr_ff[63:13];

                hit_1h[0]           =   (tag_rd_w0.valid) & (tag_ff == tag_rd_w0.tag);
                hit_1h[1]           =   (tag_rd_w1.valid) & (tag_ff == tag_rd_w1.tag);
                hit_1h[2]           =   (tag_rd_w2.valid) & (tag_ff == tag_rd_w2.tag);
                hit_1h[3]           =   (tag_rd_w3.valid) & (tag_ff == tag_rd_w3.tag);

                instr_hit           =   |hit_1h & valid_instr_ff;
                cache_miss          =   valid_instr_ff & ~instr_hit;

                instr_valid_o       =   instr_hit;

                fetch_stall         =   instr_valid_o & ~instr_ready_i;

                instr_mem_ready_o   =   ~fetch_stall & ~cache_miss;

                valid_instr         =   instr_mem_req_i & instr_mem_ready_o;

                case(hit_1h)
                    4'b0001: instr_o        =   data_rd_w0;
                    4'b0010: instr_o        =   data_rd_w1;
                    4'b0100: instr_o        =   data_rd_w2;
                    4'b1000: instr_o        =   data_rd_w3;
                    default: instr_o        =   32'h0;
                endcase

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

                case(PLRU_tree_q)
                    3'b000, 3'b001: way_fill_PLRU   =   2'b00;
                    3'b010, 3'b011: way_fill_PLRU   =   2'b01;
                    3'b100, 3'b110: way_fill_PLRU   =   2'b10;
                    3'b101, 3'b111: way_fill_PLRU   =   2'b11;
                    default: way_fill_PLRU          =   2'b00;
                endcase

                nxt_way_fill        =   way_fill_replace ? way_fill_PLRU : way_fill_invalid;
            end
            S_IC_LOAD_REQUEST: begin
                araddr_o            =   {instr_mem_addr_ff[63:6], 6'b0};
                arlen_o             =   8'd3;
                arsize_o            =   3'd4;
                arburst_o           =   2'b01;
                arid_o              =   1'b0;
                arprot_o            =   3'b000;
                arvalid_o           =   1'b1;
            end
            S_IC_LOAD_WAIT: begin
                instr_offset        =   instr_mem_addr_ff[5:2];
                data_line           =   instr_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_IC_LOAD_1: begin
                instr_offset        =   instr_mem_addr_ff[5:2];
                data_line           =   instr_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_IC_LOAD_2: begin
                instr_offset        =   instr_mem_addr_ff[5:2];
                data_line           =   instr_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_IC_LOAD_3: begin
                instr_offset        =   instr_mem_addr_ff[5:2];
                data_line           =   instr_mem_addr_ff[12:6];

                rready_o            =   1'b1;
            end
            S_IC_LOAD_DONE: begin
                exc_valid_o         =   error_ff | id_error;
                exc_code_o          =   5'b00001;

                instr_index         =   instr_mem_addr_ff[12:6];
                instr_tag           =   instr_mem_addr_ff[63:13];

                if (~(kill_ff | error_ff | id_error)) begin
                    instr_o         =   instr_hold;
                    instr_valid_o   =   1'b1;
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