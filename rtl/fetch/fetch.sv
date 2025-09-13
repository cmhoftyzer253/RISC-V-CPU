import cpu_modules::*;

module fetch (
    input logic         clk,
    input logic         reset,

    //pc interface
    input  logic [63:0] pc_i, 
    input  logic        pc_valid_i,
    output logic        pc_ready_o,

    //instruction memory interface
    input logic [31:0]  instr_i,   
    input logic         instr_valid_i,

    input logic         instr_mem_ready_i,
    output logic        instr_mem_req_o,
    output logic [63:0] instr_mem_addr_o,

    //fetch -> decode interface
    input  logic        decode_ready_i,
    output logic [31:0] fetch_instr_o,
    output logic        instr_valid_o   
);

    logic           sb_ready;
    logic           sb_valid;
    logic [31:0]    sb_data;

    //pc -> instruction memory
    assign instr_mem_req_o          = pc_valid_i & sb_ready;
    assign instr_mem_addr_o         = pc_i;
    assign pc_ready_o               = instr_mem_ready_i & sb_ready;

    //instruction memory -> skid buffer
    skid_buffer_32 u_skid_buffer (
        .clk        (clk),
        .reset      (reset),
        .valid_i    (instr_valid_i),
        .data_i     (instr_i),
        .ready_o    (sb_ready),
        .ready_i    (decode_ready_i),
        .valid_o    (sb_valid),
        .data_o     (sb_data)
    );

    //skid buffer -> decode
    assign fetch_instr_o = sb_data;
    assign instr_valid_o = sb_valid;

endmodule