import cpu_defines::*;
import cpu_utils::*;

module i_pmp (
    input logic [63:0]  pc_i,

    input logic [1:0]   priv_level_i,

    input logic [63:0]  pmpaddr0_i,
    input logic [63:0]  pmpaddr1_i,
    input logic [63:0]  pmpaddr2_i,
    input logic [63:0]  pmpaddr3_i,
    input logic [63:0]  pmpaddr4_i,
    input logic [63:0]  pmpaddr5_i,
    input logic [63:0]  pmpaddr6_i,
    input logic [63:0]  pmpaddr7_i,
    input logic [63:0]  pmpaddr8_i,
    input logic [63:0]  pmpaddr9_i,
    input logic [63:0]  pmpaddr10_i,
    input logic [63:0]  pmpaddr11_i,
    input logic [63:0]  pmpaddr12_i,
    input logic [63:0]  pmpaddr13_i,
    input logic [63:0]  pmpaddr14_i,
    input logic [63:0]  pmpaddr15_i,
    input logic [63:0]  pmpcfg0_i,
    input logic [63:0]  pmpcfg2_i,

    output logic        pmp_fault_o
);

    logic [53:0]        pc;
    logic [15:0][53:0]  pmpaddr;
    logic [15:0][7:0]   pmpcfg;

    logic [2:0]         pmp_a;
    logic [53:0]        na_mask;

    logic [15:0]        ge;
    logic [15:0]        match_addr;
    logic [15:0]        pmpcfg_match;

    always_comb begin
        pc          =   pc_i[55:2];

        pmpcfg      =   {pmpcfg2_i, pmpcfg0_i};

        pmpaddr     =   {pmpaddr15_i[53:0], pmpaddr14_i[53:0], pmpaddr13_i[53:0], pmpaddr12_i[53:0], 
                        pmpaddr11_i[53:0], pmpaddr10_i[53:0], pmpaddr9_i[53:0], pmpaddr8_i[53:0],
                        pmpaddr7_i[53:0], pmpaddr6_i[53:0], pmpaddr5_i[53:0], pmpaddr4_i[53:0], 
                        pmpaddr3_i[53:0], pmpaddr2_i[53:0], pmpaddr1_i[53:0], pmpaddr0_i[53:0]};

        for (int i=0; i<16; i++) begin
            ge[i]   =   (pc >= pmpaddr[i]);
        end

        for (int i=0; i<16; i++) begin
            pmp_a   =   pmpcfg[i][4:3];
            na_mask =   (pmp_a == NAPOT) ? napot_mask(pmpaddr[i]) : 54'h0;

            case (pmp_a)
                OFF: match_addr[i]          =   1'b0;
                TOR: match_addr[i]          =   (i == 0) ? !ge[0] : (ge[i-1] && !ge[i]);
                NA4, NAPOT: match_addr[i]   =   &((pc ~^ pmpaddr[i]) | na_mask);
            endcase
        end

        pmpcfg_match    =   8'b0;
        for (int i=15; i >= 0; i--) begin
            if (match_addr[i])
                pmpcfg_match    =   pmpcfg[i];
        end

        if (~|match_addr) begin
            pmp_fault_o     =   (priv_level_i != M_MODE);
        end else if ((priv_level_i == M_MODE) && !pmpcfg_match[7]) begin
            pmp_fault_o     =   1'b0;
        end else begin
            pmp_fault_o     =   !pmpcfg_match[2];
        end

    end

endmodule