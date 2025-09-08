import cpu_consts::*;
import cpu_modules::*;

module memory (
    input logic                 clk,
    input logic                 reset,

    //load/store request from datapath
    input logic                 req_valid_i,                // valid request from datapath
    input logic [63:0]          req_addr_i,                 // address for request
    input mem_access_size_t     req_byte_en_i,              // read/write size           
    input logic                 req_wr_i,                   // read/write
    input logic [63:0]          req_wr_data_i,              // data for request (if write)
    input logic                 req_zero_extnd_i,           // zero extend (for read)

    //input from data memory
    input logic                 req_wr_done_i,              // write request completed
    input logic                 req_rd_valid_i,             // valid data from memory
    input logic [63:0]          req_rd_data_i,              // data returned from memory

    //flush
    input logic                 flush_i,

    //send load/store request to data memory
    output logic                data_mem_req_o,             // valid request to memory
    output logic [63:0]         data_mem_addr_o,            // address for request
    output mem_access_size_t    data_mem_byte_en_o,         // read/write size
    output logic                data_mem_wr_o,              // read/write
    output logic [63:0]         data_mem_wr_data_o,         // data for request (if write)
    output logic [7:0]          data_mem_mask_o,            // 1 for bits to change, 0 otherwise

    //output to writeback
    output logic                data_mem_valid_o,           // valid data to writeback
    output logic [63:0]         data_mem_rd_data_o,         // data associated with valid signal

    //pipeline control
    output logic                mem_ready_o,                //ready this cycle
    output logic                mem_busy_o,                 //stall after grace
    
    //exception flags
    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o
);

    //TODO - determine OOB errors
    //Restrict data memory to 512Kb for now
    //Later - write AXI interface module so I can expand to DDR3 memory
    localparam longint unsigned MEM_SIZE = 512*1024;

    logic [7:0]         data_mem_mask;
    logic [63:0]        data_mem_wr_data;

    logic [63:0]        access_size;
    logic               unaligned_addr;
    logic               oob;

    logic               exc_valid;
    logic [4:0]         exc_code;

    logic               rd_ff_en;

    logic [63:0]        rd_addr;
    mem_access_size_t   rd_byte_en;
    logic               rd_zero_extnd;
    logic [63:0]        rd_data;

    logic               issue_rd;
    logic               issue_wr;

    logic               pending_rd_q;
    logic               pending_wr_q;

    logic               nxt_pending_wr;
    logic               nxt_pending_rd;

    logic               grace_q;
    logic               nxt_grace;

    logic               data_mem_req;     
    logic               data_mem_wr;      
    logic               data_mem_valid;  

    //exception handling
    assign access_size[63:0]    =   64'(size_bytes(req_byte_en_i));

    assign oob                  =   req_valid_i & ((req_addr_i + access_size) > MEM_SIZE);

    assign unaligned_addr       =   (req_byte_en_i == BYTE)        ?  1'b0 :
                                    (req_byte_en_i == HALF_WORD)   ?  req_addr_i[0] : 
                                    (req_byte_en_i == WORD)        ? |req_addr_i[1:0] :
                                    (req_byte_en_i == DOUBLE_WORD) ? |req_addr_i[2:0] : 1'b0;

    assign exc_valid            =   (unaligned_addr | oob);
    assign exc_code             =   ({5{unaligned_addr &  req_wr_i}} & 5'b00110) |
                                    ({5{unaligned_addr & ~req_wr_i}} & 5'b00100) |
                                    ({5{oob & ~unaligned_addr &  req_wr_i}} & 5'b00111) |
                                    ({5{oob & ~unaligned_addr & ~req_wr_i}} & 5'b00101);

    assign rd_ff_en             =   issue_rd;

    //store address, size, and zero extend in a flip flop for wr commands
    always_ff @(posedge clk) begin
        if (reset) begin
            rd_addr         <= 64'h0;
            rd_byte_en      <= BYTE;
            rd_zero_extnd   <= 1'b0;
        end else if (rd_ff_en) begin
            rd_addr         <= req_addr_i;
            rd_byte_en      <= req_byte_en_i;
            rd_zero_extnd   <= req_zero_extnd_i;
        end
    end

    //load alignment
    load_align u_load_align (
        .addr_i         (rd_addr),
        .byte_en_i      (rd_byte_en),
        .rd_data_i      (req_rd_data_i),
        .zero_extnd_i   (rd_zero_extnd),
        .rd_data_o      (rd_data)
    );

    //store alignment and mask
    store_align u_store_align (
        .addr_i         (req_addr_i),
        .byte_en_i      (req_byte_en_i),
        .wr_data_i      (req_wr_data_i),
        .wr_data_o      (data_mem_wr_data),
        .mask_o         (data_mem_mask)
    );

    //pipeline control logic
    assign issue_rd         =   req_valid_i & ~req_wr_i & ~exc_valid & ~pending_rd_q & ~pending_wr_q;
    assign issue_wr         =   req_valid_i &  req_wr_i & ~exc_valid & ~pending_rd_q & ~pending_wr_q;

    assign nxt_pending_rd   =   (pending_rd_q & ~(req_rd_valid_i | flush_i)) |
                                (issue_rd     & ~(req_rd_valid_i | flush_i));

    assign nxt_pending_wr   =   (pending_wr_q & ~(req_wr_done_i  | flush_i)) |
                                (issue_wr     & ~(req_wr_done_i  | flush_i));

    assign nxt_grace        =   (issue_rd | issue_wr) & ~(grace_q | flush_i | req_rd_valid_i | req_wr_done_i);

    always_ff @(posedge clk) begin
        if (reset) begin
            pending_rd_q    <= 1'b0;
            pending_wr_q    <= 1'b0;
            grace_q         <= 1'b0;
        end else begin
            pending_rd_q    <= nxt_pending_rd;
            pending_wr_q    <= nxt_pending_wr;
            grace_q         <= nxt_grace;
        end
    end

    assign data_mem_req     =   issue_rd | issue_wr;
    assign data_mem_wr      =   issue_wr;
    assign data_mem_valid   =   req_rd_valid_i & pending_rd_q;

    //assign outputs to memory
    assign data_mem_req_o               =   data_mem_req;
    assign data_mem_addr_o[63:0]        =   req_addr_i;
    assign data_mem_byte_en_o           =   req_byte_en_i;
    assign data_mem_wr_o                =   data_mem_wr;
    assign data_mem_wr_data_o[63:0]     =   data_mem_wr_data;
    assign data_mem_mask_o[7:0]         =   data_mem_mask;

    //assign outputs to pipeline
    assign mem_ready_o                  =   ~(pending_rd_q | pending_wr_q) & ~exc_valid;                       
    assign mem_busy_o                   =   ((pending_rd_q | pending_wr_q) & ~grace_q);                  

    assign exc_valid_o                  =   exc_valid;
    assign exc_code_o                   =   exc_code;

    //assign outputs to writeback
    assign data_mem_valid_o             =   data_mem_valid;
    assign data_mem_rd_data_o[63:0]     =   rd_data[63:0];

endmodule