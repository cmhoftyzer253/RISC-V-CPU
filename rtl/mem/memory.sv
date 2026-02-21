import cpu_consts::*;

module memory (
    input logic                 clk,
    input logic                 resetn,

    //datapath request interface
    input logic                 req_valid_i,
    input logic [63:0]          req_addr_i,
    input mem_access_size_t     req_byte_en_i,
    input logic                 req_wr_i,
    input logic                 req_zero_extnd_i,
    input logic [63:0]          req_wr_data_i,
    output logic                req_ready_o,

    //datapath response interface
    output logic                data_mem_resp_valid_o,
    output logic [63:0]         data_mem_rd_data_o,

    //data memory request interface
    input logic                 data_mem_ready_i,
    output logic                data_mem_req_o,
    output logic [63:0]         data_mem_addr_o,
    output logic                data_mem_wr_o,
    output logic [63:0]         data_mem_wr_data_o,
    output logic [7:0]          data_mem_mask_o,

    //data memory response interface
    input logic                 req_resp_valid_i,
    input logic [63:0]          req_rd_data_i,
    output logic                req_resp_ready_o,

    //control signals
    input logic                 flush_i,

    input logic                 exc_valid_i,
    input logic [4:0]           exc_code_i,

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o
);

    logic [2:0]                 req_addr_ff;
    mem_access_size_t           req_byte_en_ff;
    logic                       req_zero_extnd_ff;

    logic                       req_handshake;

    logic                       oob;
    logic                       unaligned_addr;

    logic                       exc_valid_mem;
    logic [4:0]                 exc_code_mem;

    logic [4:0]                 exc_code_ff;

    logic [63:0]                store_data;
    logic [7:0]                 store_mask;
    logic [63:0]                load_data;

    memory_state_t              state;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            req_addr_ff                     <=  3'b000;
            req_byte_en_ff                  <=  DOUBLE_WORD;
            req_zero_extnd_ff               <=  1'b0;

            exc_code_ff                     <=  5'b0;

            state                           <= S_MEM_RUN;
        end else begin
            case (state)
                S_MEM_RUN: begin
                    if (exc_valid_o & ~flush_i) begin
                        exc_code_ff         <=  exc_code_o;

                        state               <=  S_MEM_EXC_HOLD;
                    end else if (req_handshake) begin
                        req_addr_ff         <=  req_addr_i;
                        req_byte_en_ff      <=  req_byte_en_i;
                        req_zero_extnd_ff   <=  req_zero_extnd_i;
                    end
                end
                S_MEM_EXC_HOLD: begin
                    if (flush_i) begin
                        state               <=  S_MEM_RUN;
                    end
                end
            endcase
        end
    end

    always_comb begin
        case (state)
            req_ready_o                     =   1'b0;

            data_mem_resp_valid_o           =   1'b0;
            data_mem_rd_data_o              =   64'h0;

            data_mem_req_o                  =   1'b0;
            data_mem_addr_o                 =   64'h0;
            data_mem_wr_o                   =   1'b0;
            data_mem_wr_data_o              =   64'h0;
            data_mem_mask_o                 =   8'h0;

            req_resp_ready_o                =   1'b0;

            exc_valid_o                     =   1'b0;
            exc_code_o                      =   5'b0;

            req_handshake                   =   1'b0;

            oob                             =   1'b0;
            unaligned_addr                  =   1'b0;

            exc_valid_mem                   =   1'b0;
            exc_code_mem                    =   5'b0;

            store_data                      =   64'h0;
            store_mask                      =   8'b0;
            load_data                       =   64'h0;

            S_MEM_RUN: begin
                oob                         =   req_valid_i & req_ready_o & ~flush_i & 
                                                ~((req_addr_i >= 64'h0000_0000_0001_0000) & (req_addr_i <= 64'h0000_0000_0001_BFFF));

                unaligned_addr              =   req_valid_i & req_ready_o & ~flush_i & 
                                                ((req_byte_en_i == BYTE)        ?   1'b0                : 
                                                 (req_byte_en_i == HALF_WORD)   ?   req_addr_i[0]       : 
                                                 (req_byte_en_i == WORD)        ?   |req_addr_i[1:0]    : 
                                                 (req_byte_en_i == DOUBLE_WORD) ?   |req_addr_i[2:0]    :   1'b0);

                exc_valid_mem               =   oob | unaligned_addr;
                exc_code_mem                =   ({5{oob &  req_wr_i}} & 5'd7)                   | 
                                                ({5{oob & ~req_wr_i}} & 5'd5)                   | 
                                                ({5{unaligned_addr & ~oob &  req_wr_i}} & 5'd6) |
                                                ({5{unaligned_addr & ~oob & ~req_wr_i}} & 5'd4);

                exc_valid_o                 =   exc_valid_i | exc_valid_mem;
                exc_code_o                  =   exc_valid_i ? exc_code_i : exc_code_mem;

                req_handshake               =   req_valid_i & req_ready_o & ~flush_i & ~exc_valid_o;

                //store align & mask
                case (req_byte_en_i)
                    BYTE: begin
                        store_data[7:0]     =   ({8{req_addr_i[2:0] == 3'b000}} & req_wr_data_i[7:0]);
                        store_data[15:8]    =   ({8{req_addr_i[2:0] == 3'b001}} & req_wr_data_i[7:0]);
                        store_data[23:16]   =   ({8{req_addr_i[2:0] == 3'b010}} & req_wr_data_i[7:0]);
                        store_data[31:24]   =   ({8{req_addr_i[2:0] == 3'b011}} & req_wr_data_i[7:0]);
                        store_data[39:32]   =   ({8{req_addr_i[2:0] == 3'b100}} & req_wr_data_i[7:0]);
                        store_data[47:40]   =   ({8{req_addr_i[2:0] == 3'b101}} & req_wr_data_i[7:0]);
                        store_data[55:48]   =   ({8{req_addr_i[2:0] == 3'b110}} & req_wr_data_i[7:0]);
                        store_data[63:56]   =   ({8{req_addr_i[2:0] == 3'b111}} & req_wr_data_i[7:0]);

                        store_mask[0]       =   (req_addr_i[2:0] == 3'b000);
                        store_mask[1]       =   (req_addr_i[2:0] == 3'b001);
                        store_mask[2]       =   (req_addr_i[2:0] == 3'b010);
                        store_mask[3]       =   (req_addr_i[2:0] == 3'b011);
                        store_mask[4]       =   (req_addr_i[2:0] == 3'b100);
                        store_mask[5]       =   (req_addr_i[2:0] == 3'b101);
                        store_mask[6]       =   (req_addr_i[2:0] == 3'b110);
                        store_mask[7]       =   (req_addr_i[2:0] == 3'b111);
                    end
                    HALF_WORD: begin
                        store_data[15:0]    =   ({16{req_addr_i[2:1] == 2'b00}} & req_wr_data_i[15:0]);
                        store_data[31:16]   =   ({16{req_addr_i[2:1] == 2'b01}} & req_wr_data_i[15:0]);
                        store_data[47:32]   =   ({16{req_addr_i[2:1] == 2'b10}} & req_wr_data_i[15:0]);
                        store_data[63:48]   =   ({16{req_addr_i[2:1] == 2'b01}} & req_wr_data_i[15:0]);

                        store_mask[1:0]     =   {2{req_addr_i[2:1] == 2'b00}};
                        store_mask[3:2]     =   {2{req_addr_i[2:1] == 2'b01}};
                        store_mask[5:4]     =   {2{req_addr_i[2:1] == 2'b10}};
                        store_mask[7:6]     =   {2{req_addr_i[2:1] == 2'b11}};
                    end
                    WORD: begin
                        store_data[31:0]    =   ({32{~req_addr_i[2]}} & req_wr_data_i[31:0]);
                        store_data[63:32]   =   ({32{ req_addr_i[2]}} & req_wr_data_i[31:0]);

                        store_mask[3:0]     =   {4{~req_addr_i[2]}};
                        store_mask[7:4]     =   {4{ req_addr_i[2]}};
                    end
                    DOUBLE_WORD: begin
                        store_data          =   req_wr_data_i;
                        store_mask          =   8'hFF;
                    end
                    default: begin
                        store_data          =   64'h0;
                        store_mask          =   8'b0;
                    end
                endcase

                //load align 
                case (req_byte_en_ff)
                    BYTE: begin
                        case (req_addr_ff[2:0])
                            3'b000: load_data[7:0]      =   req_rd_data_i[7:0];
                            3'b001: load_data[7:0]      =   req_rd_data_i[15:8];
                            3'b010: load_data[7:0]      =   req_rd_data_i[23:16];
                            3'b011: load_data[7:0]      =   req_rd_data_i[31:24];
                            3'b100: load_data[7:0]      =   req_rd_data_i[39:32];
                            3'b101: load_data[7:0]      =   req_rd_data_i[47:40];
                            3'b110: load_data[7:0]      =   req_rd_data_i[55:48];
                            3'b111: load_data[7:0]      =   req_rd_data_i[63:56];
                            default: load_data[7:0]     =   8'b0;
                        endcase

                        load_data[63:8]     =   {56{~req_zero_extnd_ff & load_data[7]}};
                    end
                    HALF_WORD: begin
                        case (req_addr_ff[2:1])
                            2'b00: load_data[15:0]      =   req_rd_data_i[15:0];
                            2'b01: load_data[15:0]      =   req_rd_data_i[31:16];
                            2'b10: load_data[15:0]      =   req_rd_data_i[47:32];
                            2'b11: load_data[15:0]      =   req_rd_data_i[63:48];
                            default: load_data[15:0]    =   16'h0;
                        endcase

                        load_data[63:16]    =   {48{~req_zero_extnd_ff & load_data[15]}};
                    end
                    WORD: begin
                        case (req_addr_ff[2])
                            1'b0: load_data[31:0]       =   req_rd_data_i[31:0];
                            1'b1: load_data[31:0]       =   req_rd_data_i[63:32];
                            default: load_data[31:0]    =   32'h0;
                        endcase

                        load_data[63:32]    =   {32{~req_zero_extnd_ff & load_data[31]}};
                    end
                    DOUBLE_WORD: load_data              =   req_rd_data_i;
                    default: load_data                  =   req_rd_data_i;
                endcase

                if (req_handshake & req_wr_i) begin
                    data_mem_req_o          =   1'b1;
                    data_mem_addr_o         =   req_addr_i;
                    data_mem_wr_o           =   1'b1;
                    data_mem_wr_data_o      =   store_data;
                    data_mem_mask_o         =   store_mask;
                end

                if (req_handshake & ~req_wr_i) begin
                    data_mem_req_o          =   1'b1;
                    data_mem_addr_o         =   req_addr_i;
                    data_mem_wr_o           =   1'b0;
                    data_mem_wr_data_o      =   64'h0;
                    data_mem_mask_o         =   8'b0;
                end

                req_ready_o                 =   data_mem_ready_i;

                data_mem_resp_valid_o       =   req_resp_valid_i;
                data_mem_rd_data_o          =   load_data;

                req_resp_ready_o            =   1'b1;
            end
            S_MEM_EXC_HOLD: begin
                exc_valid_o                 =   1'b1;
                exc_code_o                  =   exc_code_ff;

                data_mem_resp_valid_o       =   1'b1;
            end
        endcase
    end

endmodule