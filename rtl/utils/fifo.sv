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

    always_ff @(posedge clk) begin
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