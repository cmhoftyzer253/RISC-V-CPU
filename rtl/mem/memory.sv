import cpu_consts::*;

module memory (

    //load/store request from datapath
    input logic         data_req_i,
    input logic [63:0]  data_addr_i,
    input logic         data_wr_i,          
    input logic [63:0]  data_wr_data_i,

    //send load/store request to data memory
    output logic        data_mem_req_o,
    output logic [63:0] data_mem_addr_o,
    output logic        data_mem_wr_o,
    output logic [63:0] data_mem_wr_data_o,     
    
    //input from data memory
    input logic [63:0]  mem_rd_data_i,

    //output to writeback
    output logic [63:0] data_mem_rd_data_o,
    output logic [2:0]  data_mem_row_idx_o,    

    //exception flagging
    output logic        exc_valid_o,
    output logic [4:0]  exc_code_o
);

    //Restrict data memory to 512Kb for now
    //Later - write AXI interface module so I can expand to DDR3 memory
    localparam int MEM_SIZE = 512*1024;

    logic [63:0]    data_mem_addr_row;
    logic [2:0]     data_mem_row_idx;

    logic           unaligned_addr;
    logic           oob;
    logic           exc_valid;
    logic [4:0]     exc_code;

    logic           data_mem_req;
    logic           data_mem_wr;

    assign unaligned_addr = (data_byte_en_i == BYTE)        ? 1'b0 :
                            (data_byte_en_i == HALF_WORD)   ? data_addr_i[0] : 
                            (data_byte_en_i == WORD)        ? |data_addr_i[1:0] :
                            (data_byte_en_i == DOUBLE_WORD) ? |data_addr_i[2:0] : 1'b0;

    assign oob = data_req_i & (data_addr_i >= MEM_SIZE);

    assign data_mem_addr_row    = {data_addr_i[63:3], 3'b0};
    assign data_mem_row_idx     = data_addr_i[2:0];

    //exception handling
    assign exc_valid    = (unaligned_addr | oob);
    assign exc_code     = unaligned_addr ? (data_wr_i ? 5'h6 : 5'h4) : 
                                     oob ? (data_wr_i ? 5'h7 : 5'h5) :
                                     5'b0;

    assign data_mem_req = data_req_i & ~oob;
    assign data_mem_wr  = data_wr_i & ~oob;

    //assign outputs
    assign data_mem_req_o       = data_mem_req;
    assign data_mem_addr_o      = data_mem_addr_row;
    assign data_mem_row_idx_o   = data_mem_row_idx;
    assign data_mem_wr_o        = data_mem_wr;
    assign data_mem_wr_data_o   = data_wr_data_i;
    assign data_mem_rd_data_o   = mem_rd_data_i;
    assign exc_valid_o          = exc_valid;
    assign exc_code_o           = exc_code;

endmodule