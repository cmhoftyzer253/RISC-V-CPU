import cpu_modules::*;
import cpu_consts::*;

module async_fifo_64 (
    //write (axi side) interface
    input logic         axi_clk,
    input logic         axi_resetn,
    input logic         wr_en_i,
    input fifo_entry_t  wr_data_i,
    output logic        wr_full_o,

    //read (cpu side) interface
    input logic         cpu_clk,
    input logic         cpu_reset,
    input logic         rd_en_i,
    output fifo_entry_t rd_data_o,
    output logic        rd_valid_o,
    output logic        rd_empty_o
);

    fifo_entry_t    mem [7:0];

    fifo_entry_t    rd_data_q;

    logic           rd_valid_q;

    logic           wr_full;
    logic           rd_empty;

    logic           wr_ptr_incr;
    logic           rd_ptr_incr;

    logic [3:0]     wr_b_ptr_q;
    logic [3:0]     wr_gc_ptr_q;

    logic [3:0]     nxt_wr_b_ptr;
    logic [3:0]     nxt_wr_gc_ptr;

    logic [3:0]     rd_b_ptr_q;
    logic [3:0]     rd_gc_ptr_q;

    logic [3:0]     nxt_rd_b_ptr;
    logic [3:0]     nxt_rd_gc_ptr;

    logic [3:0]     wr_gc_cpu_ptr_q1;
    logic [3:0]     wr_gc_cpu_ptr_q2;

    logic [3:0]     rd_gc_axi_ptr_q1;
    logic [3:0]     rd_gc_axi_ptr_q2;

    assign wr_ptr_incr    = wr_en_i & ~wr_full;

    assign nxt_wr_b_ptr   = wr_b_ptr_q + wr_ptr_incr;
    assign nxt_wr_gc_ptr  = bin_to_gc (nxt_wr_b_ptr);

    always_ff @(posedge axi_clk) begin
        if (~axi_resetn) begin
            wr_b_ptr_q  <= 4'b0;
            wr_gc_ptr_q <= 4'b0;
        end else begin
            if (wr_ptr_incr) begin
                mem[wr_b_ptr_q[2:0]] <= wr_data_i;
            end

            wr_b_ptr_q  <= nxt_wr_b_ptr;
            wr_gc_ptr_q <= nxt_wr_gc_ptr;
        end
    end

    always_ff @(posedge axi_clk) begin
        if (~axi_resetn) begin
            rd_gc_axi_ptr_q1 <= 4'b0;
            rd_gc_axi_ptr_q2 <= 4'b0;
        end else begin
            rd_gc_axi_ptr_q1 <= rd_gc_ptr_q;
            rd_gc_axi_ptr_q2 <= rd_gc_axi_ptr_q1;
        end
    end

    assign rd_ptr_incr    = rd_en_i & ~rd_empty;

    assign nxt_rd_b_ptr   = rd_b_ptr_q + rd_ptr_incr;
    assign nxt_rd_gc_ptr  = bin_to_gc (nxt_rd_b_ptr); 

    always_ff @(posedge cpu_clk) begin
        if (cpu_reset) begin
            rd_b_ptr_q  <= 4'b0;
            rd_gc_ptr_q <= 4'b0;
            rd_valid_q  <= 1'b0;
            rd_data_q   <= '0;
        end else begin
            rd_valid_q <= rd_ptr_incr;

            if (rd_ptr_incr) begin
                rd_data_q <= mem[rd_b_ptr_q[2:0]];
            end

            rd_b_ptr_q <= nxt_rd_b_ptr;
            rd_gc_ptr_q <= nxt_rd_gc_ptr;
        end
    end

    always_ff @(posedge cpu_clk) begin
        if (cpu_reset) begin
            wr_gc_cpu_ptr_q1 <= 4'b0;
            wr_gc_cpu_ptr_q2 <= 4'b0;
        end else begin
            wr_gc_cpu_ptr_q1 <= wr_gc_ptr_q;
            wr_gc_cpu_ptr_q2 <= wr_gc_cpu_ptr_q1;
        end
    end

    assign wr_full      = (nxt_wr_gc_ptr == {~rd_gc_axi_ptr_q2[3:2], rd_gc_axi_ptr_q2[1:0]});
    assign rd_empty     = (rd_gc_ptr_q == wr_gc_cpu_ptr_q2);

    //output assignments
    assign wr_full_o    = wr_full;
    assign rd_data_o    = rd_data_q;
    assign rd_valid_o   = rd_valid_q;
    assign rd_empty_o   = rd_empty;

endmodule