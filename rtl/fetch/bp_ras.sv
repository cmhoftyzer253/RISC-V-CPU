module ras(
    input logic clk,
    input logic reset,

    input logic         push_i,
    input logic [63:0]  push_addr_i,
    input logic         pop_i,
    output logic [63:0] pop_addr_o,
    output logic        empty_o
);

    logic [63:0]    pop_addr;
    logic           empty;          

    logic [63:0]    ras[16];
    logic [4:0]     sp;

    assign empty        = (sp == 5'b0);
    assign pop_addr     = ({64{~empty}} & ras[sp-1]);

    always_ff @(posedge clk) begin
        if (reset) begin
            sp <= 5'b0;
        end else begin
            if (push_i) begin
                stack[sp] <= push_addr_i;
                if (sp != 5'd16) begin 
                    sp <= sp + 5'd1;
                end
            end else if (pop & sp != 0) begin
                sp <= sp - 5'd1;
            end
        end
    end

    //output assignments
    assign pop_addr_o   = pop_addr;
    assign empty_o      = empty;

endmodule