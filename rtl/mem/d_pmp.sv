module d_pmp 
    import cpu_defines::*;
(   
    input logic                 lsu_valid_i,

    input logic [63:0]          lsu_addr_i,
    input logic [1:0]           lsu_ls_i,
    input logic [1:0]           lsu_size_i,

    input logic [1:0]           priv_level_i,
    input logic [1:0]           mstatus_mpp_i,
    input logic                 mstatus_mprv_i,

    input logic [63:0]          pmpcfg0_i,
    input logic [63:0]          pmpcfg2_i,
    input logic [15:0][53:0]    pmpaddr_i,
    input logic [15:0][53:0]    pmpaddr_napot_mask_i,

    output logic                pmp_fault_o
);

    logic [1:0]                 priv_level_eff;

    logic [53:0]                addr_base;
    logic [53:0]                addr_uw;

    logic [15:0][7:0]           pmpcfg;

    logic [1:0]                 pmp_a;

    logic [15:0]                ge_base;
    logic [15:0]                ge_uw;
    logic [15:0]                match_base;
    logic [15:0]                match_uw;

    logic [15:0]                match;
    logic [15:0]                low_match_1h;
    logic                       lower_match;
    
    logic [15:0]                straddle;
    logic [15:0]                enforce;
    
    always_comb begin
        priv_level_eff  =   mstatus_mprv_i ? mstatus_mpp_i : priv_level_i;

        addr_base       =   lsu_addr_i[55:2];
        addr_uw         =   {lsu_addr_i[55:3], lsu_addr_i[2] || (lsu_size_i == DOUBLE_WORD)};

        pmpcfg          =   {pmpcfg2_i, pmpcfg0_i};

        for (int i=0; i<16; i++) begin
            ge_base[i]  =   (addr_base >= pmpaddr_i[i]);
            ge_uw[i]    =   ge_base[i] || (addr_uw == pmpaddr_i[i]);
        end

        for (int i=0; i<16; i++) begin
            pmp_a       =   pmpcfg[i][4:3];

            case (pmp_a)
                OFF: begin
                    match_base[i]   =   1'b0;
                    match_uw[i]     =   1'b0;
                end
                TOR: begin
                    match_base[i]   =   (i == 0) ? !ge_base[0] : (ge_base[i-1] && !ge_base[i]);
                    match_uw[i]     =   (i == 0) ? !ge_uw[0] : (ge_uw[i-1] && !ge_uw[i]);
                end
                NA4: begin
                    match_base[i]   =   &(addr_base ~^ pmpaddr_i[i]);
                    match_uw[i]     =   &(addr_uw ~^ pmpaddr_i[i]);
                end
                NAPOT: begin
                    match_base[i]   =   &((addr_base ~^ pmpaddr_i[i]) | pmpaddr_napot_mask_i[i]);
                    match_uw[i]     =   &((addr_uw ~^ pmpaddr_i[i]) | pmpaddr_napot_mask_i[i]);
                end
            endcase
        end

        match       =   match_base | match_uw;

        lower_match = 1'b0;
        for (int i=1; i<16; i++) begin
            low_match_1h[i]     =   match[i] && !lower_match;
            lower_match         =   lower_match || match[i];
        end

        straddle    =   match_base ^ match_uw;
        
        for (int i=0; i<16; i++)
            enforce[i] = (priv_level_eff != M_MODE) || pmpcfg[i][7];


        pmp_fault_o = lsu_valid_i && ~!match && (priv_level_eff != M_MODE);
        for (int i=0; i<16; i++) begin
            case (lsu_ls_i) 
                LSU_LOAD: pmp_fault_o       |=  low_match_1h[i] && lsu_valid_i && (straddle[i] || (enforce[i] && !pmpcfg[i][0]));
                LSU_STORE: pmp_fault_o      |=  low_match_1h[i] && lsu_valid_i && (straddle[i] || (enforce[i] && !pmpcfg[i][1]));
                LSU_ATOMIC: pmp_fault_o     |=  low_match_1h[i] && lsu_valid_i && (straddle[i] || (enforce[i] && (~&pmpcfg[i][1:0])));
                default: pmp_fault_o        |=  1'b0;
            endcase
        end
    end

endmodule