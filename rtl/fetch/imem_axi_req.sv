module imem_axi_req (

    //cpu interface
    input logic         cpu_clk,
    input logic         cpu_reset,
    input logic [63:0]  araddr_i,
    input logic [7:0]   arlen_i,
    input logic [2:0]   arsize_i,
    input logic [1:0]   arburst_i,
    input logic         valid_i,
    output logic        ready_o,

    //axi interface
    input logic         axi_clk,
    input logic         axi_resetn,
    input logic         arready_i,
    output logic [63:0] araddr_o,
    output logic [7:0]  arlen_o,
    output logic [2:0]  arsize_o,
    output logic [1:0]  arburst_o,
    output logic        arvalid_o
);

    logic [63:0]    addr_cpu_q;
    logic [7:0]     len_cpu_q;
    logic [2:0]     size_cpu_q;
    logic [1:0]     burst_cpu_q;

    logic [63:0]    addr_axi_q;
    logic [7:0]     len_axi_q;
    logic [2:0]     size_axi_q;
    logic [1:0]     burst_axi_q;

    logic           wptr_cpu;
    logic           rptr_axi;

    logic wptr_axi1;
    logic wptr_axi2;
    logic rptr_cpu1;
    logic rptr_cpu2;

    logic empty_cpu;
    logic full_cpu;

    logic new_req_axi;

    logic ready;

    logic arvalid_q;

    logic wr_en;

    assign empty_cpu    = (wptr_cpu == rptr_cpu2);
    assign full_cpu     = ~empty_cpu;

    assign ready        = empty_cpu;

    assign wr_en        = valid_i & ready;

    always_ff @(posedge cpu_clk) begin
        if (cpu_reset) begin
            addr_cpu_q      <= 64'h0;
            len_cpu_q       <= 8'b0;
            size_cpu_q      <= 3'b0;
            burst_cpu_q     <= 2'b0;
            wptr_cpu        <= 1'b0;
        end else if (wr_en) begin
            addr_cpu_q      <= araddr_i;
            len_cpu_q       <= arlen_i;
            size_cpu_q      <= arsize_i;
            burst_cpu_q     <= arburst_i;
            wptr_cpu        <= ~wptr_cpu;
        end
    end

    always_ff @(posedge cpu_clk) begin
        if (cpu_reset) begin
            rptr_cpu1 <= 1'b0;
            rptr_cpu2 <= 1'b0;
        end else begin
            rptr_cpu1 <= rptr_axi;
            rptr_cpu2 <= rptr_cpu1;
        end
    end

    always_ff @(posedge axi_clk) begin
        if (~axi_resetn) begin
            wptr_axi1 <= 1'b0;
            wptr_axi2 <= 1'b0;
        end else begin
            wptr_axi1 <= wptr_cpu;
            wptr_axi2 <= wptr_axi1;
        end
    end

    assign new_req_axi = (wptr_axi2 != rptr_axi);

    always_ff @(posedge axi_clk) begin
        if (~axi_resetn) begin
            addr_axi_q          <= 64'h0;
            len_axi_q           <= 8'b0;
            size_axi_q          <= 3'b0;
            burst_axi_q         <= 2'b0;
            arvalid_q           <= 1'b0;
            rptr_axi            <= 1'b0;
        end else begin
            if (~arvalid_q & new_req_axi) begin
                addr_axi_q      <= addr_cpu_q;
                len_axi_q       <= len_cpu_q;
                size_axi_q      <= size_cpu_q;
                burst_axi_q     <= burst_cpu_q;
                arvalid_q       <= 1'b1;
            end

            if (arvalid_q & arready_i) begin
                arvalid_q       <= 1'b0;
                rptr_axi        <= ~rptr_axi;
            end
        end
    end 

    //output assignments
    assign ready_o      = ready;

    assign araddr_o     = addr_axi_q;
    assign arlen_o      = len_axi_q;
    assign arsize_o     = size_axi_q;
    assign arburst_o    = burst_axi_q;
    assign arvalid_o    = arvalid_q;

endmodule