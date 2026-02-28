import cpu_modules::*;

module clint (
    input logic                 clk,
    input logic                 resetn,

    input logic [63:0]          req_addr_i,
    input logic                 req_valid_i,
    input mem_access_size_t     req_byte_en_i,
    input logic                 req_wr_i,
    input logic [63:0]          req_wr_data_i,
    output logic                req_ready_o,

    output logic [63:0]         clint_data_o,
    output logic                clint_resp_valid_o,

    output logic                msip_irq_o,
    output logic                mtip_irq_o,

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o,

    output logic [63:0]         mtime_o
);

    logic           msip_q;
    logic [63:0]    mtimecmp_q;
    logic [63:0]    mtime_q;

    logic           msip_addr;
    logic           mtimecmp_addr;
    logic           mtime_addr;

    logic           handshake;
    logic           oob;
    logic           acc_fault;

    always_ff @(posedge clk or posedge reset) begin
        if (~resetn) begin
            msip_q <= 1'b0;
            mtimecmp_q <= 64'hFFFF_FFFF_FFFF_FFFF;
            mtime_q <= 64'h0;
        end else begin
            mtime_q                 <= mtime_q + 64'b1;

            if (handshake & wr_i & ~exc_valid_o) begin
                if (msip_addr)
                    msip_q          <=  wr_data_i[0];
                else if (mtimecmp_addr)
                    mtimecmp_q      <=  wr_data_i;
                else if (mtime_addr)
                    mtime_q         <=  wr_data_i;
            end 
        end 
    end

    always_comb begin
        clint_data_o            =   64'h0;
        clint_resp_valid_o      =   1'b0;
        
        req_ready_o             =   1'b1;

        msip_addr               =   (req_addr_i == 64'h0000_0000_0200_0000);
        mtimecmp_addr           =   (req_addr_i == 64'h0000_0000_0200_4000);
        mtime_addr              =   (req_addr_i == 64'h0000_0000_0200_BFF8);

        oob                     =   ~(msip_addr | mtimecmp_addr | mtime_addr);

        acc_fault               =   (mtimecmp_addr | mtime_addr) & 
                                    ((byte_en_i == BYTE | byte_en_i == HALF_WORD | byte_en_i == WORD) | (|addr_i[2:0]));

        req_handshake           =   req_valid_i & req_ready_o;

        exc_valid_o             =   (oob | acc_fault) & req_handshake;
        exc_code_o              =   req_wr_i ? 5'd7 : 5'd5;

        msip_irq_o              =   msip_q;
        mtip_irq_o              =   mtime_q >= mtimecmp_q;

        mtime_o                 =   mtime_q;

        //loads
        if (~wr_i & handshake & ~exc_valid_o) begin
            if (msip_addr) begin
                clint_data_o        =   {63'h0, msip_q};
                clint_resp_valid_o  =   1'b1;
            end else if (mtimecmp_addr) begin
                clint_data_o        =   mtimecmp_q;
                clint_resp_valid_o  =   1'b1;
            end else if (mtime_addr) begin
                clint_data_o        =   mtime_q;
                clint_resp_valid_o  =   1'b1;
            end 
        end else begin
            clint_data_o            =   64'h0;
            clint_resp_valid_o      =   handshake & ~exc_valid_o;
        end
    end

endmodule