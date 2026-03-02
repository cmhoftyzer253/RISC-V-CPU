module trap_controller (
    input logic             clk,
    input logic             resetn,

    //control outputs
    output logic            trap_en_o,
    output logic [63:0]     nxt_mepc_o,
    output logic [5:0]      nxt_mcause_o,
    output logic [63:0]     nxt_pc_o,

    //mem interface
    input logic             exc_valid_i,
    input logic [4:0]       exc_code_i,
    input logic [63:0]      mem_pc_i,

    //fetch/decode interface
    input logic             if_pc_ready_i,
    input logic [63:0]      if_pc_incr_i,
    input logic [63:0]      if_pc_i,
    input logic             mret_i,

    //csr interface
    input logic             mstatus_mie_i,
    input logic             mie_ext_ire_i,
    input logic             mie_lcof_ire_i,
    input logic             mie_sw_ire_i,
    input logic             mie_timer_ire_i,

    input logic             mie_ext_irp_i,
    input logic             mie_lcof_irp_i,
    input logic             mie_sw_irp_i,
    input logic             mie_timer_irp_i,

    input logic [63:0]      mtvec_i,
    input logic [63:0]      mepc_i
);

    logic                   trap_active_q;

    logic                   irp_grant;
    logic [4:0]             irp_code;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            trap_active_q       <= 1'b0;
        end else begin
            if (trap_en_o) begin
                trap_active_q   <=  1'b1;
            end else if (mret_i) begin
                trap_active_q   <=  1'b0;
            end
        end
    end

    always_comb begin
        trap_en_o           =   1'b0;
        nxt_mepc_o          =   64'h0;
        nxt_mcause_o        =   6'b0;
        nxt_pc_o            =   64'h0;

        irp_code            =   5'b0;

        irp_grant           =   mstatus_mie_i & ~trap_active_q & ~if_pc_ready_i & 
                                ((mie_ext_ire_i & mie_ext_irp_i)        |
                                 (mie_lcof_ire_i & mie_lcof_irp_i)      |
                                 (mie_sw_ire_i & mie_sw_irp_i)          |
                                 (mie_timer_ire_i & mie_timer_irp_i));

        if (mie_ext_ire_i & mie_ext_irp_i)
            irp_code        =   5'd11;
        else if (mie_sw_ire_i & mie_sw_irp_i) 
            irp_code        =   5'd3;
        else if (mie_timer_ire_i & mie_timer_irp_i) 
            irp_code        =   5'd7;
        else if (mie_lcof_ire_i & mie_lcof_irp_i)
            irp_code        =   5'd13;

        if (exc_valid_i) begin
            trap_en_o       =   1'b1;

            nxt_mepc_o      =   mem_pc_i;
            nxt_pc_o        =   {mtvec_i[63:2], 2'b00};
            nxt_mcause_o    =   {1'b0, exc_code_i};
        end else if (irp_grant) begin
            trap_en_o       =   1'b1;

            nxt_mepc_o      =   if_pc_incr_i;
            nxt_pc_o        =   {mtvec_i[63:2], 2'b00} + ((mtvec_i[1:0] == 2'b01) ? {57'h0, irp_code, 2'b00} : 64'h0);
            nxt_mcause_o    =   {1'b1, irp_code};
        end 

        if (mret_i) begin
            nxt_pc_o        =   mepc_i;
        end
    end

endmodule