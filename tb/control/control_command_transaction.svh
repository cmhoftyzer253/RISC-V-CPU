class control_command_transaction extends uvm_sequence_item;
    `uvm_object_utils(control_command_transaction)

    function new(string name = "control_command_transaction");
        super.new(name);
    endfunction : new

    typedef enum {
        R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE, SYSTEM_TYPE
    } instr_type_e;

    rand instr_type_e   instr_type;

    rand logic          r_type_i;
    rand logic          i_type_i;
    rand logic          s_type_i;
    rand logic          b_type_i;
    rand logic          u_type_i;
    rand logic          j_type_i;
    rand logic          system_type_i;

    rand logic [2:0]    instr_funct3_i;
    rand logic [11:0]   instr_funct12_i;
    rand logic [6:0]    instr_opcode_i;

    constraint one_type {
        r_type_i        ==  (instr_type == R_TYPE);
        i_type_i        ==  (instr_type == I_TYPE);
        s_type_i        ==  (instr_type == S_TYPE);
        b_type_i        ==  (instr_type == B_TYPE);
        u_type_i        ==  (instr_type == U_TYPE);
        j_type_i        ==  (instr_type == J_TYPE);
        system_type_i   ==  (instr_type == SYSTEM_TYPE);
    }

    constraint opcode_legal {
        if (r_type_i)
            instr_opcode_i inside {7'h33, 7'h3B};
        
        if (i_type_i)
            instr_opcode_i inside {7'h03, 7'h13, 7'h67, 7'h1B};
        
        if (s_type_i)
            instr_opcode_i == 7'h23;

        if (b_type_i)
            instr_opcode_i == 7'h63;

        if (u_type_i)
            instr_opcode_i inside {7'h37, 7'h17};

        if (j_type_i)
            instr_opcode_i == 7'h6F;

        if (system_type_i)
            instr_opcode_i == 7'h73;
    }

    constraint funct3_legal {
        if (instr_opcode_i == 7'h33)
            instr_funct3_i inside {[0:7]};

        if (instr_opcode_i == 7'h3B)
            instr_funct3_i inside {3'd0, 3'd1, 3'd4, 3'd5, 3'd6, 3'd7};

        if (instr_opcode_i == 7'h03)
            instr_funct3_i inside {[0:6]};

        if (instr_opcode_i == 7'h13)
            instr_funct3_i inside {[0:7]};

        if (instr_opcode_i == 7'h67)
            instr_funct3_i == 3'd0;

        if (instr_opcode_i == 7'h1B)
            instr_funct3_i inside {3'd0, 3'd1, 3'd5};

        if (instr_opcode_i == 7'h23)
            instr_funct3_i inside {[0:3]};

        if (instr_opcode_i == 7'h63)
            instr_funct3_i inside {3'd0, 3'd1, 3'd4, 3'd5, 3'd6, 3'd7};

        if (instr_opcode_i == 7'h73)
            instr_funct3_i inside {3'd0, 3'd1, 3'd2, 3'd3, 3'd5, 3'd6, 3'd7};
    }

    constraint funct7_legal {
        if (r_type_i && instr_opcode_i == 7'h33) {
            if (instr_funct3_i inside {3'd0, 3'd5})
                instr_funct12_i[11:5] inside {7'h00, 7'h20, 7'h01};
            else 
                instr_funct12_i[11:5] inside {7'h00, 7'h01};
        }

        if (r_type_i && instr_opcode_i == 7'h3B) {
            if (instr_funct3_i inside {3'd0, 3'd5})
                instr_funct12_i[11:5] inside {7'h00, 7'h20, 7'h01};
            else if (instr_funct3_i == 3'd1)
                instr_funct12_i[11:5] == 7'h00;
            else 
                instr_funct12_i[11:5] == 7'h01;
        }
    }

    constraint funct12_legal {
        if (system_type_i && instr_funct3_i == 3'd0)
            instr_funct12_i inside {12'h000, 12'h001, 12'h302, 12'h105};
    }

    constraint funct12_defined {
        solve instr_type before instr_funct12_i;
        if (!r_type_i && !(system_type_i && instr_funct3_i == 3'd0))
            instr_funct12_i inside {[0:4095]};
    }

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        control_command_transaction     RHS;
        bit                             same;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to do comparison to null pointer")

        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_compare")

        same    =   super.do_compare(rhs, comparer)             &&
                    (RHS.r_type_i == r_type_i)                  &&
                    (RHS.i_type_i == i_type_i)                  &&
                    (RHS.s_type_i == s_type_i)                  &&
                    (RHS.b_type_i == b_type_i)                  &&
                    (RHS.u_type_i == u_type_i)                  &&
                    (RHS.j_type_i == j_type_i)                  &&
                    (RHS.system_type_i == system_type_i)        &&
                    (RHS.instr_funct3_i == instr_funct3_i)      &&
                    (RHS.instr_funct12_i == instr_funct12_i)    &&
                    (RHS.instr_opcode_i == instr_opcode_i);

        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        control_command_transaction RHS;

        if (rhs == null)
            `uvm_fatal(get_type_name(), "Tried to copy null transaction")
        
        if (!$cast(RHS, rhs))
            `uvm_fatal(get_type_name(), "Failed to cast in do_copy")

        super.do_copy(rhs);
        r_type_i            =   RHS.r_type_i;
        i_type_i            =   RHS.i_type_i;
        s_type_i            =   RHS.s_type_i;
        b_type_i            =   RHS.b_type_i;
        u_type_i            =   RHS.u_type_i;
        j_type_i            =   RHS.j_type_i;
        system_type_i       =   RHS.system_type_i;
        instr_funct3_i      =   RHS.instr_funct3_i;
        instr_funct12_i     =   RHS.instr_funct12_i;
        instr_opcode_i      =   RHS.instr_opcode_i;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf({"r_type_i: %b, i_type_i: %b, s_type_i: %b, b_type_i: %b, u_type_i: %b, j_type_i: %b, system_type_i: %b, ",
            "instr_funct3_i: %b, instr_funct12_i: %b, instr_opcode_i: %b"}, r_type_i, i_type_i, s_type_i, b_type_i, u_type_i, j_type_i,
            system_type_i, instr_funct3_i, instr_funct12_i, instr_opcode_i);

        return s;
    endfunction : convert2string

endclass : control_command_transaction