module uart_rx (
    input logic             clk,
    input logic             resetn,

    input logic             rxen_i,
    input logic [31:0]      div_i,

    output logic            rx_fifo_push_o,
    output logic [7:0]      rx_fifo_push_data_o,

    input logic             rx_i
);

    logic [31:0]            tick_cnt;
    logic                   tick;

    logic [31:0]            div_half;
    logic [31:0]            div_sixteenth;

    logic [31:0]            rx_sample1;
    logic [31:0]            rx_sample2;
    logic [31:0]            rx_sample3;
    logic                   rx_bit_sample;

    logic [2:0]             rx_bit_cnt;
    logic [1:0]             sample_sum;
    logic [7:0]             rx_data;

    logic                   rx_q;
    logic                   rx_2q;

    uart_rx_state_t         state;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tick_cnt    <=  32'h0;
            rx_bit_cnt  <=  3'd0;

            sample_sum  <=  2'd0;
            rx_data     <=  8'h0;

            rx_q        <=  1'b1;
            rx_2q       <=  1'b1;

            state       <=  UART_RX_IDLE;
        end else begin
            rx_q        <=  rx_i;
            rx_2q       <=  rx_q;

            case (state)
                UART_RX_IDLE: begin
                    if (rxen_i && !rx_2q) begin
                        tick_cnt    <=  div_i;

                        state       <=  UART_RX_START;
                    end
                end
                UART_RX_START: begin
                    if ((tick_cnt == div_half) && rx_2q) begin
                        tick_cnt    <=  32'h0;

                        state       <=  UART_RX_IDLE;
                    end else if (tick) begin
                        tick_cnt    <=  div_i;
                        rx_bit_cnt  <=  3'd0;

                        sample_sum  <=  2'd0;
                        rx_data     <=  8'b0;

                        state <= UART_RX_DATA;
                    end else begin
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end
                end
                UART_RX_DATA: begin
                    if (tick) begin
                        tick_cnt    <=  div_i;
                        rx_bit_cnt  <=  (rx_bit_cnt == 3'd7) ? 3'd0 : rx_bit_cnt + 3'd1;
                        rx_data     <=  {sample_sum[1], rx_data[7:1]};
                        sample_sum  <=  2'd0;

                        if (rx_bit_cnt == 3'd7)
                            state   <=  UART_RX_STOP;
                    end else if (rx_bit_sample) begin
                        sample_sum  <=  sample_sum + rx_2q;
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end else begin
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end
                end
                UART_RX_STOP: begin
                    if (tick) begin
                        tick_cnt    <=  32'h0;

                        state       <=  UART_RX_IDLE;
                    end else begin
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end
                end
            endcase
        end
    end

    always_comb begin
        rx_fifo_push_o          =   1'b0;
        rx_fifo_push_data_o     =   rx_data;

        tick                    =   (tick_cnt == 32'h0);

        div_half                =   (div_i >> 1);
        div_sixteenth           =   (div_i >> 4);

        rx_sample1              =   div_half + div_sixteenth;
        rx_sample2              =   div_half;
        rx_sample3              =   div_half - div_sixteenth;

        rx_bit_sample           =   1'b0;

        case (state)
            UART_RX_DATA: begin
                rx_bit_sample   =   (tick_cnt == rx_sample1) || 
                                    (tick_cnt == rx_sample2) || 
                                    (tick_cnt == rx_sample3);
            end
            UART_RX_STOP: begin
                rx_fifo_push_o  =   tick;
            end
        endcase
    end

endmodule