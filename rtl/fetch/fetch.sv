module fetch (

    //input from program counter
    input logic         clk,
    input logic         reset,
    input logic [63:0]  pc_i, 

    //request next instruction
    output logic        instr_mem_req_o,
    output logic [63:0] instr_mem_addr_o,

    //receive next instruction
    input logic [31:0]  fetch_instr_i,   
    output logic [31:0] fetch_instr_o   
);

    logic instr_mem_req_q;

    //only request instructions when reset low
    always_ff @(posedge clk or posedge reset)
        if (reset)
            instr_mem_req_q <= 1'b0;
        else
            instr_mem_req_q <= 1'b1;

    assign instr_mem_req_o = instr_mem_req_q;
    assign instr_mem_addr_o = pc_i;             //request instruction at program counter
    assign fetch_instr_o = fetch_instr_i;        //send input instruction to decode

endmodule