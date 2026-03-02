package cpu_modules

    function automatic logic [127:0] twos_comp_128
    (
        input logic [127:0] in
    );
        return ~in + 128'h1;

    endfunction

    function automatic logic [63:0] twos_comp_64 
    (
        input logic [63:0] in
    );
        return ~in + 64'h1;

    endfunction

    function automatic logic [31:0] twos_comp_32
    (
        input logic [31:0] in
    );
        return ~in + 32'h1;

    endfunction

    function automatic bp_cnt_t pht_inc(
        bp_cnt_t c
    );
        unique case (c)
            2'b00:      inc2 = 2'b01;
            2'b01:      inc2 = 2'b10;
            2'b10:      inc2 = 2'b11;
            default:    inc2 = 2'b11;
        endcase

    return inc2;

    endfunction

    function automatic bp_cnt_t pht_dec(
        bp_cnt_t c
    );
        unique case (c)
            2'b11:      dec2 = 2'b10;
            2'b10:      dec2 = 2'b01;
            2'b01:      dec2 = 2'b00;
            default:    dec2 = 2'b00;
        endcase

        return dec2;

    endfunction

    function automatic int unsigned size_bytes (mem_access_size_t s);
        case (s)
            (BYTE):         return 1;
            (HALF_WORD):    return 2;
            (WORD):         return 4;
            (DOUBLE_WORD):  return 8;
            default:        return 0;
        endcase
    endfunction

    function automatic logic bin_to_gc (input logic [3:0] bin_val);
        return bin_val ^ (bin_val >> 1);
    endfunction

    function automatic logic [2:0] exc_priority_encode (input logic [4:0] exc_code);
    case (exc_code)
        5'd3:   return 3'd0; 
        5'd1:   return 3'd1; 
        5'd2:   return 3'd2; 
        5'd0:   return 3'd3; 
        5'd11:  return 3'd4; 
        5'd4, 5'd6: return 3'd5; 
        5'd5, 5'd7: return 3'd6; 
        default: return 3'd7;
    endcase 
endfunction

endpackage

//send interrupt requests on positive edges of switches
module irq_sw_gw (
    input logic     clk,
    input logic     resetn,

    input logic     signal_i,
    output logic    gw_irq_o
);

    always_ff @(posedge clk or negedge reset) begin
        if (~resetn) begin
            signal_q    <=  1'b0;
        end else begin
            signal_q    <=  signal_i;
        end
    end

    assign gw_irq_o     =   signal_i & ~signal_q;

endmodule

module skid_buffer (
    parameter int WIDTH = 32
)(
    input logic clk,
    input logic resetn,

    //input interface
    input logic                 valid_i,
    input logic [WIDTH-1:0]     data_i,
    output logic                ready_o

    //output interface
    input logic                 ready_i,
    output logic                valid_o,
    output logic [WIDTH-1:0]    data_o

);

    logic               b_valid;
    logic [WIDTH-1:0]   b_data;

    logic               fill_sb;
    logic               empty_sb;

    assign valid_o  =   b_valid | valid_i;
    assign data_o   =   b_valid ? b_data : data_i;
    assign ready_o  =   ~b_valid | ready_i;

    assign fill_sb  =   valid_i & ready_o;
    assign empty_sb =   valid_o & ready_i;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            b_valid             <= 1'b0;
            b_data              <= '0;
        end else begin
            if (b_valid & empty_sb) begin
                if (fill_sb) begin
                    b_valid     <= 1'b1;
                    b_data      <= data_i;
                end else begin
                    b_valid     <= 1'b0;
                    b_data      <= '0;
                end
            end else if (~b_valid & fill_sb & ~ready_i) begin
                b_valid         <= 1'b1;
                b_data          <= data_i;
            end
        end
    end

endmodule
