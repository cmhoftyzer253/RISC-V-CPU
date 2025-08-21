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

endpackage