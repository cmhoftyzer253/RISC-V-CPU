interface decode_if;

    logic [31:0]    instr_i;
    logic [4:0]     rs1_o;
    logic [4:0]     rs2_o;
    logic [4:0]     rd_o;
    logic [2:0]     funct3_o;
    logic [11:0]    funct12_o;
    logic [11:0]    csr_addr_o;
    logic           r_type_o;
    logic           i_type_o;
    logic           s_type_o;
    logic           b_type_o;
    logic           u_type_o;
    logic           j_type_o;
    logic           system_type_o;
    logic [63:0]    imm_o;
    logic           exc_valid_o;
    logic [4:0]     exc_code_o;

endinterface