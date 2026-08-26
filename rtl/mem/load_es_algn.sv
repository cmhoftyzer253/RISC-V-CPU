import cpu_defines::*;

module load_es_algn (
    input logic [63:0]      raw_data_i,
    input logic [2:0]       addr_algn_i,
    input logic [1:0]       load_size_i,
    input logic             load_se_i,

    input logic [1:0]       priv_level_i,
    input logic [1:0]       mstatus_mpp_i,
    input logic             mstatus_mprv_i,
    input logic             mstatus_mbe_i,
    input logic             mstatus_sbe_i,
    input logic             mstatus_ube_i,

    output logic [63:0]     load_data_o
);
    
    logic                   mprv_eff;
    logic [1:0]             priv_level_eff;

    logic                   be;

    logic [63:0]            raw_data_be;
    logic [63:0]            raw_data;

    logic [2:0]             addr_algn_be;
    logic [2:0]             addr_algn;

    always_comb begin
        mprv_eff            =   mstatus_mprv_i && (priv_level_i == M_MODE);
        priv_level_eff      =   mprv_eff ? mstatus_mpp_i : priv_level_i;

        be                  =   ((priv_level_eff == M_MODE) && mstatus_mbe_i) ||
                                ((priv_level_eff == S_MODE) && mstatus_sbe_i) ||
                                ((priv_level_eff == U_MODE) && mstatus_ube_i);

        raw_data_be[7:0]    =   raw_data_i[63:56];
        raw_data_be[15:8]   =   raw_data_i[55:48];
        raw_data_be[23:16]  =   raw_data_i[47:40];
        raw_data_be[31:24]  =   raw_data_i[39:32];
        raw_data_be[39:32]  =   raw_data_i[31:24];
        raw_data_be[47:40]  =   raw_data_i[23:16];
        raw_data_be[55:48]  =   raw_data_i[15:8];
        raw_data_be[63:56]  =   raw_data_i[7:0];

        addr_algn_be        =   addr_algn_i ^ 3'b111;

        raw_data            =   be ? raw_data_be : raw_data_i;
        addr_algn           =   be ? addr_algn_be : addr_algn_i;

        case (load_size_i)
            BYTE: begin
                load_data_o[7:0]        =   ({8{addr_algn == 3'b000}} & raw_data[7:0])     |
                                            ({8{addr_algn == 3'b001}} & raw_data[15:8])    |
                                            ({8{addr_algn == 3'b010}} & raw_data[23:16])   |
                                            ({8{addr_algn == 3'b011}} & raw_data[31:24])   |
                                            ({8{addr_algn == 3'b100}} & raw_data[39:32])   |
                                            ({8{addr_algn == 3'b101}} & raw_data[47:40])   |
                                            ({8{addr_algn == 3'b110}} & raw_data[55:48])   |
                                            ({8{addr_algn == 3'b111}} & raw_data[63:56]);

                load_data_o[63:8]       =   {56{load_se_i & load_data_o[7]}};
            end
            HALF_WORD: begin
                load_data_o[15:0]       =   ({16{addr_algn[2:1] == 2'b00}} & raw_data[15:0])    |
                                            ({16{addr_algn[2:1] == 2'b01}} & raw_data[31:16])   |
                                            ({16{addr_algn[2:1] == 2'b10}} & raw_data[47:32])   |
                                            ({16{addr_algn[2:1] == 2'b11}} & raw_data[63:48]);

                load_data_o[63:16]      =   {48{load_se_i & load_data_o[15]}};
            end
            WORD: begin
                load_data_o[31:0]       =   ({32{!addr_algn[2]}} & raw_data[31:0])   |
                                            ({32{ addr_algn[2]}} & raw_data[63:32]);

                load_data_o[63:32]      =   {32{load_se_i & load_data_o[31]}};
            end
            DOUBLE_WORD: load_data_o    =   raw_data;
        endcase
    end

endmodule