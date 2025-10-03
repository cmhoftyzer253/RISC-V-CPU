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


endpackage

module skid_buffer_32 (
    input logic clk,
    input logic reset,

    //input interface
    input logic         valid_i,
    input logic [31:0]  data_i,
    output logic        ready_o,

    //output interface
    input logic         ready_i,
    output logic        valid_o,
    output logic [31:0] data_o
);

    logic           valid;
    logic [31:0]    data;
    logic           ready;

    logic           b_valid;
    logic [31:0]    b_data;

    logic           buf_en_i;
    logic           buf_en_o;

    assign valid        =   b_valid | valid_i;
    assign data[31:0]   =   ({32{ b_valid}} & b_data[31:0]) | 
                                ({32{~b_valid}} & data_i[31:0]);
    assign ready        =   ~b_valid | ready_i;

    assign buf_en_i     =   valid_i & ~ready_i & ~b_valid;
    assign buf_en_o     =   ready_o & b_valid;

    always_ff @(posedge clk) begin
        if (reset) begin
            b_valid <= 1'b0;
            b_data  <= 32'h0;
        end else if (buf_en_i) begin
            b_valid <= 1'b1;
            b_data  <= data_i;
        end else if (buf_en_o) begin
            b_valid <= 1'b0;
            b_data  <= 32'h0;
        end
    end

    //output assignments
    assign valid_o  = valid;
    assign data_o   = data;
    assign ready_o  = ready;

endmodule

