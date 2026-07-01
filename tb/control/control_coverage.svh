`uvm_analysis_imp_decl(_cmd)

class control_coverage extends uvm_component;
    `uvm_component_utils(control_coverage)

    `uvm_analysis_imp_cmd #(control_command_transaction, control_coverage) cmd_export;

    logic           r_type_i;
    logic           i_type_i;
    logic           s_type_i;
    logic           b_type_i;
    logic           u_type_i;
    logic           j_type_i;
    logic           system_type_i;
    logic [2:0]     instr_funct3_i;
    logic [11:0]    instr_funct12_i;
    logic [6:0]     instr_opcode_i;

    covergroup basic_cov;

        instr_type : coverpoint {r_type_i, i_type_i, s_type_i, b_type_i, u_type_i, j_type_i, system_type_i} {
            bins r_type = {7'b100_0000};
            bins i_type = {7'b010_0000};
            bins s_type = {7'b001_0000};
            bins b_type = {7'b000_1000};
            bins u_type = {7'b000_0100};
            bins j_type = {7'b000_0010};
            bins system_type = {7'b000_0001};
        }

        instr_funct3 : coverpoint instr_funct3_i {
            bins funct3[] = {[0:7]};
        }

        instr_funct12 : coverpoint instr_funct12_i iff (instr_opcode_i == 7'h73 && instr_funct3_i == 3'b000) {
            bins ECALL = {12'h000};
            bins EBREAK = {12'h001};
            bins MRET = {12'h302};
            bins WFI = {12'h105};
        }

        instr_funct7 : coverpoint instr_funct12_i[11:5] iff (instr_opcode_i inside {7'h33, 7'h3B}) {
            bins base = {7'b000_0000};
            bins alt = {7'b010_0000};
            bins m = {7'b000_0001};
        }

        instr_opcode : coverpoint instr_opcode_i {
            bins R_TYPE_0 = {7'h33};
            bins R_TYPE_1 = {7'h3B};
            bins I_TYPE_0 = {7'h03};
            bins I_TYPE_1 = {7'h13};
            bins I_TYPE_2 = {7'h67};
            bins I_TYPE_3 = {7'h1B};
            bins S_TYPE = {7'h23};
            bins B_TYPE = {7'h63};
            bins U_TYPE_0 = {7'h37};
            bins U_TYPE_1 = {7'h17};
            bins J_TYPE = {7'h6F};
            bins SYSTEM_TYPE = {7'h73};
        }

    endgroup

    covergroup instr_cov;

        f3_r_type_0 : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h33) {
            bins f3[] = {[0:7]};
        }
        f7_r_type_0 : coverpoint instr_funct12_i[11:5] iff (instr_opcode_i == 7'h33) {
            bins base = {7'b000_0000};
            bins alt = {7'b010_0000};
            bins m = {7'b000_0001};
        }

        r_type_0 : cross f3_r_type_0, f7_r_type_0 {
            option.cross_auto_bin_max = 0;

            bins ADD = binsof(f3_r_type_0) intersect {3'b000} && binsof(f7_r_type_0) intersect {7'b000_0000};
            bins SUB = binsof(f3_r_type_0) intersect {3'b000} && binsof(f7_r_type_0) intersect {7'b010_0000};
            bins SLL = binsof(f3_r_type_0) intersect {3'b001} && binsof(f7_r_type_0) intersect {7'b000_0000};
            bins SLT = binsof(f3_r_type_0) intersect {3'b010} && binsof(f7_r_type_0) intersect {7'b000_0000};
            bins SLTU = binsof(f3_r_type_0) intersect {3'b011} && binsof(f7_r_type_0) intersect {7'b000_0000};
            bins XOR = binsof(f3_r_type_0) intersect {3'b100} && binsof(f7_r_type_0) intersect {7'b000_0000};
            bins SRL = binsof(f3_r_type_0) intersect {3'b101} && binsof(f7_r_type_0) intersect {7'b000_0000};
            bins SRA = binsof(f3_r_type_0) intersect {3'b101} && binsof(f7_r_type_0) intersect {7'b010_0000};
            bins OR = binsof(f3_r_type_0) intersect {3'b110} && binsof(f7_r_type_0) intersect {7'b000_0000};
            bins AND = binsof(f3_r_type_0) intersect {3'b111} && binsof(f7_r_type_0) intersect {7'b000_0000};

            bins MUL = binsof(f3_r_type_0) intersect {3'b000} && binsof(f7_r_type_0) intersect {7'b000_0001};
            bins MULH = binsof(f3_r_type_0) intersect {3'b001} && binsof(f7_r_type_0) intersect {7'b000_0001};
            bins MULHSU = binsof(f3_r_type_0) intersect {3'b010} && binsof(f7_r_type_0) intersect {7'b000_0001};
            bins MULHU = binsof(f3_r_type_0) intersect {3'b011} && binsof(f7_r_type_0) intersect {7'b000_0001};
            bins DIV = binsof(f3_r_type_0) intersect {3'b100} && binsof(f7_r_type_0) intersect {7'b000_0001};
            bins DIVU = binsof(f3_r_type_0) intersect {3'b101} && binsof(f7_r_type_0) intersect {7'b000_0001};
            bins REM = binsof(f3_r_type_0) intersect {3'b110} && binsof(f7_r_type_0) intersect {7'b000_0001};
            bins REMU = binsof(f3_r_type_0) intersect {3'b111} && binsof(f7_r_type_0) intersect {7'b000_0001};
        }

        f3_r_type_1 : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h3B){
            bins f3[] = {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
        }

        f7_r_type_1 : coverpoint instr_funct12_i[11:5] iff (instr_opcode_i == 7'h3B){
            bins base = {7'b000_0000};
            bins alt = {7'b010_0000};
            bins m = {7'b000_0001};
        }

        r_type_1 : cross f3_r_type_1, f7_r_type_1 {
            option.cross_auto_bin_max = 0;

            bins ADDW = binsof(f3_r_type_1) intersect {3'b000} && binsof(f7_r_type_1) intersect {7'b000_0000};
            bins SUBW = binsof(f3_r_type_1) intersect {3'b000} && binsof(f7_r_type_1) intersect {7'b010_0000};
            bins SLLW = binsof(f3_r_type_1) intersect {3'b001} && binsof(f7_r_type_1) intersect {7'b000_0000};
            bins SRLW = binsof(f3_r_type_1) intersect {3'b101} && binsof(f7_r_type_1) intersect {7'b000_0000};
            bins SRAW = binsof(f3_r_type_1) intersect {3'b101} && binsof(f7_r_type_1) intersect {7'b010_0000};

            bins MULW = binsof(f3_r_type_1) intersect {3'b000} && binsof(f7_r_type_1) intersect {7'b000_0001};
            bins DIVW = binsof(f3_r_type_1) intersect {3'b100} && binsof(f7_r_type_1) intersect {7'b000_0001};
            bins DIVUW = binsof(f3_r_type_1) intersect {3'b101} && binsof(f7_r_type_1) intersect {7'b000_0001};
            bins REMW = binsof(f3_r_type_1) intersect {3'b110} && binsof(f7_r_type_1) intersect {7'b000_0001};
            bins REMUW = binsof(f3_r_type_1) intersect {3'b111} && binsof(f7_r_type_1) intersect {7'b000_0001};
        }

        i_type_0 : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h03) {
            bins LB = {3'b000};
            bins LH = {3'b001};
            bins LW = {3'b010};
            bins LD = {3'b011};
            bins LBU = {3'b100};
            bins LHU = {3'b101};
            bins LWU = {3'b110};
        }

        f3_i_type_1 : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h13){
            bins f3[] = {[0:7]};
        }

        f7_i_type_1 : coverpoint instr_funct12_i[11:5] iff (instr_opcode_i == 7'h13){
            wildcard bins logical = {7'b000_000?};
            wildcard bins arithmetic = {7'b010_000?};
            bins other = default;
        }

        i_type_1 : cross f3_i_type_1, f7_i_type_1 {
            option.cross_auto_bin_max = 0;

            bins ADDI = binsof(f3_i_type_1) intersect {3'b000};
            bins SLTI = binsof(f3_i_type_1) intersect {3'b010};
            bins SLTIU = binsof(f3_i_type_1) intersect {3'b011};
            bins XORI = binsof(f3_i_type_1) intersect {3'b100};
            bins ORI = binsof(f3_i_type_1) intersect {3'b110};
            bins ANDI = binsof(f3_i_type_1) intersect {3'b111};

            bins SLLI = binsof(f3_i_type_1) intersect {3'b001} && binsof(f7_i_type_1.logical);
            bins SRLI = binsof(f3_i_type_1) intersect {3'b101} && binsof(f7_i_type_1.logical);
            bins SRAI = binsof(f3_i_type_1) intersect {3'b101} && binsof(f7_i_type_1.arithmetic);
        }

        i_type_2 : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h67) {
            bins JALR = {3'b000};
        }

        f3_i_type_3 : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h1B){
            bins f3[] = {3'b000, 3'b001, 3'b101};
        }

        f7_i_type_3 : coverpoint instr_funct12_i[11:5] iff (instr_opcode_i == 7'h1B) {
            bins base = {7'b000_0000};
            bins alt = {7'b010_0000};
            bins m = {7'b000_0001};
        }

        i_type_3 : cross f3_i_type_3, f7_i_type_3 {
            option.cross_auto_bin_max = 0;

            bins ADDIW = binsof(f3_i_type_3) intersect {3'b000};
            bins SLLIW = binsof(f3_i_type_3) intersect {3'b001} && binsof(f7_i_type_3) intersect {7'b000_0000};
            bins SRLIW = binsof(f3_i_type_3) intersect {3'b101} && binsof(f7_i_type_3) intersect {7'b000_0000};
            bins SRAIW = binsof(f3_i_type_3) intersect {3'b101} && binsof(f7_i_type_3) intersect {7'b010_0000};
        }

        s_type : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h23) {
            bins SB = {3'b000};
            bins SH = {3'b001};
            bins SW = {3'b010};
            bins SD = {3'b011};
        }

        b_type : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h63) {
            bins BEQ = {3'b000};
            bins BNE = {3'b001};
            bins BLT = {3'b100};
            bins BGE = {3'b101};
            bins BLTU = {3'b110};
            bins BGEU = {3'b111};
        }

        u_type_0 : coverpoint instr_opcode_i {
            bins LUI = {7'h37};
        }

        u_type_1 : coverpoint instr_opcode_i {
            bins AUIPC = {7'h17};
        }

        j_type : coverpoint instr_opcode_i {
            bins JAL = {7'h6F};
        }

        f3_system_type : coverpoint instr_funct3_i iff (instr_opcode_i == 7'h73){
            bins f3[] = {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
        }

        f12_system_type : coverpoint instr_funct12_i iff (instr_opcode_i == 7'h73){
            bins ECALL_F12 = {12'h000};
            bins EBREAK_F12 = {12'h001};
            bins MRET_F12 = {12'h302};
            bins WFI_F12 = {12'h105};
            bins CSR_ADDR = default;
        }

        system_type : cross f3_system_type, f12_system_type {
            option.cross_auto_bin_max = 0;

            bins ECALL = binsof(f3_system_type) intersect {3'b000} && binsof(f12_system_type) intersect {12'h000};
            bins EBREAK = binsof(f3_system_type) intersect {3'b000} && binsof(f12_system_type) intersect {12'h001};
            bins MRET = binsof(f3_system_type) intersect {3'b000} && binsof(f12_system_type) intersect {12'h302};
            bins WFI = binsof(f3_system_type) intersect {3'b000} && binsof(f12_system_type) intersect {12'h105};
            bins CSRRW = binsof(f3_system_type) intersect {3'b001};
            bins CSRRS = binsof(f3_system_type) intersect {3'b010};
            bins CSRRC = binsof(f3_system_type) intersect {3'b011};
            bins CSRRWI = binsof(f3_system_type) intersect {3'b101};
            bins CSRRSI = binsof(f3_system_type) intersect {3'b110};
            bins CSRRCI = binsof(f3_system_type) intersect {3'b111};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);

        cmd_export  =   new("cmd_export", this);
        
        basic_cov   =   new();
        instr_cov   =   new();
    endfunction : new

    function void write_cmd(control_command_transaction t);
        r_type_i            =   t.r_type_i;
        i_type_i            =   t.i_type_i;
        s_type_i            =   t.s_type_i;
        b_type_i            =   t.b_type_i;
        u_type_i            =   t.u_type_i;
        j_type_i            =   t.j_type_i;
        system_type_i       =   t.system_type_i;
        instr_funct3_i      =   t.instr_funct3_i;
        instr_funct12_i     =   t.instr_funct12_i;
        instr_opcode_i      =   t.instr_opcode_i;

        basic_cov.sample();
        instr_cov.sample();
    endfunction : write_cmd

endclass : control_coverage