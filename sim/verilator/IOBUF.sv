module IOBUF #(
    parameter int DRIVE             =   12,
    parameter string IBUF_LOW_PWR   =   "TRUE",
    parameter string IOSTANDARD     =   "DEFAULT",
    parameter string SLEW           =   "SLOW"
) (
    output logic    O,
    inout wire      IO,
    input logic     I,
    input logic     T
);
endmodule