import cpu_modules::*;

module clint (
    input logic                 clk,
    input logic                 resetn,

    input logic                 req_valid_i,
    input logic [63:0]          req_addr_i,
    input mem_access_size_t     req_byte_en_i,
    input logic                 req_wr_i,
    input logic [63:0]          req_wr_data_i,

    output logic [63:0]         clint_rd_data_o,
    output logic                clint_resp_valid_o,

    output logic                msip_irp_o,
    output logic                mtip_irp_o,

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o,

    output logic [63:0]         mtime_o
);

    localparam MSIP_ADDR        =   64'h0000_0000_0200_0000;
    localparam MTIMECMP_ADDR    =   64'h0000_0000_0200_4000;
    localparam MTIMECMPH_ADDR   =   64'h0000_0000_0200_4004;
    localparam MTIME_ADDR       =   64'h0000_0000_0200_BFF8;
    localparam MTIMEH_ADDR      =   64'h0000_0000_0200_BFFC;

    logic           msip_q;
    logic [63:0]    mtimecmp_q;
    logic [63:0]    mtime_q;

    logic           unaligned_addr;
    logic           acc_fault_size;
    logic           acc_fault_addr_wr;
    logic           acc_fault_addr_rd;
    logic           acc_fault;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            msip_q <= 1'b0;
            mtimecmp_q <= 64'hFFFF_FFFF_FFFF_FFFF;
            mtime_q <= 64'h0;
        end else begin
            mtime_q                 <= mtime_q + 64'b1;

            if (req_valid_i & req_wr_i & ~exc_valid_o) begin
                if (req_byte_en_i == WORD) begin
                    case (req_addr_i)
                        MSIP_ADDR: begin
                            msip_q              <=  req_wr_data_i[0];
                        end
                        MTIMECMP_ADDR: begin
                            mtimecmp_q[31:0]    <=  req_wr_data_i[31:0];
                        end
                        MTIMECMPH_ADDR: begin
                            mtimecmp_q[63:32]   <=  req_wr_data_i[63:32];
                        end
                        MTIME_ADDR: begin
                            mtime_q[31:0]       <=  req_wr_data_i[31:0];
                        end
                        MTIMEH_ADDR: begin
                            mtime_q[63:32]      <=  req_wr_data_i[63:32];
                        end
                    endcase
                end else if (req_byte_en_i == DOUBLE_WORD) begin
                    case (req_addr_i) 
                        MTIMECMP_ADDR: begin
                            mtimecmp_q          <=  req_wr_data_i;
                        end
                        MTIME_ADDR: begin
                            mtime_q             <=  req_wr_data_i;
                        end
                    endcase
                end
            end 
        end 
    end

    always_comb begin
        clint_rd_data_o         =   64'h0;
        clint_resp_valid_o      =   1'b0;

        acc_fault_addr_rd       =   1'b0;
        
        unaligned_addr          =   ((req_byte_en_i == DOUBLE_WORD) & |req_addr_i[2:0]) | 
                                    ((req_byte_en_i == WORD) & |req_addr_i[1:0]);
        acc_fault_size          =   (req_byte_en_i == BYTE) | (req_byte_en_i == HALF_WORD);
        acc_fault_addr_wr       =   req_wr_i & ~(
                                    (req_addr_i == MTIMECMP_ADDR)                               |
                                    (req_addr_i == MTIME_ADDR)                                  |
                                    ((req_addr_i == MSIP_ADDR) & (req_byte_en_i == WORD))       | 
                                    ((req_addr_i == MTIMECMPH_ADDR) & (req_byte_en_i == WORD))  | 
                                    ((req_addr_i == MTIMEH_ADDR) & (req_byte_en_i == WORD)));

        msip_irp_o              =   msip_q[0];
        mtip_irp_o              =   mtime_q >= mtimecmp_q;

        mtime_o                 =   mtime_q;

        //loads
        if (~req_wr_i & req_valid_i & ~(unaligned_addr | acc_fault_size | acc_fault_addr_wr)) begin
            if (req_byte_en_i == DOUBLE_WORD) begin
                case (req_addr_i)
                    MTIMECMP_ADDR: begin
                        clint_rd_data_o     =   mtimecmp_q;
                        clint_resp_valid_o  =   1'b1;
                    end
                    MTIME_ADDR: begin
                        clint_rd_data_o     =   mtime_q;
                        clint_resp_valid_o  =   1'b1;
                    end
                    default: begin
                        clint_rd_data_o     =   64'h0;
                        clint_resp_valid_o  =   1'b0;

                        acc_fault_addr_rd   =   1'b1;
                    end
                endcase
            end else if (req_byte_en_i == WORD) begin
                case (req_addr_i)
                    MSIP_ADDR: begin
                        clint_rd_data_o     =   {32'h0, msip_q};
                        clint_resp_valid_o  =   1'b1;
                    end
                    MTIMECMP_ADDR: begin
                        clint_rd_data_o     =   {32'h0, mtimecmp_q[31:0]};
                        clint_resp_valid_o  =   1'b1;
                    end
                    MTIMECMPH_ADDR: begin
                        clint_rd_data_o     =   {mtimecmp_q[63:32], 32'h0};
                        clint_resp_valid_o  =   1'b1;
                    end
                    MTIME_ADDR: begin
                        clint_rd_data_o     =   {32'h0, mtime_q[31:0]};
                        clint_resp_valid_o  =   1'b1;
                    end
                    MTIMEH_ADDR: begin
                        clint_rd_data_o     =   {mtime_q[63:32], 32'h0};
                        clint_resp_valid_o  =   1'b1;
                    end 
                    default: begin
                        clint_rd_data_o     =   64'h0;
                        clint_resp_valid_o  =   1'b1;

                        acc_fault_addr_rd   =   1'b1;
                    end
                endcase
            end
        end

        acc_fault               =   acc_fault_size | acc_fault_addr_rd | acc_fault_addr_wr;

        exc_valid_o             =   req_valid_i & (unaligned_addr | acc_fault_size | acc_fault_addr_rd | acc_fault_addr_wr);
        exc_code_o              =   ({5{unaligned_addr & ~acc_fault & ~req_wr_i}} & 5'd4)   | 
                                    ({5{unaligned_addr & ~acc_fault &  req_wr_i}} & 5'd6)   | 
                                    ({5{acc_fault & ~req_wr_i}} & 5'd5)                     |
                                    ({5{acc_fault &  req_wr_i}} & 5'd7);
    end

endmodule