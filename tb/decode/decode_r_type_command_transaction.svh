class decode_r_type_command_transaction extends decode_command_transaction;
    `uvm_object_utils(decode_r_type_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [4:0] rd;
    rand logic [2:0] funct3;
    rand logic [4:0] rs1;
    rand logic [4:0] rs2;
    rand logic [6:0] funct7;

    constraint c_opcode {
        opcode dist {R_TYPE_0 := 1, R_TYPE_1 := 1};
    }

    constraint c_funct7 {
        funct7 dist {
            7'b000_0000 := 30,
            7'b010_0000 := 30,
            7'b000_0001 := 30,
            [0:127]     :/ 1
        };
    }

    function void post_randomize();
        instr_i = {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction : post_randomize

endclass : decode_r_type_command_transaction