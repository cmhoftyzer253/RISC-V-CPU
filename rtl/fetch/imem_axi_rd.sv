module imem_axi_rd (

    //cpu interface
    input logic             cpu_clk,
    input logic             cpu_reset,
    input logic             ready_i,
    output logic [511:0]    line_o,
    output logic            line_valid_o,

    //axi interface
    input logic             axi_clk,
    input logic             axi_resetn,
    input logic [63:0]      rdata_i,
    input logic [1:0]       rresp_i,
    input logic             rlast_i,
    input logic             rvalid_i,
    output logic            rready_o,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o
);

    logic [511:0]   line_axi_q;
    logic [511:0]   line_cpu_q;
    logic [511:0]   line_q;

    logic           error_axi_q;
    logic           error_cpu_q;
    logic           error_q;

    logic [2:0]     beat_cnt_q;
    logic           burst_q;

    logic wptr_axi;
    logic rptr_cpu;

    logic wptr_cpu1;
    logic wptr_cpu2;

    logic rptr_axi1;
    logic rptr_axi2;

    logic empty_axi;
    logic full_cpu;

    logic rready;

    logic line_valid;

    logic first_beat;
    logic next_beat;
    logic last_beat;

    assign rready       = axi_resetn & empty_axi;
    assign line_valid   = full_cpu;

    assign empty_axi    = (wptr_axi == rptr_axi2);
    assign full_cpu     = (wptr_cpu2 != rptr_cpu);

    assign first_beat   = ~burst_q & empty_axi & rvalid_i & rready;
    assign next_beat    = burst_q & rvalid_i & rready & ~rlast_i;
    assign last_beat    = burst_q & rvalid_i & rready & rlast_i;

    always_ff @(posedge axi_clk) begin
        if (~axi_resetn) begin
            line_axi_q      <= 512'h0;
            beat_cnt_q      <= 3'b0;
            burst_q         <= 1'b0;
            error_axi_q     <= 1'b0;

            line_q          <= 512'h0;
            error_q         <= 1'b0;
            wptr_axi        <= 1'b0;
        end else begin
            if (first_beat) begin   
                burst_q             <= 1'b1;
                beat_cnt_q          <= 3'b001;
                error_axi_q         <= (rresp_i != 2'b00);
                line_axi_q[63:0]    <= rdata_i;
            end else if (next_beat) begin
                beat_cnt_q                          <= beat_cnt_q + 3'b001;
                line_axi_q[64*beat_cnt_q +: 64]     <= rdata_i;
                if (rresp_i != 2'b00) begin
                    error_axi_q <= 1'b1;
                end
            end

            if (last_beat) begin
                burst_q     <= 1'b0;
                line_q      <= {rdata_i, line_axi_q[447:0]};
                error_q     <= error_axi_q | (rresp_i != 2'b00);
                wptr_axi    <= ~wptr_axi;
            end 
        end
    end

    always_ff @(posedge axi_clk) begin
        if (~axi_resetn) begin
            rptr_axi1 <= 1'b0;
            rptr_axi2 <= 1'b0;
        end else begin
            rptr_axi1 <= rptr_cpu;
            rptr_axi2 <= rptr_axi1;
        end
    end

    always_ff @(posedge cpu_clk) begin
        if (cpu_reset) begin
            wptr_cpu1       <= 1'b0;
            wptr_cpu2       <= 1'b0;
            line_cpu_q      <= 512'h0;
            error_cpu_q     <= 1'b0;
            rptr_cpu        <= 1'b0;
        end else begin
            wptr_cpu1       <= wptr_axi;
            wptr_cpu2       <= wptr_cpu1;

            if (wptr_cpu2 != rptr_cpu) begin
                line_cpu_q      <= line_q;
                error_cpu_q     <= error_q;
            end

            if (ready_i & full_cpu) begin
                rptr_cpu <= ~rptr_cpu;
            end
        end
    end

    //output assignments
    assign line_o       = line_cpu_q;
    assign line_valid_o = line_valid;

    assign rready_o     = rready;

    assign exc_valid_o  = line_valid_o & error_cpu_q;
    assign exc_code_o   = 5'b00001;

endmodule