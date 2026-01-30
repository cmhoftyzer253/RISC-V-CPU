import cpu_consts::*;
import cpu_modules::*;

module memory(
    input logic clk,
    input logic resetn,

    //datapath request interface
    input logic                 req_valid_i,
    input logic [63:0]          req_addr_i;
    input mem_access_size_t     req_byte_en_i,
    input logic                 req_wr_i,
    input logic                 req_zero_extnd_i,
    input logic [63:0]          req_wr_data_i,
    output logic                req_ready_o,

    //datapath response interface
    output logic                data_mem_resp_valid_o,
    output logic [63:0]         data_mem_rd_data_o;

    //data memory request interface
    input logic                 data_mem_ready_i,
    output logic                data_mem_req_o,
    output logic [63:0]         data_mem_addr_o,
    output mem_access_size_t    data_mem_byte_en_o,
    output logic                data_mem_wr_o,
    output logic [63:0]         data_mem_wr_data_o,

    //data memory response interface
    input logic                 req_resp_valid_i,
    input logic                 req_rd_data_i,
    output logic                req_rd_ready_o,

    //control signals
    input logic                 flush_i,

    input logic                 exc_valid_i,
    input logic [4:0]           exc_code_i,

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o
);

    //mmio registers
    (* ram_style "block" *) logic [63:0] mmio [511:0];

    logic [2:0]                 req_addr_ff;
    mem_access_size_t           req_byte_en_ff;
    logic                       req_zero_extnd_ff;
    logic                       req_wr_ff;
    logic                       req_mmio_ff;

    logic                       mmio_load_ff;
    logic                       mmio_store_ff;

    logic [63:0]                mmio_load_data;

    logic                       mmio_req;
    logic                       mn_mem_req;

    logic                       oob_addr;
    logic                       unaligned_addr;

    logic                       exc_valid_mem;
    logic [4:0]                 exc_code_mem;

    logic                       req_handshake;

    logic                       mmio_store;
    logic                       mmio_load;

    logic [8:0]                 mmio_index;

    logic [63:0]                store_data;
    logic [7:0]                 store_mask;
    
    logic [63:0]                req_rd_data;
    logic [63:0]                load_data;

    //input ffs
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            req_addr_ff         <= 3'b0;
            req_byte_en_ff      <= DOUBLE_WORD;
            req_zero_extnd_ff   <= 1'b0;
            req_wr_ff           <= 1'b0;
            req_mmio_ff         <= 1'b0;
        end else if (req_handshake) begin
            req_addr_ff         <= req_addr_i[2:0];
            req_byte_en_ff      <= req_byte_en_i;
            req_zero_extnd_ff   <= req_zero_extnd_i;
            req_wr_ff           <= req_wr_i;
            req_mmio_ff         <= mmio_req;
        end
    end

    //update mmio registers
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            mmio_load_ff        <= 1'b0;
            mmio_store_ff       <= 1'b0;

            mmio_load_data      <= 64'h0;
        end else if (mmio_store) begin
            mmio_store_ff       <= 1'b1;

            if (store_mask[0]) begin
                mmio[mmio_index][7:0]       <= store_data[7:0];
            end
            if (store_mask[1]) begin
                mmio[mmio_index][15:8]      <= store_data[15:8];
            end
            if (store_mask[2]) begin
                mmio[mmio_index][23:16]     <= store_data[23:16];
            end
            if (store_mask[3]) begin
                mmio[mmio_index][31:24]     <= store_data[31:24];
            end
            if (store_mask[4]) begin
                mmio[mmio_index][39:32]     <= store_data[39:32];
            end 
            if (store_mask[5]) begin
                mmio[mmio_index][47:40]     <= store_data[47:40];
            end
            if (store_mask[6]) begin
                mmio[mmio_index][55:48]     <= store_data[55:48];
            end
            if (store_mask[7]) begin
                mmio[mmio_index][63:56]     <= store_data[63:56];
            end
        end else if (mmio_load) begin
            mmio_load_ff                    <= 1'b1;
            mmio_load_data                  <= mmio[mmio_index];
        end else begin
            mmio_load_ff                    <= 1'b0;
            mmio_store_ff                   <= 1'b0;
        end
    end

    always_comb begin
        store_data          =   64'h0;
        store_mask          =   8'b0;

        load_data           =   64'h0;

        data_mem_req_o      =   1'b0;
        data_mem_addr_o     =   64'h0;
        data_mem_byte_en_o  =   DOUBLE_WORD;
        data_mem_wr_o       =   1'b0;
        data_mem_wr_data    =   64'h0;

        mmio_req            =   ((req_addr_i >= 64'h0000_0000_4000_0000) & (req_addr_i <= 64'h0000_0000_4000_0FFF));
        mn_mem_req          =   ((req_addr_i >= 64'h0000_0000_8000_0000) & (req_addr_i <= 64'h0000_0000_9FFF_FFFF));

        oob_addr            =   req_valid_i & req_ready_o & ~(mmio_req | mn_mem_req);

        unaligned_addr      =   req_valid_i & req_ready_o & 
                                ((req_byte_en_i == BYTE)        ? 1'b0 : 
                                 (req_byte_en_i == HALF_WORD)   ? req_addr_i[0] :
                                 (req_byte_en_i == WORD)        ? |req_addr_i[1:0] : 
                                 (req_byte_en_i == DOUBLE_WORD) ? |req_addr_i[2:0] : 1'b0);

        exc_valid_mem       =   oob_addr | unaligned_addr;
        exc_code_mem        =   ({5{oob_addr &  req_wr_i}} & 5'd7) |
                                ({5{oob_addr & ~req_wr_i}} & 5'd5) | 
                                ({5{unaligned_addr & ~oob_addr &  req_wr_i}} & 5'd6) | 
                                ({5{unaligned_addr & ~oob_addr & ~req_wr_i}} & 5'd4);

        exc_valid_o         =   exc_valid_i | exc_valid_mem;
        exc_code_o          =   exc_valid_i ? exc_code_i : exc_code_mem;

        req_handshake       =   req_valid_i & req_ready_o & ~flush_i & ~exc_valid_o;

        mmio_store          =   req_handshake & mmio_req & req_wr_i;
        mmio_load           =   req_handshake & mmio_req & ~req_wr_i;

        mmio_index          =   req_addr_i[11:3];

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
                store_data[63:48]   =   ({16{req_addr_i[2:1] == 2'b11}} & req_wr_data_i[15:0])

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
                store_mask          =   8'b1111_1111;
            end
            default: begin
                store_data          =   64'h0;
                store_mask          =   8'b0;
            end
        endcase

        req_rd_data                 = req_mmio_ff ? mmio_load_data : req_rd_data_i;

        //load align
        case(req_byte_en_ff)
            BYTE: begin
                load_data[7:0]      =   ({8{req_addr_ff[2:0] == 3'b000}} & req_rd_data[7:0])   | 
                                        ({8{req_addr_ff[2:0] == 3'b001}} & req_rd_data[15:8])  |
                                        ({8{req_addr_ff[2:0] == 3'b010}} & req_rd_data[23:16]) |
                                        ({8{req_addr_ff[2:0] == 3'b011}} & req_rd_data[31:24]) |
                                        ({8{req_addr_ff[2:0] == 3'b100}} & req_rd_data[39:32]) |
                                        ({8{req_addr_ff[2:0] == 3'b101}} & req_rd_data[47:40]) |
                                        ({8{req_addr_ff[2:0] == 3'b110}} & req_rd_data[55:48]) |
                                        ({8{req_addr_ff[2:0] == 3'b111}} & req_rd_data[63:56]);

                load_data[63:8]     =   {56{~req_zero_extnd_ff & load_data[7]}};
            end 
            HALF_WORD: begin
                load_data[15:0]     =   ({16{req_addr_ff[2:1] == 2'b00}} & req_rd_data[15:0])  |
                                        ({16{req_addr_ff[2:1] == 2'b01}} & req_rd_data[31:16]) |
                                        ({16{req_addr_ff[2:1] == 2'b10}} & req_rd_data[47:32]) |
                                        ({16{req_addr_ff[2:1] == 2'b11}} & req_rd_data[63:48]);

                load_data[63:16]    =   {48{~req_zero_extnd_ff & load_data[15]}};
            end
            WORD: begin
                load_data[31:0]     =   ({32{~req_addr_ff[2]}} & req_rd_data[31:0]) |
                                        ({32{ req_addr_ff[2]}} & req_rd_data[63:32]);

                load_data[63:32]    =   {32{~req_zero_extnd_ff & load_data[31]}};
            end
            DOUBLE_WORD: load_data  =   req_rd_data;
            default: load_data      =   64'h0;
        endcase

        //main memory store
        if (req_handshake & mn_mem_req & req_wr_i) begin
            data_mem_req_o          =   1'b1;
            data_mem_addr_o         =   req_addr_i;
            data_mem_byte_en_o      =   req_byte_en_i;
            data_mem_wr_o           =   1'b1;
            data_mem_wr_data_o      =   req_wr_data_i;
        end

        //main memory load
        if (req_handshake & mn_mem_req & ~req_wr_i) begin
            data_mem_req_o          =   1'b1;
            data_mem_addr_o         =   req_addr_i;
            data_mem_byte_en_o      =   req_byte_en_i;
            data_mem_wr_o           =   1'b0;
            data_mem_wr_data_o      =   64'h0;
        end

        req_ready_o                 =   data_mem_ready_i;

        data_mem_resp_valid_o       =   (mmio_store_ff |                          //write mmio       
                                         mmio_load_ff  |                          //read mmio
                                         (~req_mmio_ff &  req_resp_valid_i)) &                    //read/write main memory
                                        ~exc_valid_i;
        data_mem_rd_data_o          =   load_data;

        req_rd_ready_o              =   1'b1;
    end

endmodule