module uart_tx (
    input logic         clk,
    input logic         resetn,

    input logic         txen_i,
    input logic         nstop_i,
    input logic [31:0]  div_i,

    input logic         tx_fifo_empty_i,
    output logic        tx_fifo_pop_o,
    input logic [7:0]   tx_fifo_pop_data_i,

    output logic        tx_o
);

    logic [31:0]        tick_cnt;
    logic               tick;

    logic [2:0]         tx_bit_cnt;
    logic [7:0]         tx_data;

    uart_tx_state_t     state;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tx_data     <=  8'b0;

            tick_cnt    <=  32'h0;
            tx_bit_cnt  <=  3'd0;

            state       <=  UART_TX_IDLE;
        end else begin
            case (state)
                UART_TX_IDLE: begin
                    if (txen_i && !tx_fifo_empty_i) begin
                        tx_data     <=  tx_fifo_pop_data_i;
                        tick_cnt    <=  div_i;

                        state       <=  UART_TX_START;
                    end 
                end
                UART_TX_START: begin
                    if (tick) begin
                        tick_cnt    <=  div_i;
                        tx_bit_cnt  <=  3'd0;

                        state       <=  UART_TX_DATA;
                    end else begin
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end
                end
                UART_TX_DATA: begin
                    if (tick) begin
                        tick_cnt    <=  div_i;
                        tx_bit_cnt  <=  (tx_bit_cnt == 3'd7) ? 3'd0 : tx_bit_cnt + 3'd1;
                        tx_data     <=  {1'b0, tx_data[7:1]};

                        if (tx_bit_cnt == 3'd7)
                            state   <=  UART_TX_STOP;
                    end else begin
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end
                end
                UART_TX_STOP: begin
                    if (tick) begin
                        tick_cnt    <=  div_i;
                        state       <=  nstop_i ? UART_TX_STOP_2 : UART_TX_IDLE;
                    end else begin
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end
                end
                UART_TX_STOP_2: begin
                    if (tick) begin
                        tick_cnt    <=  32'h0;
                        state       <=  UART_TX_IDLE;
                    end else begin
                        tick_cnt    <=  tick_cnt - 32'h1;
                    end
                end
            endcase
        end
    end

    always_comb begin
        tx_o            =   1'b1;
        tx_fifo_pop_o   =   1'b0;

        tick            =   (tick_cnt == 32'h0);

        case (state)
            UART_TX_IDLE: begin
                tx_fifo_pop_o   =   txen_i && !tx_fifo_empty_i;
            end
            UART_TX_START: begin
                tx_o            =   1'b0;
            end
            UART_TX_DATA: begin
                tx_o            =   tx_data[0];
            end
        endcase
    end

endmodule