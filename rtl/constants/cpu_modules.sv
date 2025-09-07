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

endpackage