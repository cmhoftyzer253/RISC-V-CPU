import cpu_modules::*;

module clint (
    input logic                 clk,
    input logic                 reset,

    input logic [63:0]          addr_i,
    input logic                 valid_i,
    input mem_access_size_t     byte_en_i,
    input logic                 wr_i,
    input logic [63:0]          wr_data_i,
    output logic                ready_o,

    output logic [63:0]         data_o,
    output logic                resp_valid_o,

    output logic                msi_irq_o,
    output logic                mti_irq_o,

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o
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
        if (reset) begin
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
        data_o                  =   64'h0;
        resp_valid_o            =   1'b0;
        
        ready_o                 =   1'b1;

        msip_addr               =   (addr_i == 64'h0000_0000_0001_0000);
        mtimecmp_addr           =   (addr_i == 64'h0000_0000_0001_4000);
        mtime_addr              =   (addr_i == 64'h0000_0000_0001_BFF8);

        oob                     =   ~(msip_addr | mtimecmp_addr | mtime_addr);

        acc_fault               =   (mtimecmp_addr | mtime_addr) & 
                                    ((byte_en_i == BYTE | byte_en_i == HALF_WORD | byte_en_i == WORD) | (|addr_i[2:0]));

        handshake               =   valid_i & ready_o;

        exc_valid_o             =   (oob | acc_fault) & handshake;
        exc_code_o              =   wr_i ? 5'd7 : 5'd5;

        msi_irq_o               =   msip_q;
        mti_irq_o               =   mtime_q >= mtimecmp_q;

        //loads
        if (~wr_i & handshake & ~exc_valid_o) begin
            if (msip_addr) begin
                data_o          =   {63'h0, msip_q};
                resp_valid_o    =   1'b1;
            end else if (mtimecmp_addr) begin
                data_o          =   mtimecmp_q;
                resp_valid_o    =   1'b1;
            end else if (mtime_addr) begin
                data_o          =   mtime_q;
                resp_valid_o    =   1'b1;
            end 
        end else begin
            data_o              =   64'h0;
            resp_valid_o        =   handshake & ~exc_valid_o;
        end

    end

endmodule