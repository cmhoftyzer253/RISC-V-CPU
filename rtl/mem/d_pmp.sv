import cpu_defines::*;
import cpu_utils::*;

module d_pmp (
    input logic         lsu_valid_i,

    input logic [63:0]  lsu_addr_i,
    input logic [1:0]   lsu_ls_i,
    input logic [1:0]   lsu_size_i,

    input logic [1:0]   priv_level_i,
    input logic [1:0]   mstatus_mpp_i,
    input logic         mstatus_mprv_i,

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

    logic [1:0]         priv_level_eff;

    logic [53:0]        addr_base;
    logic [53:0]        addr_uw;

    logic [15:0][53:0]  pmpaddr;
    logic [15:0][7:0]   pmpcfg;

    logic [1:0]         pmp_a;
    logic [53:0]        na_mask;

    logic [15:0]        ge_base;
    logic [15:0]        ge_uw;
    logic [15:0]        match_base;
    logic [15:0]        match_uw;

    logic [7:0]         pmpcfg_base;
    logic [7:0]         pmpcfg_uw;

    logic [4:0]         first_match_base;
    logic [4:0]         first_match_uw;

    logic               straddle;
    logic               enforce;
    
    always_comb begin
        priv_level_eff  =   mstatus_mprv_i ? mstatus_mpp_i : priv_level_i;

        addr_base       =   lsu_addr_i[55:2];
        addr_uw         =   {lsu_addr_i[55:3], lsu_addr_i[2] || (lsu_size_i == DOUBLE_WORD)};

        pmpcfg          =   {pmpcfg2_i, pmpcfg0_i};

        pmpaddr         =   {pmpaddr15_i[53:0], pmpaddr14_i[53:0], pmpaddr13_i[53:0], pmpaddr12_i[53:0],
                            pmpaddr11_i[53:0], pmpaddr10_i[53:0], pmpaddr9_i[53:0], pmpaddr8_i[53:0],
                            pmpaddr7_i[53:0], pmpaddr6_i[53:0], pmpaddr5_i[53:0], pmpaddr4_i[53:0], 
                            pmpaddr3_i[53:0], pmpaddr2_i[53:0], pmpaddr1_i[53:0], pmpaddr0_i[53:0]};

        for (int i=0; i<16; i++) begin
            ge_base[i]  =   (addr_base >= pmpaddr[i]);
            ge_uw[i]    =   ge_base[i] || (addr_uw == pmpaddr[i]);
        end

        for (int i=0; i<16; i++) begin
            pmp_a       =   pmpcfg[i][4:3];
            na_mask     =   (pmp_a == NAPOT) ? napot_mask(pmpaddr[i]) : 54'h0;

            case (pmp_a)
                OFF: begin
                    match_base[i]   =   1'b0;
                    match_uw[i]     =   1'b0;
                end
                TOR: begin
                    match_base[i]   =   (i == 0) ? !ge_base[0] : (ge_base[i-1] && !ge_base[i]);
                    match_uw[i]     =   (i == 0) ? !ge_uw[0] : (ge_uw[i-1] && !ge_uw[i]);
                end
                NA4, NAPOT: begin
                    match_base[i]   =   &((addr_base ~^ pmpaddr[i]) | na_mask);
                    match_uw[i]     =   &((addr_uw ~^ pmpaddr[i]) | na_mask);
                end
            endcase
        end

        pmpcfg_base         =   8'b0;
        pmpcfg_uw           =   8'b0;
        first_match_base    =   5'd0;
        first_match_uw      =   5'd0;
        for (int i=15; i >= 0; i--) begin
            if (match_base[i]) begin
                pmpcfg_base         =   pmpcfg[i];
                first_match_base    =   {1'b1, i[3:0]};
            end
            
            if (match_uw[i]) begin
                pmpcfg_uw           =   pmpcfg[i];
                first_match_uw      =   {1'b1, i[3:0]};
            end
        end

        straddle    =   (first_match_base != first_match_uw);
        enforce     =   (priv_level_eff != M_MODE) || pmpcfg_uw[7] || pmpcfg_base[7];

        case (lsu_ls_i)
            LOAD: pmp_fault_o       =   lsu_valid_i && enforce && (straddle || !pmpcfg_base[0]);
            STORE: pmp_fault_o      =   lsu_valid_i && enforce && (straddle || !pmpcfg_base[1]);
            ATOMIC: pmp_fault_o     =   lsu_valid_i && enforce && (straddle || ~&pmpcfg_base[1:0]);
            default: pmp_fault_o    =   1'b0;
        endcase
    end

endmodule