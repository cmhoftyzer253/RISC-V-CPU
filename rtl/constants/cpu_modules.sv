package cpu_modules

    function automatic logic [31:0] get_magnitude (
        input logic [31:0] value,
        input logic is_signed,
        input logic is_negative,
    );
        if (is_signed) begin
            return is_negative ? $unsigned(-$signed(value)) : $unsigned($signed(value));
        end else begin
            return value;
        end
    endfunction

    function automatic logic [63:0] twos_comp 
    (
        input logic [63:0] in,
    );
        return ~in + {63'b0, 1'b1};

    endfunction

endpackage