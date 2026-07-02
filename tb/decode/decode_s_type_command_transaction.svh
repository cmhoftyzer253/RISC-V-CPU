class decode_s_type_command_transaction extends decode_command_transaction;
    `uvm_object_utils(decode_s_type_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [2:0] funct3;
    rand logic [4:0] rs1;
    rand logic [4:0] rs2;
    rand logic [11:0] imm;

    constraint c_opcode {
        opcode dist {S_TYPE := 1};
    }

    constraint c_funct3 {
        funct3 dist {SB := 50, SH := 50, SW := 50, SD := 50, [4:7] :/ 1};
    }

    function void post_randomize();
        instr_i = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
    endfunction : post_randomize
    
endclass : decode_s_type_command_transaction