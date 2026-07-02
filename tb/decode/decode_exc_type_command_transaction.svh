class decode_exc_type_command_transaction extends decode_command_transaction;
    `uvm_object_utils(decode_exc_type_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [24:0] upper;

    constraint c_opcode {
        !(opcode inside {R_TYPE_0, R_TYPE_1, I_TYPE_0, I_TYPE_1, I_TYPE_2, I_TYPE_3,
            S_TYPE, B_TYPE, U_TYPE_0, U_TYPE_1, J_TYPE, SYSTEM_TYPE});
    }

    function void post_randomize();
        instr_i = {upper, opcode};
    endfunction : post_randomize

endclass : decode_exc_type_command_transaction