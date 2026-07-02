class decode_b_type_command_transaction extends decode_command_transaction;
    `uvm_object_utils(decode_b_type_command_transaction)

    function new(string name = "decode_b_type_command_transaction");
        super.new(name);
    endfunction : new

    rand logic [2:0]    funct3;
    rand logic [4:0]    rs1;
    rand logic [4:0]    rs2;
    rand logic [12:0]   imm;

    constraint c_opcode {opcode == B_TYPE;}

    constraint c_funct3 {
        funct3 dist {
            BEQ := 100, 
            BNE := 100, 
            3'b010 := 1, 
            3'b011 := 1, 
            BLT := 100,
            BGE := 100,
            BLTU := 100,
            BGEU := 100
        };
    }

    constraint c_imm_0 {imm[0] == 1'b0;}

    function void post_randomize();
        instr_i = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
    endfunction : post_randomize

endclass : decode_b_type_command_transaction