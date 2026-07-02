`uvm_analysis_imp_decl(_cmd)

class decode_coverage extends uvm_component;
    `uvm_component_utils(decode_coverage)

    uvm_analysis_imp_cmd #(decode_command_transaction, decode_coverage) cmd_export;

    logic [31:0] instr_i;

    covergroup basic_cov;
        opcode : coverpoint instr_i[6:0] {
            bins r_type         =   {R_TYPE_0, R_TYPE_1};
            bins i_type         =   {I_TYPE_0, I_TYPE_1, I_TYPE_2, I_TYPE_3};
            bins s_type         =   {S_TYPE};
            bins b_type         =   {B_TYPE};
            bins u_type         =   {U_TYPE_0, U_TYPE_1};
            bins j_type         =   {J_TYPE};
            bins system_type    =   {SYSTEM_TYPE};
            bins exc_type       =   {[0:127]} with (
                !(item inside {R_TYPE_0, R_TYPE_1, I_TYPE_0, I_TYPE_1, I_TYPE_2, I_TYPE_3, S_TYPE, B_TYPE, U_TYPE_0, U_TYPE_1, J_TYPE, SYSTEM_TYPE})
            );
        }
    endgroup

    covergroup r_type_cov;
        opcode : coverpoint instr_i[6:0] iff (instr_i[6:0] inside {R_TYPE_0, R_TYPE_1}) {
            bins op_64b         =   {R_TYPE_0};
            bins op_32b         =   {R_TYPE_1};
        }

        funct3 : coverpoint instr_i[14:12] iff (instr_i[6:0] inside {R_TYPE_0, R_TYPE_1});

        funct7 : coverpoint instr_i[31:25] iff (instr_i[6:0] inside {R_TYPE_0, R_TYPE_1}) {
            bins zero    = {7'b000_0000};
            bins bit5    = {7'b010_0000};
            bins m_instr = {7'b000_0001};
            bins rest    = {[0:127]} with (!(item inside {7'b000_0000, 7'b010_0000, 7'b000_0001}));
        }

        legal_r_type : cross opcode, funct3, funct7 {
            //base double word operations
            bins ADD    =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b000};
            bins SUB    =   binsof(opcode.op_64b) && binsof(funct7.bit5) && binsof(funct3) intersect {3'b000};
            bins SLL    =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b001};
            bins SLT    =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b010};
            bins SLTU   =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b011};
            bins XOR    =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b100};
            bins SRL    =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b101};
            bins SRA    =   binsof(opcode.op_64b) && binsof(funct7.bit5) && binsof(funct3) intersect {3'b101};
            bins OR     =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b110};
            bins AND    =   binsof(opcode.op_64b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b111};

            //m extension double word operations
            bins MUL    =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b000};
            bins MULH   =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b001};
            bins MULHSU =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b010};
            bins MULHU  =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b011};
            bins DIV    =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b100};
            bins DIVU   =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b101};
            bins REM    =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b110};
            bins REMU   =   binsof(opcode.op_64b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b111};

            //base word operations
            bins ADDW   =   binsof(opcode.op_32b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b000};
            bins SUBW   =   binsof(opcode.op_32b) && binsof(funct7.bit5) && binsof(funct3) intersect {3'b000};
            bins SLLW   =   binsof(opcode.op_32b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b001};
            bins SRLW   =   binsof(opcode.op_32b) && binsof(funct7.zero) && binsof(funct3) intersect {3'b101};
            bins SRAW   =   binsof(opcode.op_32b) && binsof(funct7.bit5) && binsof(funct3) intersect {3'b101};

            //m extension word operations
            bins MULW   =   binsof(opcode.op_32b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b000};
            bins DIVW   =   binsof(opcode.op_32b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b100};
            bins DIVUW  =   binsof(opcode.op_32b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b101};
            bins REMW   =   binsof(opcode.op_32b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b110};
            bins REMUW  =   binsof(opcode.op_32b) && binsof(funct7.m_instr) && binsof(funct3) intersect {3'b111};

            ignore_bins rest    =   !binsof(funct7.zero) && !binsof(funct7.bit5) && !binsof(funct7.m_instr);
        }

        exc_r_type : cross opcode, funct3, funct7 {
            bins r_type_0_funct7_exc     = binsof(opcode.op_64b) && binsof(funct7.rest);
            bins r_type_1_funct7_exc     = binsof(opcode.op_32b) && binsof(funct7.rest);

            bins ADD_SUB_MUL_funct7_exc  = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b000};
            bins SLL_MULH_exc            = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b001};
            bins SLT_MULHSU_exc          = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b010};
            bins SLTU_MULHU_exc          = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b011};
            bins XOR_DIV_exc             = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b100};
            bins SRL_SRA_DIVU_exc        = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b101};
            bins OR_REM_exc              = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b110};
            bins AND_REMU_exc            = binsof(opcode.op_64b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b111};

            bins ADDW_SUBW_MULW_exc      = binsof(opcode.op_32b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b000};
            bins SLLW_exc                = binsof(opcode.op_32b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b001};
            bins DIVW_exc                = binsof(opcode.op_32b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b100};
            bins SRLW_SRAW_DIVUW_exc     = binsof(opcode.op_32b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b101};
            bins REMW_exc                = binsof(opcode.op_32b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b110};
            bins REMUW_exc               = binsof(opcode.op_32b) && binsof(funct7.rest) && binsof(funct3) intersect {3'b111};

            bins R_TYPE_1_funct3_exc     = binsof(opcode.op_32b) && binsof(funct3) intersect {3'b010, 3'b011};
        }
    endgroup

    covergroup i_type_cov;
        opcode : coverpoint instr_i[6:0] iff (instr_i[6:0] inside {I_TYPE_0, I_TYPE_1, I_TYPE_2, I_TYPE_3}) {
            bins I_TYPE_0           =   {I_TYPE_0};
            bins I_TYPE_1           =   {I_TYPE_1};
            bins I_TYPE_2           =   {I_TYPE_2};
            bins I_TYPE_3           =   {I_TYPE_3};
        }

        funct3 : coverpoint instr_i[14:12] iff (instr_i[6:0] inside {I_TYPE_0, I_TYPE_1, I_TYPE_2, I_TYPE_3});

        funct7 : coverpoint instr_i[31:25] iff (instr_i[6:0] inside {I_TYPE_3}) {
            bins zero = {7'b000_0000};
            bins bit5 = {7'b010_0000};
            bins rest = {[0:127]} with (!(item inside {7'b000_0000, 7'b010_0000}));
        }

        funct6 : coverpoint instr_i[31:26] iff (instr_i[6:0] inside {I_TYPE_1}) {
            bins zero = {6'b00_0000};
            bins bit4 = {6'b01_0000};
            bins rest = {[0:63]} with (!(item inside {6'b00_0000, 6'b01_0000}));
        }

        legal_i_type : cross opcode, funct3 {
            bins LB     =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b000};
            bins LH     =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b001};
            bins LW     =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b010};
            bins LD     =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b011};
            bins LBU    =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b100};
            bins LHU    =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b101};
            bins LWU    =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b110};

            bins ADDI   =   binsof(opcode.I_TYPE_1) && binsof(funct3) intersect {3'b000};
            bins SLTI   =   binsof(opcode.I_TYPE_1) && binsof(funct3) intersect {3'b010};
            bins SLTIU  =   binsof(opcode.I_TYPE_1) && binsof(funct3) intersect {3'b011};
            bins XORI   =   binsof(opcode.I_TYPE_1) && binsof(funct3) intersect {3'b100};
            bins ORI    =   binsof(opcode.I_TYPE_1) && binsof(funct3) intersect {3'b110};
            bins ANDI   =   binsof(opcode.I_TYPE_1) && binsof(funct3) intersect {3'b111};

            bins JALR   =   binsof(opcode.I_TYPE_2) && binsof(funct3) intersect {3'b000};

            bins ADDIW  =   binsof(opcode.I_TYPE_3) && binsof(funct3) intersect {3'b000};
        }

        legal_shift_imm : cross opcode, funct3, funct6, funct7 {
            bins SLLI   =   binsof(opcode.I_TYPE_1) && binsof(funct6.zero) && binsof(funct3) intersect {3'b001};
            bins SRLI   =   binsof(opcode.I_TYPE_1) && binsof(funct6.zero) && binsof(funct3) intersect {3'b101};
            bins SRAI   =   binsof(opcode.I_TYPE_1) && binsof(funct6.bit4) && binsof(funct3) intersect {3'b101};
            bins SLLIW  =   binsof(opcode.I_TYPE_3) && binsof(funct7.zero) && binsof(funct3) intersect {3'b001};
            bins SRLIW  =   binsof(opcode.I_TYPE_3) && binsof(funct7.zero) && binsof(funct3) intersect {3'b101};
            bins SRAIW  =   binsof(opcode.I_TYPE_3) && binsof(funct7.bit5) && binsof(funct3) intersect {3'b101};
        }

        exc_i_type : cross opcode, funct3 {
            bins I_TYPE_0_funct3_exc        =   binsof(opcode.I_TYPE_0) && binsof(funct3) intersect {3'b111};
            bins I_TYPE_2_funct3_exc        =   binsof(opcode.I_TYPE_2) && binsof(funct3) intersect {3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
            bins I_TYPE_3_funct3_exc        =   binsof(opcode.I_TYPE_3) && binsof(funct3) intersect {3'b010, 3'b011, 3'b100, 3'b110, 3'b111};
        }

        exc_shift_imm : cross opcode, funct3, funct6, funct7 {
            bins SLLI_funct6_exc   = binsof(opcode.I_TYPE_1) && binsof(funct6.rest) && binsof(funct3) intersect {3'b001};
            bins SRXI_funct6_exc   = binsof(opcode.I_TYPE_1) && binsof(funct6.rest) && binsof(funct3) intersect {3'b101};

            bins SLLIW_funct7_exc  = binsof(opcode.I_TYPE_3) && binsof(funct7.rest) && binsof(funct3) intersect {3'b001};
            bins SRXIW_funct7_exc  = binsof(opcode.I_TYPE_3) && binsof(funct7.rest) && binsof(funct3) intersect {3'b101};
        }
    endgroup

    covergroup s_type_cov;
        funct3 : coverpoint instr_i[14:12] iff(instr_i[6:0] == S_TYPE) {
            bins SB                 =   {3'b000};
            bins SH                 =   {3'b001};
            bins SW                 =   {3'b010};
            bins SD                 =   {3'b011};
            bins S_TYPE_funct3_exc  =   {3'b100, 3'b101, 3'b110, 3'b111};
        }
    endgroup

    covergroup b_type_cov;
        funct3 : coverpoint instr_i[14:12] iff(instr_i[6:0] == B_TYPE) {
            bins BEQ                =   {3'b000};
            bins BNE                =   {3'b001};
            bins BLT                =   {3'b100};
            bins BGE                =   {3'b101};
            bins BLTU               =   {3'b110};
            bins BGEU               =   {3'b111};
            bins B_TYPE_funct3_exc  =   {3'b010, 3'b011};
        }
    endgroup

    covergroup u_type_cov;
        opcode : coverpoint instr_i[6:0] iff(instr_i[6:0] inside {U_TYPE_0, U_TYPE_1}) {
            bins LUI                =   {U_TYPE_0};
            bins AUIPC              =   {U_TYPE_1};
        }
    endgroup

    covergroup j_type_cov;
        opcode : coverpoint instr_i[6:0] iff(instr_i[6:0] == J_TYPE) {
            bins JAL                =   {J_TYPE};
        }
    endgroup

    covergroup system_type_cov;
        opcode : coverpoint instr_i[6:0] iff(instr_i[6:0] == SYSTEM_TYPE) {
            bins system             =   {SYSTEM_TYPE};
        }

        funct3 : coverpoint instr_i[14:12] iff(instr_i[6:0] == SYSTEM_TYPE) {
            bins priv               =   {3'b000};
            bins CSRRW              =   {3'b001};
            bins CSRRS              =   {3'b010};
            bins CSRRC              =   {3'b011};
            bins CSRRWI             =   {3'b101};
            bins CSRRSI             =   {3'b110};
            bins CSRRCI             =   {3'b111};
            bins SYSTEM_funct3_exc  =   {3'b100};
        }

        funct12 : coverpoint instr_i[31:20] iff(instr_i[6:0] == SYSTEM_TYPE && instr_i[14:12] == 3'b000) {
            bins ECALL              =   {12'h000};
            bins EBREAK             =   {12'h001};
            bins MRET               =   {12'h302};
            bins WFI                =   {12'h105};
            bins funct12_exc        =   default;
        }

        priv_instr : cross funct3, funct12 {
            bins ECALL              =   binsof(funct3.priv) && binsof(funct12.ECALL);
            bins EBREAK             =   binsof(funct3.priv) && binsof(funct12.EBREAK);
            bins MRET               =   binsof(funct3.priv) && binsof(funct12.MRET);
            bins WFI                =   binsof(funct3.priv) && binsof(funct12.WFI);
            bins SYSTEM_funct12_exc =   binsof(funct3.priv) && binsof(funct12.funct12_exc);
            ignore_bins non_priv    =   !binsof(funct3.priv);
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);

        cmd_export          =   new("cmd_export", this);

        basic_cov           =   new();
        r_type_cov          =   new();
        i_type_cov          =   new();
        s_type_cov          =   new();
        b_type_cov          =   new();
        u_type_cov          =   new();
        j_type_cov          =   new();
        system_type_cov     =   new();
    endfunction : new

    function void write_cmd(decode_command_transaction cmd);
        instr_i = cmd.instr_i;

        basic_cov.sample();
        r_type_cov.sample();
        i_type_cov.sample();
        s_type_cov.sample();
        b_type_cov.sample();
        u_type_cov.sample();
        j_type_cov.sample();
        system_type_cov.sample();
    endfunction : write_cmd

endclass : decode_coverage