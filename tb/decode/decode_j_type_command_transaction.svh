class decode_j_type_command_transaction extends decode_command_transaction;
    `uvm_object_utils(decode_j_type_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [4:0] rd;
    rand logic [20:0] imm;

    constraint c_opcode {opcode == J_TYPE;}

    constraint c_imm_0 {imm[0] == 0;}

    function void post_randomize();
        instr_i = {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
    endfunction : post_randomize

endclass : decode_j_type_command_transaction