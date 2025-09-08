import cpu_consts::*;

module store_align (
    input logic [63:0]          addr_i,
    input mem_access_size_t     byte_en_i,
    input logic [63:0]          wr_data_i,

    output logic [63:0]         wr_data_o
    output logic [7:0]          mask_o,
);

    logic [63:0]    wr_data;
    logic [7:0]     mask;

    always_comb begin
        wr_data[63:0]   = 64'h0;
        mask[7:0]       = 8'b0;

        case (byte_en_i) 
            (BYTE): begin
                wr_data[7:0]    = ({8{addr_i[2:0] == 3'b000}} & wr_data_i[7:0]);
                wr_data[15:8]   = ({8{addr_i[2:0] == 3'b001}} & wr_data_i[7:0]);
                wr_data[23:16]  = ({8{addr_i[2:0] == 3'b010}} & wr_data_i[7:0]);
                wr_data[31:24]  = ({8{addr_i[2:0] == 3'b011}} & wr_data_i[7:0]);
                wr_data[39:32]  = ({8{addr_i[2:0] == 3'b100}} & wr_data_i[7:0]);
                wr_data[47:40]  = ({8{addr_i[2:0] == 3'b101}} & wr_data_i[7:0]);
                wr_data[55:48]  = ({8{addr_i[2:0] == 3'b110}} & wr_data_i[7:0]);
                wr_data[63:56]  = ({8{addr_i[2:0] == 3'b111}} & wr_data_i[7:0]);

                mask[0]         = (addr_i[2:0] == 3'b000);
                mask[1]         = (addr_i[2:0] == 3'b001);
                mask[2]         = (addr_i[2:0] == 3'b010);
                mask[3]         = (addr_i[2:0] == 3'b011);
                mask[4]         = (addr_i[2:0] == 3'b100);
                mask[5]         = (addr_i[2:0] == 3'b101);
                mask[6]         = (addr_i[2:0] == 3'b110);
                mask[7]         = (addr_i[2:0] == 3'b111);
            end
            (HALF_WORD): begin
                wr_data[15:0]   = ({16{addr_i[2:1] == 2'b00}} & wr_data_i[15:0]);
                wr_data[31:16]  = ({16{addr_i[2:1] == 2'b01}} & wr_data_i[15:0]);
                wr_data[47:32]  = ({16{addr_i[2:1] == 2'b10}} & wr_data_i[15:0]);
                wr_data[63:48]  = ({16{addr_i[2:1] == 2'b11}} & wr_data_i[15:0]);

                mask[1:0]       = {2{addr_i[2:1] == 2'b00}};
                mask[3:2]       = {2{addr_i[2:1] == 2'b01}};
                mask[5:4]       = {2{addr_i[2:1] == 2'b10}};
                mask[7:6]       = {2{addr_i[2:1] == 2'b11}};
            end
            (WORD): begin
                wr_data[31:0]   = ({32{~addr_i[2]}} & wr_data_i[31:0]);
                wr_data[63:32]  = ({32{ addr_i[2]}} & wr_data_i[63:31]);

                mask[3:0]       = {4{~addr_i[2]}};
                mask[7:4]       = {4{ addr_i[2]}};
            end
            (DOUBLE_WORD): begin
                wr_data[63:0]   = wr_data_i[63:0];
                mask[7:0]       = 8'b1111_1111;
            end
            default: begin
                wr_data[63:0]   = 64'h0;
                mask[7:0]       = 8'b0000_0000;
            end
        endcase
    end

    assign wr_data_o[63:0]  = wr_data[63:0];
    assign mask_o[7:0]      = mask[7:0];

endmodule