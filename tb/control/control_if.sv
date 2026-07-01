interface control_if (
    input logic clk
);

    import cpu_consts::*;

    logic               r_type_i            =   '0;
    logic               i_type_i            =   '0;
    logic               s_type_i            =   '0;
    logic               b_type_i            =   '0;
    logic               u_type_i            =   '0;
    logic               j_type_i            =   '0;
    logic               system_type_i       =   '0;

    logic [2:0]         instr_funct3_i      =   '0;
    logic [11:0]        instr_funct12_i     =   '0;
    logic [6:0]         instr_opcode_i      =   '0;

    logic               pc_sel_o;
    alu_opr_a_sel_t     opa_sel_o;
    alu_opr_b_sel_t     opb_sel_o;
    logic [3:0]         exu_func_sel_o;
    rd_src_t            rd_src_o;
    logic               csr_en_o;
    logic               csr_rw_o;
    logic               data_req_o;
    mem_access_size_t   data_byte_o;
    bypass_avail_t      bypass_avail_o;
    logic               data_wr_o;
    logic               zero_extnd_o;
    logic               rf_wr_en_o;
    logic               word_op_o;
    logic               alu_instr_o;
    logic               mul_instr_o;
    logic               div_instr_o;
    logic               mret_o;
    logic               wfi_o;

    logic               exc_valid_o;
    logic [4:0]         exc_code_o;

    clocking mon_cb @(posedge clk);
        default input #1step;
        input r_type_i;
        input i_type_i;
        input s_type_i;
        input b_type_i;
        input u_type_i;
        input j_type_i;
        input system_type_i;
        input instr_funct3_i;
        input instr_funct12_i;
        input instr_opcode_i;
    endclocking : mon_cb

    clocking drv_cb @(posedge clk);
        default output #1ns;
        output r_type_i;
        output i_type_i;
        output s_type_i;
        output b_type_i;
        output u_type_i;
        output j_type_i;
        output system_type_i;
        output instr_funct3_i;
        output instr_funct12_i;
        output instr_opcode_i;
    endclocking : drv_cb

    clocking res_cb @(posedge clk);
        default input #1step;
        input pc_sel_o;
        input opa_sel_o;
        input opb_sel_o;
        input exu_func_sel_o;
        input rd_src_o;
        input csr_en_o;
        input csr_rw_o;
        input data_req_o;
        input data_byte_o;
        input bypass_avail_o;
        input data_wr_o;
        input zero_extnd_o;
        input rf_wr_en_o;
        input word_op_o;
        input alu_instr_o;
        input mul_instr_o;
        input div_instr_o;
        input mret_o;
        input wfi_o;
        input exc_valid_o;
        input exc_code_o;
    endclocking : res_cb

    modport MON (clocking mon_cb, input clk);
    modport DRV (clocking drv_cb, input clk);
    modport RES (clocking res_cb, input clk);

    modport DUT (
        input r_type_i,
        input i_type_i,
        input s_type_i,
        input b_type_i,
        input u_type_i,
        input j_type_i,
        input system_type_i,
        input instr_funct3_i,
        input instr_funct12_i,
        input instr_opcode_i,
        output pc_sel_o,
        output opa_sel_o,
        output opb_sel_o,
        output exu_func_sel_o,
        output rd_src_o,
        output csr_en_o,
        output csr_rw_o,
        output data_req_o,
        output data_byte_o,
        output bypass_avail_o,
        output data_wr_o,
        output zero_extnd_o,
        output rf_wr_en_o,
        output word_op_o,
        output alu_instr_o,
        output mul_instr_o,
        output div_instr_o,
        output mret_o,
        output wfi_o,
        output exc_valid_o,
        output exc_code_o
    );

endinterface