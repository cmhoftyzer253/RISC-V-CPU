class decode_u_type_command_transaction extends decode_command_transaction;
    `uvm_object_utils(decode_u_type_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [4:0] rd;
    rand logic [19:0] imm;

    constraint c_opcode {
        opcode dist {U_TYPE_0 := 1, U_TYPE_1 := 1};
    }

    function void post_randomize();
        instr_i = {imm, rd, opcode};
    endfunction : post_randomize

endclass : decode_u_type_command_transaction