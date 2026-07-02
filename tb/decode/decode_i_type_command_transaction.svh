class decode_i_type_command_transaction extends decode_command_transaction;
    `uvm_object_utils(decode_i_type_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [4:0] rd;
    rand logic [2:0] funct3;
    rand logic [4:0] rs1;
    rand logic [11:0] imm;

    rand logic [4:0] shamt5;
    rand logic [6:0] funct7;

    rand logic [5:0] shamt6;
    rand logic [5:0] funct6;

    constraint c_opcode {
        opcode dist {I_TYPE_0 := 10, I_TYPE_1 := 10, I_TYPE_2 := 1, I_TYPE_3 := 10};
    }

    constraint c_funct7 {
        funct7 dist {7'b000_0000 := 30, 7'b010_0000 := 30, [0:127] :/ 1};
    }

    constraint c_funct6 {
        funct6 dist {6'b00_0000 := 50, 6'b01_0000 := 50, [0:63] :/ 1};
    }

    constraint c_funct3_jalr {
        (opcode == I_TYPE_2) -> funct3 dist {3'b000 := 50, [1:7] :/ 1};
    }

    function void post_randomize();
        if (opcode == I_TYPE_1 && (funct3 == 3'b001 || funct3 == 3'b101))
            instr_i = {funct6, shamt6, rs1, funct3, rd, opcode};
        else if (opcode == I_TYPE_3 && (funct3 == 3'b001 || funct3 == 3'b101))
            instr_i = {funct7, shamt5, rs1, funct3, rd, opcode};
        else
            instr_i = {imm, rs1, funct3, rd, opcode};
    endfunction : post_randomize

endclass : decode_i_type_command_transaction