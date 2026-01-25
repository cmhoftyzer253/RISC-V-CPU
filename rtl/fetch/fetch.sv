import cpu_modules::*;

module fetch (
    input logic         clk,
    input logic         resetn,

    //CPU interface
    input  logic [63:0] pc_i, 
    input  logic        pc_valid_i,
    output logic        pc_ready_o,

    input logic         kill_i,

    output logic        exc_valid_o,
    output logic [4:0]  exc_code_o,

    //instruction memory response interface
    input logic [31:0]  instr_i,   
    input logic         instr_valid_i,
    output logic        instr_ready_o,

    input logic         exc_valid_i,
    input logic [4:0]   exc_code_i,

    //instruction memory request interface
    input logic         instr_mem_ready_i,
    output logic        instr_mem_req_o,
    output logic [63:0] instr_mem_addr_o,

    output logic        kill_o,

    //fetch -> decode interface
    input  logic        decode_ready_i,
    output logic [31:0] fetch_instr_o,
    output logic        instr_valid_o   
);
    logic           instr_handshake;

    logic           BROM_instr;
    logic           BROM_instr_valid;

    logic           BROM_instr_ff;

    logic           BROM_en;
    logic [13:0]    BROM_addr;
    logic [31:0]    BROM_data;

    logic           BROM_hold;
    logic [31:0]    BROM_hold_instr;

    logic           BROM_reg_write;
    logic           BROM_reg_clear;

    logic           oob_addr;
    logic           unaligned_addr;

    logic           exc_valid_fetch;
    logic [4:0]     exc_code_fetch;

    //Boot ROM  
    blk_mem_gen_0 Boot_ROM (
        .clka       (clk),
        .ena        (BROM_en),
        .addra      (BROM_addr),
        .douta      (BROM_data)
    );

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            BROM_instr_ff   <= 1'b0;
        end else begin
            BROM_instr_ff   <= BROM_instr_valid;
        end
    end 

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            BROM_hold           <= 1'b0;
            BROM_hold_instr     <= 32'd0;
        end else begin
            if (BROM_reg_write) begin
                BROM_hold       <= 1'b1;
                BROM_hold_instr <= BROM_data;
            end else if (BROM_reg_clear) begin
                BROM_hold       <= 1'b0;
                BROM_hold_instr <= 32'd0;
            end
        end
    end

    always_comb begin

        kill_o                      =   kill_i;

        pc_ready_o                  =   instr_mem_ready_i & (decode_ready_i | ~(BROM_hold | BROM_instr_ff));

        instr_handshake             =   pc_valid_i & pc_ready_o;

        BROM_instr                  =   (pc_i[63:16] == 48'h0);

        if (BROM_instr) begin
            BROM_addr               =   pc_i[15:2];

            instr_mem_req_o         =   1'b0;
            instr_mem_addr_o        =   64'd0;    
        end else begin
            instr_mem_req_o         =   instr_handshake & ~exc_valid_fetch & ~kill_i;
            instr_mem_addr_o        =   pc_i;

            BROM_addr               =   14'd0;
        end

        if (BROM_hold) begin
            instr_valid_o           =   1'b1;
            fetch_instr_o           =   BROM_hold_instr;
        end else if (BROM_instr_ff) begin
            instr_valid_o           =   1'b1;
            fetch_instr_o           =   BROM_data;
        end else begin
            instr_valid_o           =   instr_valid_i;
            fetch_instr_o           =   instr_i;
        end

        BROM_en                     =   1'b1;

        BROM_reg_write              =   ~BROM_hold & BROM_instr_ff & ~decode_ready_i;
        BROM_reg_clear              =   BROM_hold & decode_ready_i;

        instr_ready_o               =   ~(BROM_hold | BROM_instr_ff) & decode_ready_i;

        oob_addr                    =   ~(BROM_instr | ((pc_i >= 64'h0000_0000_8000_0000) & (pc_i <= 64'h0000_0000_9FFF_FFFF)));
        unaligned_addr              =   |pc_i[1:0];

        exc_valid_fetch             =   instr_handshake & ~kill_i & (oob_addr | unaligned_addr);
        exc_code_fetch              =   unaligned_addr ? 5'd0 : 5'd1;

        BROM_instr_valid            =   instr_handshake & BROM_instr & ~exc_valid_fetch & ~kill_i;

        //CPU control signals
        exc_valid_o                 =   exc_valid_i | exc_valid_fetch;
        exc_code_o                  =   exc_valid_fetch ? exc_code_fetch : exc_code_i;
    end
endmodule