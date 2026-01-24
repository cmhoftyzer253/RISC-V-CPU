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

    logic           sb_ready_o;
    logic           sb_valid_o;
    logic [31:0]    sb_data_o;

    logic           sb_valid_i;
    logic [31:0]    sb_data_i;

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

    //Boot ROM  
    blk_mem_gen_0 Boot_ROM (
        .clka       (clk),
        .ena        (BROM_en),
        .addra      (BROM_addr),
        .douta      (BROM_data)
    );

    //instruction memory -> skid buffer
    skid_buffer #(.WIDTH(32)) u_skid_buffer (
        .clk        (clk),
        .resetn     (resetn),
        .valid_i    (sb_valid_i),
        .data_i     (sb_data_i),
        .ready_o    (sb_ready_o),
        .ready_i    (decode_ready_i),
        .valid_o    (sb_valid_o),
        .data_o     (sb_data_o)
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

        //CPU control signals
        exc_valid_o                 =   exc_valid_i;
        exc_code_o                  =   exc_code_i;

        kill_o                      =   kill_i;

        BROM_instr                  =   (pc_i[63:16] == 48'h0);

        if (BROM_instr) begin
            BROM_addr               =   pc_i[15:2];

            pc_ready_o              =   sb_ready_o;  
            instr_mem_req_o         =   1'b0;
            instr_mem_addr_o        =   64'd0;    
        end else begin
            pc_ready_o              =   instr_mem_ready_i & sb_ready_o;
            instr_mem_req_o         =   pc_valid_i & pc_ready_o;
            instr_mem_addr_o        =   pc_i;

            BROM_addr               =   14'd0;
        end

        if (BROM_hold) begin
            sb_valid_i              =   1'b1;
            sb_data_i               =   BROM_hold_instr;
        end else if (BROM_instr_ff) begin
            sb_valid_i              =   1'b1;
            sb_data_i               =   BROM_data;
        end else begin
            sb_valid_i              =   instr_valid_i;
            sb_data_i               =   instr_i;
        end

        BROM_instr_valid            =   BROM_instr & pc_valid_i & sb_ready_o;

        BROM_en                     =   1'b1;

        BROM_reg_write              =   ~BROM_hold & BROM_instr_ff & ~sb_ready_o;
        BROM_reg_clear              =   BROM_hold & sb_ready_o;

        fetch_instr_o               =   sb_data_o;
        instr_valid_o               =   sb_valid_o;
        instr_ready_o               =   ~(BROM_hold | BROM_instr_ff) & sb_ready_o;
    end
endmodule