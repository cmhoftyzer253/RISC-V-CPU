import cpu_modules::*;
import cpu_consts::*;

module imem_axi_rd (

    //cpu interface
    input logic             cpu_clk,
    input logic             cpu_reset,
    input logic             ready_i,
    output logic [31:0]     instr_o,
    output logic            instr_valid_o,
    output logic            last_instr_o,
    
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

    logic           fifo_full;
    logic           fifo_empty;

    logic           fifo_wr_en;
    logic           fifo_rd_en;

    fifo_entry_t    fifo_rd_data;
    fifo_entry_t    fifo_wr_data;

    logic           rready;

    assign fifo_wr_data.error   = (rresp_i != 2'b00);
    assign fifo_wr_data.last    = rlast_i;
    assign fifo_wr_data.data    = rdata_i;

    assign fifo_wr_en           = rvalid_i & rready;
    
    assign rready               = axi_resetn & ~fifo_full;

    async_fifo_64 u_async_fifo_64 (
        
        .axi_clk        (axi_clk),
        .axi_resetn     (axi_resetn),
        .wr_en_i        (fifo_wr_en),
        .wr_data_i      (fifo_wr_data),
        .wr_full_o      (fifo_full),

        .cpu_clk        (cpu_clk),
        .cpu_reset      (cpu_reset),
        .rd_en_i        (fifo_rd_en),
        .rd_data_o      (fifo_rd_data),
        .rd_valid_o     (instr_valid),
        .rd_empty_o     (fifo_empty)
    );

    logic [63:0]    instr_beat;

    logic           have_beat_q;

    logic           beat_half_sel_q;

    logic           instr_last;
    logic [31:0]    instr;

    logic exc_valid;

    assign fifo_rd_en   =   ~have_beat_q & ~fifo_empty & ~cpu_reset;

    assign instr_beat   =   fifo_rd_data.data;

    assign exc_valid    =   (beat_half_sel_q & ready_i & instr_valid_o & fifo_rd_data.error);
    assign instr_last   =   (have_beat_q & fifo_rd_data.last & beat_half_sel_q);

    assign instr        =   ({32{~beat_half_sel_q}} & instr_beat[31:0]) |
                            ({32{ beat_half_sel_q}} & instr_beat[63:32]);

    always_ff @(posedge cpu_clk) begin
        if (cpu_reset) begin
            beat_half_sel_q     <= 1'b0;
            have_beat_q         <= 1'b0;
        end else begin
            if (fifo_rd_en) begin
                have_beat_q         <= 1'b1;
                beat_half_sel_q     <= 1'b0;
            end else if (instr_valid_o & ready_i) begin
                if (have_beat_q & ~beat_half_sel_q) begin
                    beat_half_sel_q <= 1'b1;
                end else if (have_beat_q & beat_half_sel_q) begin
                    have_beat_q     <= 1'b0;
                    beat_half_sel_q <= 1'b0;
                end
            end
        end
    end

    //output assignments
    assign instr_o          = instr;
    assign instr_valid_o    = have_beat_q;
    assign last_instr_o     = instr_last;

    assign rready_o         = rready;

    assign exc_valid_o      = exc_valid;
    assign exc_code_o       = 5'b00001;

endmodule