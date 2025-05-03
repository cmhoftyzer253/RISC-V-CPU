module memory (
    input clk,
    input reset_sync,

    //read/write request from datapath
    input logic         data_req_i,
    input logic [63:0]  data_addr_i,
    input logic [1:0]   data_byte_en_i,
    input logic         data_wr_i,
    input logic [63:0]  data_wr_data_i,
    input logic         data_zero_extnd_i,

    //send read/write request to data memory
    output logic        data_mem_req_o,
    output logic [63:0] data_mem_addr_o,
    output logic [1:0]  data_mem_byte_en_o,
    output logic        data_mem_wr_o,
    output logic [31:0] data_mem_wr_data_o,
    
    //input from data memory
    input logic [63:0]  mem_rd_data_i,

    //output to datapath
    output logic [63:0] data_mem_rd_data_o
);

    //TODO - handle unaligned data - see youtube playlist
    //TODO - add datamask for invalid addresses

    import cpu_consts::*;

    //Restrict data memory to 512Kb for now
    //Later - write AXI interface module so I can expand to DDR3 memory
    localparam int MEM_SIZE = 512*1024;

    logic [63:0] data_mem_rd_data;
    logic [63:0] rd_data_sign_extnd;
    logic [63:0] rd_data_zero_extnd;

    assign rd_data_sign_extnd = (data_byte_en_i == BYTE)        ? {{56{mem_rd_data_i[7]}}, mem_rd_data_i[7:0]} : 
                                (data_byte_en_i == HALF_WORD)   ? {{48{mem_rd_data_i[15]}}, mem_rd_data_i[15:0]} : 
                                (data_byte_en_i == WORD)        ? {{32{mem_rd_data_i[31]}}, mem_rd_data_i[31:0]} : 
                                                                    mem_rd_data_i;

    assign rd_data_zero_extnd = (data_byte_en_i == BYTE)        ? {{56{1'b0}}, mem_rd_data_i[7:0]} : 
                                (data_byte_en_i == HALF_WORD)   ? {{48{1'b0}}, mem_rd_data_i[15:0]} : 
                                (data_byte_en_i == WORD)        ? {{32{1'b0}}, mem_rd_data_i[31:0]}: 
                                                                    mem_rd_data_i;

    assign data_mem_rd_data = data_zero_extnd_i ? rd_data_zero_extnd : rd_data_sign_extnd;

    //assign outputs
    assign data_mem_req_o       = data_req_i;
    assign data_mem_addr_o      = data_addr_i;
    assign data_mem_byte_en_o   = data_byte_en_i;
    assign data_mem_wr_o        = data_wr_i;
    assign data_mem_wr_data_o   = data_wr_data_i;
    assign data_mem_rd_data_o   = data_mem_rd_data;

endmodule