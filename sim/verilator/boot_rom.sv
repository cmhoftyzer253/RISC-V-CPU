/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */

module boot_rom (
    input logic             clka,
    input logic             ena,
    input logic [8:0]       addra,
    output logic [63:0]     douta
);
endmodule