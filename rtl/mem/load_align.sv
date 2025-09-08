import cpu_consts::*;

module load_align (
    input logic [63:0]          addr_i,
    input mem_access_size_t     byte_en_i,
    input logic [63:0]          rd_data_i,
    input logic                 zero_extnd_i,

    output logic [63:0]         rd_data_o
);

    logic [63:0] rd_data;

    always_comb begin
        rd_data[63:0] = 64'h0;

        case (byte_en_i)
            (BYTE): begin
                rd_data[7:0]    =   ({8{addr_i[2:0] == 3'b000}} & rd_data_i[7:0])   |
                                    ({8{addr_i[2:0] == 3'b001}} & rd_data_i[15:8])  |
                                    ({8{addr_i[2:0] == 3'b010}} & rd_data_i[23:16]) |
                                    ({8{addr_i[2:0] == 3'b011}} & rd_data_i[31:24]) |
                                    ({8{addr_i[2:0] == 3'b100}} & rd_data_i[39:32]) |
                                    ({8{addr_i[2:0] == 3'b101}} & rd_data_i[47:40]) |
                                    ({8{addr_i[2:0] == 3'b110}} & rd_data_i[55:48]) |
                                    ({8{addr_i[2:0] == 3'b111}} & rd_data_i[63:56]);

                rd_data[63:8]   =   {56{~zero_extnd_i & rd_data[7]}};
            end
            (HALF_WORD): begin
                rd_data[15:0]   =   ({16{addr_i[2:1] == 2'b00}} & rd_data_i[15:0])  |
                                    ({16{addr_i[2:1] == 2'b01}} & rd_data_i[31:16]) |
                                    ({16{addr_i[2:1] == 2'b10}} & rd_data_i[47:32]) |
                                    ({16{addr_i[2:1] == 2'b11}} & rd_data_i[63:48]);

                rd_data[63:16]  =   {48{~zero_extnd_i & rd_data[15]}};
            end
            (WORD): begin
                rd_data[31:0]   =   ({32{~addr_i[2]}} & rd_data_i[31:0]) |
                                    ({32{ addr_i[2]}} & rd_data_i[63:32]);
                rd_data[63:32]  =   {32{~zero_extnd_i & rd_data[31]}};
            end
            (DOUBLE_WORD):          rd_data[63:0] = rd_data_i[63:0];
            default:                rd_data[63:0] = 64'h0;
        endcase
    end

    assign rd_data_o[63:0] = rd_data[63:0];

endmodule;