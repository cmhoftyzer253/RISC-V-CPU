package cpu_utils;
    import cpu_defines::*;

    function automatic logic [53:0] napot_mask (input logic [53:0] addr);
        napot_mask[0] = 1'b1;

        for (int k=1; k<54; k++) begin
            napot_mask[k] = addr[k-1] && napot_mask[j-1];
        end

        return napot_mask;
    endfunction : napot_mask

    function automatic logic [6:0] plru_update (input logic [6:0] plru, input logic [2:0] way);
        case (way)
            3'd0: plru_update       =   plru | 7'b1101000;
            3'd1: plru_update       =   (plru | 7'b1100000) & 7'b1110111;
            3'd2: plru_update       =   (plru | 7'b1000100) & 7'b1011111;
            3'd3: plru_update       =   (plru | 7'b1000000) & 7'b1011011;
            3'd4: plru_update       =   (plru | 7'b0010010) & 7'b0111111;
            3'd5: plru_update       =   (plru | 7'b0010000) & 7'b0111101;
            3'd6: plru_update       =   (plru | 7'b0000001) & 7'b0101111;
            3'd7: plru_update       =   (plru | 7'b0000000) & 7'b0101110;
            default: plru_update    =   plru;
        endcase
    endfunction : plru_update

    function automatic logic [1:0] mpp_wr_legal (input logic [1:0] mpp_wr);
        case (mpp_wr)
            2'b10: mpp_wr_legal     =   2'b11;
            default: mpp_wr_legal   =   mpp_wr;
        endcase
    endfunction : mpp_wr_legal

    function automatic logic [1:0] pmpcfg_rw_legal (input logic [1:0] pmp_rw);
        case (pmp_rw)
            2'b01: pmpcfg_rw_legal      =   2'b00;
            default: pmpcfg_rw_legal    =   pmp_rw;
        endcase
    endfunction : pmpcfg_rw_legal

    function automatic logic [7:0] pmpcfg_wmask (input logic [7:0] pmpcfg);
        pmpcfg_wmask    =   pmpcfg[7] ? 8'h00 : 8'b1001_1111;
    endfunction : pmpcfg_wmask

    function automatic logic [53:0] pmpaddr_wmask (input logic [7:0] pmpcfg, input logic [7:0] pmpcfg_above);
        lock_above      =   pmpcfg_above[7] && (pmpcfg_above[4:3] == TOR);
        pmpaddr_wmask   =   (pmpcfg[7] || lock_above) ? 54'h0 : {54{1'b1}};
    endfunction : pmpaddr_wmask

endpackage : cpu_utils

module fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 8
)(
    input logic                     clk,
    input logic                     resetn,

    input logic                     wr_en_i,
    input logic [WIDTH-1:0]         wr_data_i,

    input logic                     rd_en_i,
    output logic [WIDTH-1:0]        rd_data_o,

    output logic                    full_o,
    output logic                    empty_o,
    output logic [$clog2(DEPTH):0]  count_o
);

    localparam PTR_W = $clog2(DEPTH) + 1;

    logic [WIDTH-1:0] fifo_ff [DEPTH-1:0];
    logic [PTR_W-1:0] rd_ptr;
    logic [PTR_W-1:0] wr_ptr;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rd_ptr  <=  '0;
            wr_ptr  <=  '0;
        end else begin
            if (wr_en_i && !full_o) begin
                fifo_ff[wr_ptr[PTR_W-2:0]]  <=  wr_data_i;
                wr_ptr                      <=  wr_ptr + 1'b1;
            end 
            if (rd_en_i && !empty_o) begin
                rd_ptr                      <=  rd_ptr + 1'b1;
            end
        end
    end

    assign full_o       =   (rd_ptr[PTR_W-1] != wr_ptr[PTR_W-1]) && (rd_ptr[PTR_W-2:0] == wr_ptr[PTR_W-2:0]);
    assign empty_o      =   (rd_ptr == wr_ptr);
    assign count_o      =   wr_ptr - rd_ptr;

    assign rd_data_o    =   fifo_ff[rd_ptr[PTR_W-2:0]];

endmodule