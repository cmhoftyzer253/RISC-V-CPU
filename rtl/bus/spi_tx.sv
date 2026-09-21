import cpu_defines::*;
import cpu_types::*;

module spi_tx (
    input logic             clk,
    input logic             resetn,

    input logic [11:0]      div_i,

    input logic [1:0]       sckmode_i,
    input logic [1:0]       csid_i,
    input logic [3:0]       csdef_i,
    input logic [1:0]       csmode_i,
    input logic [7:0]       cssck_i,
    input logic [7:0]       sckcs_i,
    input logic [7:0]       intercs_i,
    input logic [7:0]       interxfr_i,
    input logic             endian_i,
    input logic             dir_i,
    input logic [3:0]       len_i,

    output logic            rx_fifo_push_o,
    output logic [7:0]      rx_fifo_push_data_o,

    input logic             tx_fifo_empty_i,
    output logic            tx_fifo_pop_o,
    input logic [7:0]       tx_fifo_pop_data_i,

    output logic            sck_o,
    output logic            sdo_o,
    input logic             sdi_i,
    output logic [3:0]      cs_o
);

    logic [11:0]            div_cnt;
    logic [7:0]             spi_delay_cnt;
    logic [2:0]             spi_data_cnt;

    logic [7:0]             tx_data;
    logic [7:0]             rx_data;

    logic                   sck;
    logic                   sck_toggle_suppress;
    logic                   frame_done_q;
    
    logic                   pha;
    logic                   pol;
    logic                   cs_off;
    logic [3:0]             csid_1h;

    logic                   tick;
    logic                   leading_edge;
    logic                   trailing_edge;
    logic                   sck_en;

    logic                   frame_done;
    logic                   rx_data_shift_en;
    logic                   tx_data_shift_en;

    logic                   sckcs_done;
    logic                   intercs_done;
    logic                   clear_div_cnt;

    spi_state_t             state;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            frame_done_q            <=  1'b0;
            sck_toggle_suppress     <=  1'b0;

            div_cnt                 <=  12'h0;
            spi_delay_cnt           <=  8'd0;
            spi_data_cnt            <=  3'd0;

            tx_data                 <=  8'b0;
            rx_data                 <=  8'b0;
            
            sck                     <=  1'b0;

            state                   <=  SPI_IDLE;
        end else begin
            case (state)
                SPI_IDLE: begin
                    frame_done_q    <=  1'b0;

                    if (!tx_fifo_empty_i) begin
                        div_cnt             <=  div_i;
                        tx_data             <=  tx_fifo_pop_data_i;

                        sck                 <=  pol;

                        if (cssck_i == 8'b0) begin
                            if (pha)
                                sck         <=  !pol;
                            
                            spi_data_cnt    <=  3'd0;

                            state           <=  SPI_DATA;
                        end else begin
                            spi_delay_cnt   <=  cssck_i;

                            state           <=  SPI_CSSCK;
                        end
                    end
                end
                SPI_CSSCK: begin
                    div_cnt     <=  (div_cnt == 12'h0) ? div_i : div_cnt - 12'h1;

                    if (sck_en)
                        sck             <=  !sck;

                    if (trailing_edge) begin
                        spi_delay_cnt   <= spi_delay_cnt - 8'b1;

                        if (spi_delay_cnt == 8'b1) begin
                            spi_data_cnt    <=  3'd0;

                            state           <=  SPI_DATA;
                        end
                    end
                end
                SPI_DATA: begin
                    frame_done_q    <=  1'b0;
                    div_cnt         <=  (div_cnt == 12'h0) ? div_i : div_cnt - 12'h1;

                    if (tick)
                        sck         <=  !sck;

                    if (rx_data_shift_en) begin
                        rx_data     <=  endian_i ? {sdi_i, rx_data[7:1]} : {rx_data[6:0], sdi_i};
                    end

                    if (tx_data_shift_en) begin
                        tx_data     <=  endian_i ? {1'b0, tx_data[7:1]} : {tx_data[6:0], 1'b0};
                    end 

                    if (trailing_edge) begin
                        spi_data_cnt        <=  spi_data_cnt + 3'd1;

                        if (frame_done) begin
                            frame_done_q    <=  1'b1;

                            case (csmode_i)
                                AUTO: begin
                                    if ((sckcs_i == 8'b0) && !pha) begin
                                        spi_delay_cnt           <=  intercs_i;

                                        state                   <=  SPI_INTERCS;
                                    end else begin
                                        spi_delay_cnt           <=  sckcs_i;
                                        sck_toggle_suppress     <=  pha;

                                        state                   <=  SPI_SCKCS;
                                    end
                                end
                                HOLD,
                                OFF: begin
                                    if (interxfr_i != 8'b0) begin
                                        spi_delay_cnt   <=  interxfr_i;

                                        state           <=  SPI_INTERXFR;
                                    end else if (tx_fifo_empty_i) begin
                                        state           <=  SPI_HOLD;
                                    end else begin
                                        spi_data_cnt    <=  3'd0;
                                        tx_data         <=  tx_fifo_pop_data_i;
                                    end
                                end
                            endcase
                        end
                    end
                end
                SPI_SCKCS: begin
                    frame_done_q    <=  1'b0;
                    div_cnt         <=  (div_cnt == 12'h0) ? div_i : div_cnt - 12'h1;

                    if (tick)
                        sck_toggle_suppress     <=  1'b0;

                    if (sck_en) 
                        sck                     <=  !sck;

                    if (trailing_edge)
                        spi_delay_cnt           <=  spi_delay_cnt - 8'd1;

                    if (sckcs_done) begin
                        spi_delay_cnt           <=  intercs_i;
                        state                   <=  SPI_INTERCS;
                    end
                end
                SPI_INTERCS: begin
                    frame_done_q        <=  1'b0;
                    div_cnt             <=  (clear_div_cnt) ? div_i : div_cnt - 12'h1;

                    if (sck_en) 
                        sck             <=  !sck;

                    if (trailing_edge)
                        spi_delay_cnt   <=  spi_delay_cnt - 8'b1;

                    if (intercs_done) begin
                        if (tx_fifo_empty_i) begin
                            state               <=  SPI_IDLE;
                        end else begin
                            tx_data             <=  tx_fifo_pop_data_i;

                            if (cssck_i == 8'b0) begin
                                sck             <=  pha ? !pol : pol;
                                spi_data_cnt    <=  3'd0;

                                state           <=  SPI_DATA;
                            end else begin
                                sck             <=  pol;
                                spi_delay_cnt   <=  cssck_i;

                                state           <=  SPI_CSSCK;
                            end
                        end
                    end
                end
                SPI_INTERXFR: begin
                    frame_done_q    <=  1'b0;
                    div_cnt         <=  (div_cnt == 12'h0) ? div_i : div_cnt - 12'h1;

                    if (tick)
                        sck         <=  !sck;

                    if (trailing_edge) begin
                        spi_delay_cnt           <=  spi_delay_cnt - 8'b1;

                        if (spi_delay_cnt == 8'b1) begin
                            if (!tx_fifo_empty_i) begin
                                spi_data_cnt    <=  3'd0;
                                tx_data         <=  tx_fifo_pop_data_i;

                                state           <=  SPI_DATA;
                            end else begin
                                state           <=  SPI_HOLD;
                            end
                        end
                    end
                end
                SPI_HOLD: begin
                    frame_done_q        <=  1'b0;

                    if (csmode_i == AUTO) begin
                        state           <=  SPI_IDLE;
                    end else if (!tx_fifo_empty_i) begin
                        spi_data_cnt                <=  3'd0;
                        tx_data                     <=  tx_fifo_pop_data_i;

                        state                       <=  SPI_DATA;
                    end
                end
            endcase
        end
    end

    always_comb begin
        pha                     =   sckmode_i[0];
        pol                     =   sckmode_i[1];

        sck_o                   =   pol;
        sdo_o                   =   1'b0;
        cs_o                    =   csdef_i;

        tx_fifo_pop_o           =   1'b0;

        rx_fifo_push_o          =   frame_done_q && !dir_i;
        rx_fifo_push_data_o     =   endian_i ? (rx_data >> (4'd8 - len_i)) : (rx_data << (4'd8 - len_i));

        tick                    =   (div_cnt == 12'h0);

        leading_edge            =   tick && (sck == pol);
        trailing_edge           =   tick && (sck != pol);

        cs_off                  =   (csmode_i == OFF);

        sck_en                  =   1'b0;

        frame_done              =   1'b0;
        rx_data_shift_en        =   1'b0;
        tx_data_shift_en        =   1'b0;

        sckcs_done              =   1'b0;
        intercs_done            =   1'b0;

        clear_div_cnt           =   1'b0;

        case (csid_i)
            2'b00: csid_1h = 4'b0001;
            2'b01: csid_1h = 4'b0010;
            2'b10: csid_1h = 4'b0100;
            2'b11: csid_1h = 4'b1000;
        endcase

        case (state)
            SPI_IDLE: begin
                tx_fifo_pop_o       =   !tx_fifo_empty_i;
            end
            SPI_CSSCK: begin
                cs_o                =   csdef_i ^ (cs_off ? 4'b0 : csid_1h);
                sck_en              =   tick && !(pha && trailing_edge && (spi_delay_cnt == 8'b1));
            end
            SPI_DATA: begin
                sck_o               =   sck;
                sdo_o               =   endian_i ? tx_data[0] : tx_data[7];
                cs_o                =   csdef_i ^ (cs_off ? 4'b0 : csid_1h);

                frame_done          =   trailing_edge && ({1'b0, spi_data_cnt} == (len_i - 4'd1));

                rx_data_shift_en    =   !pha && leading_edge || pha && trailing_edge;
                tx_data_shift_en    =   (pha && leading_edge && (spi_data_cnt != 3'd0)) || 
                                        !pha && trailing_edge;

                tx_fifo_pop_o       =   frame_done && ((csmode_i == HOLD) || (csmode_i == OFF)) && (interxfr_i == 8'b0) && !tx_fifo_empty_i;
            end
            SPI_SCKCS: begin
                cs_o                =   csdef_i ^ (cs_off ? 4'b0 : csid_1h);

                sck_en              =   tick && !sck_toggle_suppress;
                sckcs_done          =   (sck_toggle_suppress && tick && (spi_delay_cnt == 8'b0)) ||
                                        (trailing_edge && (spi_delay_cnt == 8'd1));
            end
            SPI_INTERCS: begin
                intercs_done        =   (spi_delay_cnt == 8'b0) || (trailing_edge && (spi_delay_cnt == 8'b1));
                clear_div_cnt       =   intercs_done || (div_cnt == 12'h0);

                tx_fifo_pop_o       =   intercs_done && !tx_fifo_empty_i;

                sck_en              =   tick && (spi_delay_cnt != 8'b0);
            end
            SPI_INTERXFR: begin
                cs_o                =   csdef_i ^ (cs_off ? 4'b0 : csid_1h);
                tx_fifo_pop_o       =   trailing_edge && (spi_delay_cnt == 8'b1) && !tx_fifo_empty_i;
            end
            SPI_HOLD: begin
                cs_o                =   csdef_i ^ ((csmode_i == HOLD) ? csid_1h : 4'b0);
                tx_fifo_pop_o       =   !tx_fifo_empty_i && ((csmode_i == HOLD) || (csmode_i == OFF));
            end
        endcase
    end

endmodule