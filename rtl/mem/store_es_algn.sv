import cpu_defines::*;

module store_es_algn (
    input logic [63:0]      raw_data_i,
    input logic [2:0]       addr_algn_i,
    input logic [1:0]       store_size_i,

    input logic [1:0]       priv_level_i,
    input logic [1:0]       mstatus_mpp_i,
    input logic             mstatus_mprv_i,
    input logic             mstatus_mbe_i,
    input logic             mstatus_sbe_i,
    input logic             mstatus_ube_i,

    output logic [7:0]      store_mask_o,
    output logic [63:0]     store_data_o
);

    logic           mprv_eff;
    logic [1:0]     priv_level_eff;

    logic           be;

    logic [63:0]    store_data_le;
    logic [63:0]    store_data_be;

    always_comb begin
        mprv_eff        =   mstatus_mprv_i && (priv_level_i == M_MODE);
        priv_level_eff  =   mprv_eff ? mstatus_mpp_i : priv_level_i;

        be              =   ((priv_level_eff == M_MODE) && mstatus_mbe_i) ||
                            ((priv_level_eff == S_MODE) && mstatus_sbe_i) ||
                            ((priv_level_eff == U_MODE) && mstatus_ube_i);

        case (store_size_i)
            BYTE: begin
                store_data_le       =   {8{raw_data_i[7:0]}};

                store_mask_o[0]     =   (addr_algn_i == 3'b000);
                store_mask_o[1]     =   (addr_algn_i == 3'b001);
                store_mask_o[2]     =   (addr_algn_i == 3'b010);
                store_mask_o[3]     =   (addr_algn_i == 3'b011);
                store_mask_o[4]     =   (addr_algn_i == 3'b100);
                store_mask_o[5]     =   (addr_algn_i == 3'b101);
                store_mask_o[6]     =   (addr_algn_i == 3'b110);
                store_mask_o[7]     =   (addr_algn_i == 3'b111);
            end
            HALF_WORD: begin
                store_data_le       =   {4{raw_data_i[15:0]}};

                store_mask_o[1:0]   =   {2{addr_algn_i[2:1] == 2'b00}};
                store_mask_o[3:2]   =   {2{addr_algn_i[2:1] == 2'b01}};
                store_mask_o[5:4]   =   {2{addr_algn_i[2:1] == 2'b10}};
                store_mask_o[7:6]   =   {2{addr_algn_i[2:1] == 2'b11}};
            end
            WORD: begin
                store_data_le       =   {2{raw_data_i[31:0]}};
                
                store_mask_o[3:0]   =   {4{!addr_algn_i[2]}};
                store_mask_o[7:4]   =   {4{ addr_algn_i[2]}};
            end
            DOUBLE_WORD: begin
                store_data_le       =   raw_data_i;
                store_mask_o        =   8'hFF;
            end
        endcase

        store_data_be[7:0]      =   store_data_le[63:56];
        store_data_be[15:8]     =   store_data_le[55:48];
        store_data_be[23:16]    =   store_data_le[47:40];
        store_data_be[31:24]    =   store_data_le[39:32];
        store_data_be[39:32]    =   store_data_le[31:24];
        store_data_be[47:40]    =   store_data_le[23:16];
        store_data_be[55:48]    =   store_data_le[15:8];
        store_data_be[63:56]    =   store_data_le[7:0];

        store_data_o            =   be ? store_data_be : store_data_le;
    end

endmodule