module i_pmp 
    import cpu_defines::*;
    import cpu_utils::*;
(   
    input logic [63:0]          pc_i,

    input logic [1:0]           priv_level_i,

    input logic [63:0]          pmpcfg0_i,
    input logic [63:0]          pmpcfg2_i,

    input logic [15:0][53:0]    pmpaddr_i,
    input logic [15:0][53:0]    pmpaddr_napot_mask_i,

    output logic                pmp_fault_o
);

    logic [53:0]                pc;
    logic [15:0][7:0]           pmpcfg;

    logic [1:0]                 pmp_a;

    logic [15:0]                ge;
    logic [15:0]                match_addr;
    logic [7:0]                 pmpcfg_match;

    always_comb begin
        pc          =   pc_i[55:2];

        pmpcfg      =   {pmpcfg2_i, pmpcfg0_i};

        for (int i=0; i<16; i++) begin
            ge[i]   =   (pc >= pmpaddr_i[i]);
        end

        for (int i=0; i<16; i++) begin
            pmp_a       =   pmpcfg[i][4:3];

            case (pmp_a)
                OFF:            match_addr[i]   =   1'b0;
                TOR:            match_addr[i]   =   (i == 0) ? !ge[0] : (ge[i-1] && !ge[i]);
                NA4:            match_addr[i]   =   &(pc ~^ pmpaddr_i[i]);
                NAPOT:          match_addr[i]   =   &((pc ~^ pmpaddr_i[i]) | pmpaddr_napot_mask_i[i]);
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