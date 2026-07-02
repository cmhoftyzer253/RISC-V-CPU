class decode_system_type_command_transaction extends decode_command_transaction;
        `uvm_object_utils(decode_system_type_command_transaction)

    function new(string name = "");
        super.new(name);
    endfunction : new

    rand logic [4:0] rd;
    rand logic [2:0] funct3;
    rand logic [4:0] rs1_uimm;
    rand logic [11:0] csr;

    rand logic [11:0] funct12;

    constraint c_opcode {opcode == SYSTEM_TYPE;}

    constraint c_funct12 {
        funct12 dist {ECALL := 1, EBREAK := 1, MRET := 1, WFI := 1, [0:4095] :/ 1};
    }

    constraint c_funct3 {
        funct3 dist {3'b000 := 120, CSRRW := 30, CSRRS := 30, CSRRC := 30, CSRRWI := 30, CSRRSI := 30, CSRRCI := 30, [0:7] :/ 1};
    }

    constraint c_system_rd {
        (funct3 == 3'b000) -> rd dist {5'b0 := 50, [0:31] :/ 1};
    }

    constraint c_system_rs1_uimm {
        (funct3 == 3'b000) -> rs1_uimm dist {5'b0 := 50, [0:31] :/ 1};
    }

    function void post_randomize();
        if (funct3 == 3'b000)
            instr_i = {funct12, rs1_uimm, funct3, rd, opcode};
        else
            instr_i = {csr, rs1_uimm, funct3, rd, opcode};
    endfunction : post_randomize

endclass : decode_system_type_command_transaction