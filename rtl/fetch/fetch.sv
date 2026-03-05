module fetch (
    input logic             clk,
    input logic             resetn,

    input logic [63:0]      pc_i,
    output logic            pc_ready_o,

    input logic             flush_i,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o,

    //instruction memory response interface
    input logic             instr_valid_i,
    input logic [31:0]      instr_i,
    output logic            instr_ready_o,

    input logic [4:0]       exc_valid_i,
    input logic             exc_code_i,

    //instruction memory request interface
    input logic             instr_mem_ready_i,
    output logic            instr_mem_req_o,
    output logic [63:0]     instr_mem_addr_o,

    output logic            flush_o,

    //fetch -> decode interface
    input logic             decode_ready_i,
    output logic            instr_valid_o,
    output logic [31:0]     fetch_instr_o
);

    logic [4:0]             exc_code_ff;

    logic                   BROM_instr_ff;
    logic [31:0]            BROM_hold_instr;

    logic                   instr_handshake;

    logic                   BROM_instr;
    logic                   BROM_instr_valid;

    logic                   oob_addr;
    logic                   unaligned_addr;

    logic                   exc_valid_fetch;
    logic [4:0]             exc_code_fetch;

    logic                   BROM_en;
    logic [10:0]            BROM_addr;
    logic [31:0]            BROM_data;

    fetch_state_t           state;

    //Boot ROM
    blk_mem_gen_0 Boot_ROM (
        .clka   (clk),
        .ena    (BROM_en),
        .addra  (BROM_addr),
        .douta  (BROM_data)
    );

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            exc_code_ff                     <= 5'b0;

            BROM_instr_ff                   <= 1'b0;
            BROM_hold_instr                 <= 32'h0;

            state                           <= S_FETCH_RUN;
        end else begin
            BROM_instr_ff                   <= BROM_instr_valid;

            case (state)
                S_FETCH_RUN: begin
                    if (BROM_instr_ff & ~decode_ready_i & ~flush_i) begin
                        BROM_hold_instr     <= BROM_data;

                        state               <= S_BROM_HOLD;
                    end else if (exc_valid_o & ~decode_ready_i & ~flush_i) begin
                        exc_code_ff         <= exc_code_o;

                        state               <= S_FETCH_EXC_HOLD;
                    end
                end
                S_BROM_HOLD: begin
                    if (decode_ready_i | flush_i) begin
                        state               <= S_FETCH_RUN;
                    end
                end
                S_FETCH_EXC_HOLD: begin
                    if (decode_ready_i | flush_i) begin
                        state               <= S_FETCH_RUN;
                    end
                end
            endcase
        end
    end 

    always_comb begin
        pc_ready_o                  =   1'b0;
        flush_o                     =   flush_i;

        exc_valid_o                 =   1'b0;
        exc_code_o                  =   5'b0;

        instr_ready_o               =   1'b0;
        instr_mem_req_o             =   1'b0;
        instr_mem_addr_o            =   64'h0;

        instr_valid_o               =   1'b0;
        fetch_instr_o               =   32'h0;

        BROM_en                     =   1'b0;
        BROM_addr                   =   11'h0;

        instr_handshake             =   1'b0;

        BROM_instr                  =   1'b0;
        BROM_instr_valid            =   1'b0;

        oob_addr                    =   1'b0;
        unaligned_addr              =   1'b0;

        exc_valid_fetch             =   1'b0;
        exc_code_fetch              =   5'b0;

        case (state)
            S_FETCH_RUN: begin
                pc_ready_o          =   decode_ready_i & instr_mem_ready_i;
                BROM_en             =   1'b1;

                BROM_instr          =   pc_ready_o & 
                                        (pc_i >= 64'h0000_0000_0001_0000) & (pc_i <= 64'h0000_0000_0001_1FFF);

                oob_addr            =   ~(BROM_instr | ((pc_i >= 64'h0000_0000_8000_0000) & (pc_i <= 64'h0000_0000_9FFF_FFFF)));
                unaligned_addr      =   |pc_i[1:0];

                exc_valid_fetch     =   pc_ready_o & ~flush_i & (oob_addr | unaligned_addr);
                exc_code_fetch      =   unaligned_addr ? 5'd0 : 5'd1;

                BROM_instr_valid    =   pc_ready_o & BROM_instr & ~exc_valid_fetch & ~flush_i;

                exc_valid_o         =   (exc_valid_i | exc_valid_fetch) & ~flush_i;
                exc_code_o          =   exc_valid_fetch ? exc_code_fetch : exc_code_i;

                instr_ready_o       =   decode_ready_i & ~BROM_instr_ff;

                //load instruction
                if (BROM_instr) begin
                    BROM_addr           =   pc_i[12:2];

                    instr_mem_req_o     =   1'b0;
                    instr_mem_addr_o    =   64'h0;
                end else begin
                    BROM_addr           =   11'h0;

                    instr_mem_req_o     =   pc_ready_o & ~exc_valid_o & ~flush_i;
                    instr_mem_addr_o    =   pc_i;
                end

                //instruction output
                if (BROM_instr_ff) begin
                    instr_valid_o       =   1'b1;
                    fetch_instr_o       =   BROM_data;
                end else begin
                    instr_valid_o       =   instr_valid_i & ~flush_i;
                    fetch_instr_o       =   instr_i;
                end
            end
            S_BROM_HOLD: begin
                instr_valid_o           =   ~flush_i;
                fetch_instr_o           =   BROM_hold_instr;
            end
            S_FETCH_EXC_HOLD: begin
                exc_valid_o             =   ~flush_i;
                exc_code_o              =   exc_code_ff;
            end
        endcase
    end

endmodule;