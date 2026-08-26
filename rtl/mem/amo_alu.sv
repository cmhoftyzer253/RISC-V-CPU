import cpu_defines::*;

module amo_alu (
    input logic [63:0]      lsu_ld_i,    
    input logic [63:0]      rs2_ld_i,    

    input logic [3:0]       atomic_op_i,
    input logic             amo_word_op_i,

    output logic [63:0]     amo_res_o
);

    logic [63:0]    lsu_ld_eff;
    logic [63:0]    rs2_ld_eff;

    always_comb begin
        lsu_ld_eff        =   amo_word_op_i ? {{32{lsu_ld_i[31]}}, lsu_ld_i[31:0]} : lsu_ld_i;
        rs2_ld_eff        =   amo_word_op_i ? {{32{rs2_ld_i[31]}}, rs2_ld_i[31:0]} : rs2_ld_i;

        case (atomic_op_i)
            AMOSWAP: amo_res_o      =   rs2_ld_i;
            AMOADD: amo_res_o       =   lsu_ld_i + rs2_ld_i;
            AMOXOR: amo_res_o       =   lsu_ld_i ^ rs2_ld_i;
            AMOAND: amo_res_o       =   lsu_ld_i & rs2_ld_i;
            AMOOR: amo_res_o        =   lsu_ld_i | rs2_ld_i;
            AMOMIN: amo_res_o       =   ($signed(lsu_ld_eff) <= $signed(rs2_ld_eff)) ? lsu_ld_eff : rs2_ld_eff;
            AMOMAX: amo_res_o       =   ($signed(lsu_ld_eff) <= $signed(rs2_ld_eff)) ? rs2_ld_eff : lsu_ld_eff;
            AMOMINU: amo_res_o      =   (lsu_ld_eff <= rs2_ld_eff) ? lsu_ld_eff : rs2_ld_eff;
            AMOMAXU: amo_res_o      =   (lsu_ld_eff <= rs2_ld_eff) ? rs2_ld_eff : lsu_ld_eff;
            default: amo_res_o      =   rs2_ld_eff;
        endcase
    end

endmodule