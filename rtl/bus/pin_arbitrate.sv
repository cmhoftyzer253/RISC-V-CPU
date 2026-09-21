module pin_arbitrate(
    inout logic [31:0]      gpio_io,

    input logic [31:0]      iof_en_i,
    input logic [31:0]      iof_sel_i,

    input logic [31:0]      gpio_out_en_i,
    input logic [31:0]      gpio_out_i,
    output logic [31:0]     gpio_in_o,

    input logic             spi_sck_i,
    input logic             spi_sdo_i,
    output logic            spi_sdi_o,
    input logic [3:0]       spi_cs_i
);

    logic [31:0]            gpio_out_eff;
    logic [31:0]            gpio_out_en_eff;
    logic [31:0]            gpio_in_raw;

    always_comb begin
        gpio_out_eff        =   gpio_out_i;

        gpio_out_eff[0]     =   iof_en_i[0] ? spi_sck_i : gpio_out_i[0];
        gpio_out_eff[1]     =   iof_en_i[1] ? spi_sdo_i : gpio_out_i[1];
        gpio_out_eff[3]     =   iof_en_i[3] ? spi_cs_i[0] : gpio_out_i[3];
        gpio_out_eff[4]     =   iof_en_i[4] ? spi_cs_i[1] : gpio_out_i[4];
        gpio_out_eff[5]     =   iof_en_i[5] ? spi_cs_i[2] : gpio_out_i[5];
        gpio_out_eff[6]     =   iof_en_i[6] ? spi_cs_i[3] : gpio_out_i[6];

        gpio_out_en_eff     =   gpio_out_en_i;
        gpio_out_en_eff[0]  =   iof_en_i[0] ? 1'b1 : gpio_out_en_i[0];
        gpio_out_en_eff[1]  =   iof_en_i[1] ? 1'b1 : gpio_out_en_i[1];
        gpio_out_en_eff[2]  =   iof_en_i[2] ? 1'b0 : gpio_out_en_i[2];
        gpio_out_en_eff[3]  =   iof_en_i[3] ? 1'b1 : gpio_out_en_i[3];
        gpio_out_en_eff[4]  =   iof_en_i[4] ? 1'b1 : gpio_out_en_i[4];
        gpio_out_en_eff[5]  =   iof_en_i[5] ? 1'b1 : gpio_out_en_i[5];
        gpio_out_en_eff[6]  =   iof_en_i[6] ? 1'b1 : gpio_out_en_i[6];

        gpio_in_o           =   gpio_in_raw;

        spi_sdi_o           =   iof_en_i[2] ? gpio_in_raw[2] : 1'b0;
    end

    genvar i;

    generate
        for (i=0; i<32; i++) begin
            IOBUF gpio_iobuf (
                .I  (gpio_out_eff[i]),
                .O  (gpio_in_raw[i]),
                .T  (!gpio_out_en_eff[i]),
                .IO (gpio_io[i])
            );
        end
    endgenerate

endmodule