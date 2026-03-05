import cpu_consts::*;
import cpu_utils::*;

module core (
    input logic             clk,
    input logic             resetn,

    //instruction memory interface
    input logic             ic_arready_i,
    output logic [63:0]     ic_araddr_o,
    output logic [7:0]      ic_arlen_o,
    output logic [2:0]      ic_arsize_o,
    output logic [1:0]      ic_arburst_o,
    output logic            ic_arid_o,
    output logic [2:0]      ic_arprot_o,
    output logic            ic_arvalid_o,

    input logic             ic_rvalid_i,
    input logic [127:0]     ic_rdata_i,
    input logic [1:0]       ic_rresp_i,
    input logic             ic_rlast_i,
    input logic             ic_rid_i,
    output logic            ic_rready_o,

    //data memory interface
    input logic             dc_arready_i,
    output logic [63:0]     dc_araddr_o,
    output logic [7:0]      dc_arlen_o,
    output logic [2:0]      dc_arsize_o,
    output logic [1:0]      dc_arburst_o,
    output logic            dc_arid_o,
    output logic [2:0]      dc_arprot_o,
    output logic            dc_arvalid_o,

    input logic             dc_rvalid_i,
    input logic [127:0]     dc_rdata_i,
    input logic [1:0]       dc_rresp_i,
    input logic             dc_rlast_i,
    input logic             dc_rid_i,
    output logic            dc_rready_o,

    input logic             dc_awready_i,
    input logic             dc_wready_i,
    output logic [63:0]     dc_awaddr_o,
    output logic            dc_awvalid_o,
    output logic [2:0]      dc_awsize_o,
    output logic [7:0]      dc_awlen_o,
    output logic [1:0]      dc_awburst_o,
    output logic            dc_awid_o,
    output logic [127:0]    dc_wdata_o,
    output logic [15:0]     dc_wstrb_o,
    output logic            dc_wvalid_o,
    output logic            dc_wlast_o,

    input logic [1:0]       dc_bresp_i,
    input logic             dc_bvalid_i,
    input logic             dc_bid_i,
    output logic            dc_bready_o,

    //interrupt inputs
    input logic             signal1_i,
    input logic             signal2_i,
    input logic             signal3_i,
    input logic             signal4_i,
    input logic             signal5_i,
    input logic             signal6_i,
    input logic             signal7_i,
    input logic             signal8_i
);

    logic [63:0]            pc_q;
    logic [63:0]            nxt_pc;
    logic [63:0]            pc_incr;
    logic                   bj_pc;

    logic                   flush_fetch;

    logic                   if_pc_ready;
    logic                   if_fetch_ready;

    logic                   if_exc_valid;
    logic [4:0]             if_exc_code;

    logic                   if_req;
    logic [63:0]            if_req_addr;
    logic                   if_ready;
    logic                   if_flush;

    logic                   ic_instr_valid;
    logic [31:0]            ic_instr;
    logic                   ic_exc_valid;
    logic [4:0]             ic_exc_code;

    logic                   id_valid_q;
    logic                   id_instr_valid;
    logic [31:0]            id_instr;
    logic [63:0]            id_pc_q;
    logic [63:0]            id_pc_incr_q;
    logic                   id_exc_valid_q;
    logic [4:0]             id_exc_code_q;

    logic [4:0]             id_rs1;
    logic [4:0]             id_rs2;
    logic [4:0]             id_rd;
    logic [6:0]             id_opcode;
    logic [2:0]             id_funct3;
    logic [11:0]            id_funct12;
    logic [11:0]            id_csr_addr;

    logic                   id_r_type;
    logic                   id_i_type;
    logic                   id_s_type;
    logic                   id_b_type;
    logic                   id_u_type;
    logic                   id_j_type;
    logic                   id_system_type;
    logic [63:0]            id_imm;

    logic                   id_u_exc_valid;
    logic [4:0]             id_u_exc_code;

    logic                   ctrl_pc_sel;
    alu_opr_a_sel_t         ctrl_opa_sel;
    alu_opr_b_sel_t         ctrl_opb_sel;
    logic [3:0]             ctrl_exu_func_sel;
    rd_src_t                ctrl_rd_src;
    logic                   ctrl_csr_en;
    logic                   ctrl_csr_rw;
    logic                   ctrl_data_req;
    mem_access_size_t       ctrl_data_byte;
    bypass_avail_t          ctrl_bypass_avail;
    logic                   ctrl_data_wr;
    logic                   ctrl_zero_extnd;
    logic                   ctrl_rf_wr_en;
    logic                   ctrl_word_op;
    logic                   ctrl_alu_instr;
    logic                   ctrl_mul_instr;
    logic                   ctrl_div_instr;
    logic                   ctrl_mret;
    logic                   ctrl_wfi;
    
    logic                   ctrl_exc_valid;
    logic [4:0]             ctrl_exc_code;

    logic                   wfi_active;
    logic                   wfi_stall;
    logic                   wfi_end;
    logic                   wfi_fetch_flush;
    
    logic [63:0]            id_rs1_rd_data;
    logic [63:0]            id_rs2_rd_data;
    
    logic [63:0]            id_csr_rd_data;

    logic                   csr_mstatus_mie;
    logic                   csr_mie_ext_ire;
    logic                   csr_mie_sw_ire;
    logic                   csr_mie_timer_ire;
    logic                   csr_mie_lcof_ire;

    logic                   csr_mie_ext_irp;
    logic                   csr_mie_sw_irp;
    logic                   csr_mie_timer_irp;
    logic                   csr_mie_lcof_irp;

    logic [63:0]            csr_mtvec;
    logic [63:0]            csr_mepc;

    logic                   csr_exc_valid;
    logic [4:0]             csr_exc_code;

    logic                   flush_decode;

    logic                   csr_wr_en;

    logic                   rd_exu_rs1_bypass_sel;
    logic                   rd_exu_rs2_bypass_sel;

    logic                   rd_wb_rs1_bypass_sel;
    logic                   rd_wb_rs2_bypass_sel;

    logic                   csr_exu_bypass_sel;
    logic                   csr_mem_bypass_sel;
    logic                   csr_wb_bypass_sel;

    logic [63:0]            id_rs1_data;
    logic [63:0]            id_rs2_data;
    logic [63:0]            id_csr_data;

    logic                   id_ready;
    
    logic                   id_stall;

    logic [2:0]             id_u_exc_priority;
    logic [2:0]             ctrl_exc_priority;
    logic [2:0]             csr_exc_priority;

    logic [2:0]             id_exc_valid_vec;
    logic [8:0]             id_exc_priority_vec;
    logic [14:0]            id_exc_code_vec;

    logic [2:0]             id_max_exc_priority;

    logic                   id_exc_valid;
    logic [4:0]             id_exc_code;

    logic                   exu_valid_q;
    logic                   exu_exc_valid_q;
    logic [4:0]             exu_exc_code_q;

    logic                   exu_b_type_q;
    logic [2:0]             exu_funct3_q;
    logic [4:0]             exu_rd_q;

    logic [11:0]            exu_csr_addr_q;
    logic [63:0]            exu_csr_data_q;
    logic                   exu_csr_instr_q;
    logic                   exu_csr_wr_en_q;

    logic [63:0]            exu_rs1_data_q;
    logic [63:0]            exu_rs2_data_q;
    logic [63:0]            exu_instr_imm_q;

    alu_opr_a_sel_t         exu_opr_a_sel_q;
    alu_opr_b_sel_t         exu_opr_b_sel_q;

    logic [3:0]             exu_alu_func_q;
    rd_src_t                exu_rd_src_q;

    logic                   exu_pc_sel_q;
    logic                   exu_data_req_q;
    mem_access_size_t       exu_data_byte_q;
    logic                   exu_data_wr_q;
    logic                   exu_zero_extnd_q;
    logic                   exu_rd_wr_en_q;
    logic                   exu_word_op_q;
    logic                   exu_alu_instr_q;
    logic                   exu_mul_instr_q;
    logic                   exu_div_instr_q;

    bypass_avail_t          exu_bypass_avail_q;

    logic [63:0]            exu_pc_q;
    logic [63:0]            exu_pc_incr_q;

    logic                   exu_valid;
    logic                   exu_ready;
    logic [63:0]            exu_opr_a;
    logic [63:0]            exu_opr_b;

    logic                   exu_valid_res;
    logic [63:0]            exu_res;

    logic                   branch_taken;
    logic                   exu_jump_instr;
    logic                   exu_branch_taken;

    logic                   mem_valid_q;
    logic                   mem_exc_valid_q;
    logic [4:0]             mem_exc_code_q;

    logic [63:0]            mem_rs2_data_q;
    logic [63:0]            mem_instr_imm_q;
    logic [4:0]             mem_rd_q;

    logic                   mem_csr_instr_q;
    logic [11:0]            mem_csr_addr_q;
    logic [63:0]            mem_csr_data_q;
    logic                   mem_csr_wr_en_q;

    logic [63:0]            mem_pc_q;
    logic [63:0]            mem_pc_incr_q;
    rd_src_t                mem_rd_src_q;

    logic                   mem_data_req_q;
    mem_access_size_t       mem_data_byte_q;
    logic                   mem_data_wr_q;
    logic                   mem_zero_extnd_q;
    
    logic                   mem_rf_wr_en_q;
    bypass_avail_t          mem_bypass_avail_q;

    logic [63:0]            mem_alu_res_q;

    logic                   mem_ready;
    
    logic                   dc_ready;
    logic                   dc_req;
    logic [63:0]            dc_addr;
    logic                   dc_wr;
    logic [63:0]            dc_wr_data;
    logic [7:0]             dc_mask;
    logic                   dc_resp_valid;
    logic [63:0]            dc_rd_data;
    logic                   mem_rd_ready;

    logic                   dc_exc_valid;
    logic [4:0]             dc_exc_code;

    logic                   mem_u_exc_valid;
    logic [4:0]             mem_u_exc_code;

    logic                   mem_addr;
    logic                   clint_addr;
    logic                   plic_addr;

    logic                   mem_req;
    logic                   clint_req;
    logic                   plic_req;

    logic [63:0]            mem_rd_data;
    
    logic [63:0]            clint_rd_data;
    logic                   clint_resp_valid;

    logic                   clint_exc_valid;
    logic [4:0]             clint_exc_code;

    logic                   clint_msip_irp;
    logic                   clint_mtip_irp;

    logic [63:0]            clint_mtime;

    logic [63:0]            plic_rd_data;
    logic                   plic_resp_valid;

    logic                   plic_exc_valid;
    logic [4:0]             plic_exc_code;

    logic                   plic_eip;

    logic                   trap_en;
    logic [63:0]            nxt_mepc;
    logic [5:0]             nxt_mcause;
    logic [63:0]            nxt_pc_trap;

    logic                   tc_flush;

    logic                   tc_exc_valid;
    logic [4:0]             tc_exc_code;

    logic                   mem_oob_exc_valid;
    logic [4:0]             mem_oob_exc_code;

    logic [2:0]             oob_exc_priority;
    logic [2:0]             mem_u_exc_priority;
    logic [2:0]             clint_exc_priority;
    logic [2:0]             plic_exc_priority;

    logic [3:0]             mem_exc_valid_vec;
    logic [11:0]            mem_exc_priority_vec;
    logic [19:0]            mem_exc_code_vec;
    
    logic                   mem_exc_valid;
    logic [2:0]             mem_max_exc_priority;
    logic [4:0]             mem_exc_code;

    logic                   nxt_wb_valid;

    logic                   wb_valid_q;

    logic                   wb_valid;
    logic                   wb_valid_mem_resp;

    logic [63:0]            wb_alu_res_q;
    logic [63:0]            wb_instr_imm_q;
    logic [63:0]            wb_pc_incr_q;

    logic [63:0]            wb_mem_rd_data_q;
    logic [63:0]            wb_mem_rd_data;

    logic [63:0]            wb_mem_wr_data;

    logic                   wb_mem_req_q;

    logic                   wb_data_mem_resp_valid;

    logic [11:0]            wb_csr_addr_q;
    logic                   wb_csr_wr_en_q;
    
    rd_src_t                wb_rd_src_q;

    logic                   wb_rf_wr_en_q;
    logic                   wb_rf_wr_en;

    bypass_avail_t          wb_bypass_avail_q;

    logic                   wb_csr_instr_q;
    logic                   wb_csr_wr_en;
    logic                   minstret_incr;
    
    logic [63:0]            wb_wr_data;

    logic [4:0]             wb_rd_q;


    localparam RESET_PC = 64'h0000_0000_0001_0000;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            pc_q <= RESET_PC;
        end else if (if_pc_ready | flush_fetch) begin
            pc_q <= nxt_pc;
        end
    end

    always_comb begin
        pc_incr     =   pc_q + 64'd4;
        bj_pc       =   exu_branch_taken | exu_jump_instr;

        if (trap_en) 
            nxt_pc  =   nxt_pc_trap;
        else if (bj_pc)      
            nxt_pc  =   exu_res;
        else
            nxt_pc  =   pc_incr;
    end

    fetch u_fetch (
        .clk                (clk),
        .resetn             (resetn),
        .pc_i               (pc_q),
        .pc_ready_o         (if_pc_ready),
        .flush_i            (flush_fetch),
        .exc_valid_o        (if_exc_valid),
        .exc_code_o         (if_exc_code),
        .instr_valid_i      (ic_instr_valid),
        .instr_i            (ic_instr),
        .instr_ready_o      (if_fetch_ready),
        .exc_valid_i        (ic_exc_valid),
        .exc_code_i         (ic_exc_code),
        .instr_mem_ready_i  (if_ready),
        .instr_mem_req_o    (if_req),
        .instr_mem_addr_o   (if_req_addr),
        .flush_o            (if_flush),
        .decode_ready_i     (id_ready),
        .instr_valid_o      (id_instr_valid),
        .fetch_instr_o      (id_instr)
    );

    i_cache u_i_cache (
        .clk                (clk),
        .resetn             (resetn),
        .instr_mem_req_i    (if_req),
        .instr_mem_addr_i   (if_req_addr),
        .instr_mem_ready_o  (if_ready),
        .instr_ready_i      (if_fetch_ready),
        .instr_o            (ic_instr),
        .instr_valid_o      (ic_instr_valid),
        .arready_i          (ic_arready_i),
        .araddr_o           (ic_araddr_o),
        .arlen_o            (ic_arlen_o),
        .arsize_o           (ic_arsize_o),
        .arburst_o          (ic_arburst_o), 
        .arid_o             (ic_arid_o),
        .arprot_o           (ic_arprot_o),
        .arvalid_o          (ic_arvalid_o),
        .rvalid_i           (ic_rvalid_i),
        .rdata_i            (ic_rdata_i),
        .rresp_i            (ic_rresp_i),
        .rlast_i            (ic_rlast_i),
        .rid_i              (ic_rid_i),
        .rready_o           (ic_rready_o),
        .flush_i            (if_flush),
        .exc_valid_o        (ic_exc_valid),
        .exc_code_o         (ic_exc_code)
    );

    assign flush_fetch  =   tc_flush | exu_branch_taken | exu_jump_instr | (wfi_fetch_flush & wfi_active);

    //pipeline registers fetch -> decode 
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            id_pc_q             <=  64'h0;
            id_pc_incr_q        <=  64'h0;
        end else if (id_ready) begin
            id_pc_q             <=  pc_q;
            id_pc_incr_q        <=  pc_incr;
        end
    end

    // DECODE 
    decode u_decode (
        .instr_i            (id_instr),
        .rs1_o              (id_rs1),
        .rs2_o              (id_rs2),
        .rd_o               (id_rd),
        .op_o               (id_opcode),
        .funct3_o           (id_funct3),
        .funct12_o          (id_funct12),
        .csr_addr_o         (id_csr_addr),
        .r_type_o           (id_r_type),
        .i_type_o           (id_i_type),
        .s_type_o           (id_s_type),
        .b_type_o           (id_b_type),
        .u_type_o           (id_u_type),
        .j_type_o           (id_j_type),
        .system_type_o      (id_system_type),
        .imm_o              (id_imm),
        .exc_valid_o        (id_u_exc_valid),
        .exc_code_o         (id_u_exc_code)
    );

    control u_control (
        .r_type_i           (id_r_type),
        .i_type_i           (id_i_type),
        .s_type_i           (id_s_type),
        .b_type_i           (id_b_type),
        .u_type_i           (id_u_type),
        .j_type_i           (id_j_type),
        .system_type_i      (id_system_type),
        .instr_funct3_i     (id_funct3),
        .instr_funct12_i    (id_funct12),
        .instr_opcode_i     (id_opcode),
        .pc_sel_o           (ctrl_pc_sel),
        .opa_sel_o          (ctrl_opa_sel),
        .opb_sel_o          (ctrl_opb_sel),
        .exu_func_sel_o     (ctrl_exu_func_sel),
        .rd_src_o           (ctrl_rd_src),
        .csr_en_o           (ctrl_csr_en),
        .csr_rw_o           (ctrl_csr_rw),
        .data_req_o         (ctrl_data_req),
        .data_byte_o        (ctrl_data_byte),
        .bypass_avail_o     (ctrl_bypass_avail),
        .data_wr_o          (ctrl_data_wr),
        .zero_extnd_o       (ctrl_zero_extnd),
        .rf_wr_en_o         (ctrl_rf_wr_en),
        .word_op_o          (ctrl_word_op),
        .alu_instr_o        (ctrl_alu_instr),
        .mul_instr_o        (ctrl_mul_instr),
        .div_instr_o        (ctrl_div_instr),
        .mret_o             (ctrl_mret),
        .wfi_o              (ctrl_wfi),
        .exc_valid_o        (ctrl_exc_valid),
        .exc_code_o         (ctrl_exc_code)
    );

    register_file u_register_file (
        .clk                (clk),
        .resetn             (resetn),
        .rs1_addr_i         (id_rs1),
        .rs2_addr_i         (id_rs2),
        .rs1_data_o         (id_rs1_rd_data),
        .rs2_data_o         (id_rs2_rd_data),
        .rd_addr_i          (wb_rd_q),
        .wr_en_i            (wb_rf_wr_en),
        .wr_data_i          (wb_wr_data)
    );

    csr u_csr (
        .clk                (clk),
        .resetn             (resetn),
        .rd_en_i            (ctrl_csr_en),
        .rd_addr_i          (id_csr_addr),
        .rd_data_o          (id_csr_rd_data),
        .wr_en_i            (wb_csr_wr_en),
        .wr_addr_i          (wb_csr_addr_q),
        .wr_data_i          (wb_alu_res_q),
        .trap_en_i          (trap_en),
        .mret_i             (ctrl_mret),
        .nxt_mepc_i         (nxt_mepc),
        .nxt_mcause_i       (nxt_mcause),
        .mstatus_mie_o      (csr_mstatus_mie),
        .mie_ext_ire_o      (csr_mie_ext_ire),
        .mie_sw_ire_o       (csr_mie_sw_ire),
        .mie_timer_ire_o    (csr_mie_timer_ire),
        .mie_lcof_ire_o     (csr_mie_lcof_ire),
        .mie_ext_irp_o      (csr_mie_ext_irp),
        .mie_sw_irp_o       (csr_mie_sw_irp),
        .mie_timer_irp_o    (csr_mie_timer_irp),
        .mie_lcof_irp_o     (csr_mie_lcof_irp),
        .eip_i              (plic_eip),
        .msip_i             (clint_msip_irp),
        .mtip_i             (clint_mtip_irp),
        .mtvec_o            (csr_mtvec),
        .mepc_o             (csr_mepc),
        .mtime_i            (clint_mtime),
        .minstret_incr_i    (minstret_incr),
        .wfi_end_o          (wfi_end),
        .wfi_fetch_flush_o  (wfi_fetch_flush),
        .exc_valid_o        (csr_exc_valid),
        .exc_code_o         (csr_exc_code)
    );

    // bypassing logic 
    always_comb begin
        id_ready                =   exu_ready & ~wfi_stall & ~id_stall;

        id_valid_q              =   id_instr_valid & ~flush_fetch;

        id_exc_valid_q          =   if_exc_valid & ~flush_fetch;
        id_exc_code_q           =   if_exc_code & ~flush_fetch;

        flush_decode            =   tc_flush | exu_branch_taken | exu_jump_instr;

        csr_wr_en               =   id_valid_q & ctrl_csr_en & (|id_rs1 | ctrl_csr_rw);

        wfi_active              =   id_valid_q & ctrl_wfi;
        wfi_stall               =   wfi_active & ~wfi_end;

        rd_exu_rs1_bypass_sel   =   (id_rs1 == exu_rd_q) & |exu_rd_q & (exu_bypass_avail_q == ALU_BYPASS) & id_valid_q & exu_valid_q;
        rd_exu_rs2_bypass_sel   =   (id_rs2 == exu_rd_q) & |exu_rd_q & (exu_bypass_avail_q == ALU_BYPASS) & id_valid_q & exu_valid_q;
        rd_wb_rs1_bypass_sel    =   (id_rs1 == wb_rd_q)  & |wb_rd_q  & id_valid_q & wb_valid;
        rd_wb_rs2_bypass_sel    =   (id_rs2 == wb_rd_q)  & |wb_rd_q  & id_valid_q & wb_valid;
        
        csr_exu_bypass_sel      =   (id_csr_addr == exu_csr_addr_q) & |exu_csr_addr_q & ctrl_csr_en & exu_csr_instr_q & exu_valid_q;
        csr_mem_bypass_sel      =   (id_csr_addr == mem_csr_addr_q) & |mem_csr_addr_q & ctrl_csr_en & mem_csr_instr_q & mem_valid_q;
        csr_wb_bypass_sel       =   (id_csr_addr == wb_csr_addr_q)  & |wb_csr_addr_q & ctrl_csr_en & wb_csr_instr_q & wb_valid;

        if (rd_exu_rs1_bypass_sel) begin
            id_rs1_data         =   exu_res;
        end else if (rd_wb_rs1_bypass_sel) begin
            id_rs1_data         =   (wb_bypass_avail_q == ALU_BYPASS) ? wb_alu_res_q : wb_load_data;
        end else beginC
            id_rs1_data         =   id_rs1_rd_data;
        end

        if (rd_exu_rs2_bypass_sel) begin
            id_rs2_data         =   exu_res;
        end else if (rd_wb_rs2_bypass_sel) begin
            id_rs2_data         =   (wb_bypass_avail_q == ALU_BYPASS) ? wb_alu_res_q : wb_load_data;
        end else begin
            id_rs2_data         =   id_rs2_rd_data;
        end

        if (csr_exu_bypass_sel) begin
            id_csr_data         =   exu_res;
        end else if (csr_mem_bypass_sel) begin
            id_csr_data         =   mem_alu_res_q;
        end else if (csr_wb_bypass_sel) begin
            id_csr_data         =   wb_alu_res_q;
        end else begin
            id_csr_data         =   id_csr_rd_data;
        end

        id_stall                =   ((id_rs1 == exu_rd_q) | (id_rs2 == exu_rd_q)) & (exu_bypass_avail_q == MEM) & |exu_rd_q & id_valid_q & exu_valid_q;

        id_u_exc_priority     =   exc_priority_encode(id_u_exc_code);
        ctrl_exc_priority       =   exc_priority_encode(ctrl_exc_code);
        csr_exc_priority        =   exc_priority_encode(csr_exc_code);

        id_exc_valid_vec        =   {id_u_exc_valid, ctrl_exc_valid, csr_exc_valid};
        id_exc_priority_vec     =   {id_u_exc_priority, ctrl_exc_priority, csr_exc_priority};
        id_exc_code_vec         =   {id_u_exc_code, ctrl_exc_code, csr_exc_code};

        id_exc_valid            =   id_valid_q & |id_exc_valid_vec;

        id_max_exc_priority     =   3'd7;
        id_exc_code             =   5'd0;
        for (int i=0; i<3; i++) begin
            if (id_exc_valid_vec[i] & (id_exc_priority_vec[i*3 +: 3] < id_max_exc_priority)) begin
                id_max_exc_priority     =   id_exc_priority_vec[i*3 +: 3];
                id_exc_code             =   id_exc_code_vec[i*5 +: 5];
            end
        end
    end

    //valid register decode -> execute
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            exu_valid_q         <=  1'b0;
        end else if (flush_decode) begin
            exu_valid_q         <=  1'b0;
        end else if (exu_ready & ~id_stall) begin
            exu_valid_q         <=  id_valid_q & ~wfi_active;
        end
    end

    //pipeline registers decode -> execute
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            exu_b_type_q        <=  1'b0;
            exu_funct3_q        <=  3'b0;
            exu_rd_q            <=  5'b0;
            exu_csr_addr_q      <=  12'h0;
            exu_csr_data_q      <=  64'h0;
            exu_csr_instr_q     <=  1'b0;
            exu_csr_wr_en_q     <=  1'b0;
            exu_rs1_data_q      <=  64'h0;
            exu_rs2_data_q      <=  64'h0;
            exu_instr_imm_q     <=  64'h0;
            exu_pc_sel_q        <=  1'b0;
            exu_opr_a_sel_q     <=  RS1_OPERAND_A;
            exu_opr_b_sel_q     <=  RS2_OPERAND_B;
            exu_alu_func_q      <=  OP_ADD;
            exu_rd_src_q        <=  ALU_SRC;
            exu_data_req_q      <=  1'b0;
            exu_data_byte_q     <=  BYTE;
            exu_bypass_avail_q  <=  ALU_BYPASS;
            exu_data_wr_q       <=  1'b0;
            exu_zero_extnd_q    <=  1'b0;
            exu_rd_wr_en_q      <=  1'b0;
            exu_word_op_q       <=  1'b0;
            exu_alu_instr_q     <=  1'b0;
            exu_mul_instr_q     <=  1'b0;
            exu_div_instr_q     <=  1'b0;
            exu_pc_q            <=  64'h0;
            exu_pc_incr_q       <=  64'h0;
        end else if (exu_ready & ~id_stall) begin
            exu_b_type_q        <=  id_b_type;
            exu_funct3_q        <=  id_funct3;
            exu_rd_q            <=  id_rd;
            exu_csr_addr_q      <=  id_csr_addr;
            exu_csr_data_q      <=  id_csr_data;
            exu_csr_instr_q     <=  ctrl_csr_en;
            exu_csr_wr_en_q     <=  csr_wr_en;
            exu_rs1_data_q      <=  id_rs1_data;
            exu_rs2_data_q      <=  id_rs2_data;
            exu_instr_imm_q     <=  id_imm;
            exu_pc_sel_q        <=  ctrl_pc_sel;
            exu_opr_a_sel_q     <=  ctrl_opa_sel;
            exu_opr_b_sel_q     <=  ctrl_opb_sel;
            exu_alu_func_q      <=  ctrl_exu_func_sel;
            exu_rd_src_q        <=  ctrl_rd_src;
            exu_data_req_q      <=  ctrl_data_req;
            exu_data_byte_q     <=  ctrl_data_byte;
            exu_bypass_avail_q  <=  ctrl_bypass_avail;
            exu_data_wr_q       <=  ctrl_data_wr;
            exu_zero_extnd_q    <=  ctrl_zero_extnd;
            exu_rd_wr_en_q      <=  ctrl_rf_wr_en;
            exu_word_op_q       <=  ctrl_word_op;
            exu_alu_instr_q     <=  ctrl_alu_instr;
            exu_mul_instr_q     <=  ctrl_mul_instr;
            exu_div_instr_q     <=  ctrl_div_instr;
            exu_pc_q            <=  id_pc_q;
            exu_pc_incr_q       <=  id_pc_incr_q;
        end
    end

    //exception registers decode -> execute
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            exu_exc_valid_q     <= 1'b0;
            exu_exc_code_q      <= 5'd0;
        end else if (flush_decode) begin
            exu_exc_valid_q     <=  1'b0;
            exu_exc_code_q      <=  5'd0;
        end else if (exu_ready & ~id_stall) begin
            exu_exc_valid_q     <= (id_exc_valid_q | id_exc_valid) & ~wfi_active;
            exu_exc_code_q      <= id_exc_valid_q ? id_exc_code_q : id_exc_code;
        end 
    end

    // EXECUTE

    execute u_execute (
        .clk                (clk),
        .resetn             (resetn),
        .valid_instr_i      (exu_valid),
        .exu_ready_o        (exu_ready),
        .flush_i            (tc_flush),
        .opr_a_i            (exu_opr_a),
        .opr_b_i            (exu_opr_b),
        .exu_func_i         (exu_alu_func_q),
        .word_op_i          (exu_word_op_q),
        .mul_instr_i        (exu_mul_instr_q),
        .div_instr_i        (exu_div_instr_q),
        .res_ready_i        (mem_ready),
        .valid_res_o        (exu_valid_res),
        .exu_res_o          (exu_res)
    );

    branch_control u_branch_control (
        .opr_a_i            (exu_opr_a),
        .opr_b_i            (exu_opr_b),
        .is_b_type_i        (exu_b_type_q),
        .instr_funct3_i     (exu_funct3_q),
        .branch_taken_o     (branch_taken)
    );

    always_comb begin
        exu_valid   =   exu_valid_q & ~exu_exc_valid_q;

        case (exu_opr_a_sel_q)
            RS1_OPERAND_A: exu_opr_a    =   exu_rs1_data_q;
            PC_OPERAND_A: exu_opr_a     =   exu_pc_q;
            CSR_OPERAND_A: exu_opr_a    =   exu_csr_data_q; 
        endcase

        case (exu_opr_b_sel_q)
            RS2_OPERAND_B: exu_opr_b    =   exu_rs2_data_q;
            IMM_OPERAND_B: exu_opr_b    =   exu_instr_imm_q;
            RS1_OPERAND_B: exu_opr_b    =   (exu_csr_instr_q & (exu_alu_func_q == OP_AND)) ? ~exu_rs1_data_q : exu_rs1_data_q;
        endcase

        exu_jump_instr      =   exu_pc_sel_q & exu_valid_q & ~exu_exc_valid_q;
        exu_branch_taken    =   branch_taken & exu_valid_q & ~exu_exc_valid_q;
    end

    //valid register execute -> memory
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            mem_valid_q         <=  1'b0;
        end else if (tc_flush) begin
            mem_valid_q         <=  1'b0;
        end else if (mem_ready) begin
            mem_valid_q         <=  exu_valid_q;
        end
    end

    //pipeline registers execute -> memory
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            mem_rs2_data_q      <=  64'h0;
            mem_instr_imm_q     <=  64'h0;
            mem_rd_q            <=  5'b0;
            mem_csr_instr_q     <=  1'b0;
            mem_csr_addr_q      <=  12'h0;
            mem_csr_data_q      <=  64'h0;
            mem_csr_wr_en_q     <=  1'b0;
            mem_pc_q            <=  64'h0;
            mem_pc_incr_q       <=  64'h0;
            mem_rd_src_q        <=  ALU_SRC;
            mem_data_req_q      <=  1'b0;
            mem_data_byte_q     <=  BYTE;
            mem_bypass_avail_q  <=  ALU_BYPASS;
            mem_data_wr_q       <=  1'b0;
            mem_zero_extnd_q    <=  1'b0;
            mem_rf_wr_en_q      <=  1'b0;
            mem_alu_res_q       <=  64'h0;
        end else if (mem_ready) begin
            mem_rs2_data_q      <=  exu_rs2_data_q;
            mem_instr_imm_q     <=  exu_instr_imm_q;
            mem_rd_q            <=  exu_rd_q;
            mem_csr_instr_q     <=  exu_csr_instr_q;
            mem_csr_addr_q      <=  exu_csr_addr_q;
            mem_csr_data_q      <=  exu_csr_data_q;
            mem_csr_wr_en_q     <=  exu_csr_wr_en_q;
            mem_pc_q            <=  exu_pc_q; 
            mem_pc_incr_q       <=  exu_pc_incr_q;
            mem_rd_src_q        <=  exu_rd_src_q;
            mem_data_req_q      <=  exu_data_req_q;
            mem_data_byte_q     <=  exu_data_byte_q;
            mem_bypass_avail_q  <=  exu_bypass_avail_q;
            mem_data_wr_q       <=  exu_data_wr_q;
            mem_zero_extnd_q    <=  exu_zero_extnd_q;
            mem_rf_wr_en_q      <=  exu_rd_wr_en_q;
            mem_alu_res_q       <=  exu_res;
        end
    end

    //exception registers execute -> memory
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            mem_exc_valid_q     <=  1'b0;
            mem_exc_code_q      <=  5'd0;
        end else if (tc_flush) begin
            mem_exc_valid_q     <=  1'b0;
            mem_exc_code_q      <=  5'd0;
        end else if (mem_ready) begin
            mem_exc_valid_q     <=  exu_exc_valid_q;
            mem_exc_code_q      <=  exu_exc_code_q;
        end
    end

    // MEMORY

    memory u_memory (
        .clk                    (clk),
        .resetn                 (resetn),
        .req_valid_i            (mem_req),
        .req_addr_i             (mem_alu_res_q),
        .req_byte_en_i          (mem_data_byte_q),
        .req_wr_i               (mem_data_wr_q),
        .req_zero_extnd_i       (mem_zero_extnd_q),
        .req_wr_data_i          (mem_rs2_data_q),
        .req_ready_o            (mem_ready),
        .data_mem_resp_valid_o  (wb_data_mem_resp_valid),
        .data_mem_rd_data_o     (wb_mem_rd_data),
        .dc_ready_i             (dc_ready),
        .dc_req_o               (dc_req),
        .dc_addr_o              (dc_addr),
        .dc_wr_o                (dc_wr),
        .dc_wr_data_o           (dc_wr_data),
        .dc_mask_o              (dc_mask),
        .dc_resp_valid_i        (dc_resp_valid),
        .dc_rd_data_i           (dc_rd_data),
        .mem_rd_ready_o         (mem_rd_ready),
        .exc_valid_i            (dc_exc_valid),
        .exc_code_i             (dc_exc_code),
        .exc_valid_o            (mem_u_exc_valid),
        .exc_code_o             (mem_u_exc_code)
    );

    d_cache u_d_cache (
        .clk                    (clk),
        .resetn                 (resetn),
        .dc_req_i               (dc_req),
        .dc_addr_i              (dc_addr),
        .dc_wr_i                (dc_wr),
        .dc_wr_data_i           (dc_wr_data),
        .dc_mask_i              (dc_mask),
        .dc_ready_o             (dc_ready),
        .mem_ready_i            (mem_rd_ready),
        .dc_resp_valid_o        (dc_resp_valid),
        .dc_rd_data_o           (dc_rd_data),
        .arready_i              (dc_arready_i),
        .araddr_o               (dc_araddr_o),
        .arlen_o                (dc_arlen_o),
        .arsize_o               (dc_arsize_o),
        .arburst_o              (dc_arburst_o),
        .arid_o                 (dc_arid_o),
        .arprot_o               (dc_arprot_o),
        .arvalid_o              (dc_arvalid_o),
        .rvalid_i               (dc_rvalid_i),
        .rdata_i                (dc_rdata_i),
        .rresp_i                (dc_rresp_i),
        .rlast_i                (dc_rlast_i),
        .rid_i                  (dc_rid_i),
        .rready_o               (dc_rready_o),
        .awready_i              (dc_awready_i),
        .wready_i               (dc_wready_i),
        .awaddr_o               (dc_awaddr_o),
        .awvalid_o              (dc_awvalid_o),
        .awsize_o               (dc_awsize_o),
        .awlen_o                (dc_awlen_o),
        .awburst_o              (dc_awburst_o),
        .awid_o                 (dc_awid_o),
        .wdata_o                (dc_wdata_o),
        .wstrb_o                (dc_wstrb_o),
        .wvalid_o               (dc_wvalid_o),
        .wlast_o                (dc_wlast_o),
        .bresp_i                (dc_bresp_i),
        .bvalid_i               (dc_bvalid_i),
        .bid_i                  (dc_bid_i),
        .bready_o               (dc_bready_o),
        .exc_valid_o            (dc_exc_valid),
        .exc_code_o             (dc_exc_code)
    );

    clint u_clint (
        .clk                    (clk),
        .resetn                 (resetn),
        .req_valid_i            (clint_req),
        .req_addr_i             (mem_alu_res_q),
        .req_byte_en_i          (mem_data_byte_q),
        .req_wr_i               (mem_data_wr_q),
        .req_wr_data_i          (mem_rs2_data_q),
        .clint_rd_data_o        (clint_rd_data),
        .clint_resp_valid_o     (clint_resp_valid),
        .msip_irp_o             (clint_msip_irp),
        .mtip_irp_o             (clint_mtip_irp),
        .exc_valid_o            (clint_exc_valid),
        .exc_code_o             (clint_exc_code),
        .mtime_o                (clint_mtime)
    );

    plic u_plic (
        .clk                    (clk),
        .resetn                 (resetn),
        .req_valid_i            (plic_req),
        .req_addr_i             (mem_alu_res_q),
        .req_byte_en_i          (mem_data_byte_q),
        .req_wr_i               (mem_data_wr_q),
        .req_wr_data_i          (mem_rs2_data_q),
        .plic_rd_data_o         (plic_rd_data),
        .plic_resp_valid_o      (plic_resp_valid),
        .signal1_i              (signal1_i),
        .signal2_i              (signal2_i),
        .signal3_i              (signal3_i),
        .signal4_i              (signal4_i),
        .signal5_i              (signal5_i),
        .signal6_i              (signal6_i),
        .signal7_i              (signal7_i),
        .signal8_i              (signal8_i),
        .eip_o                  (plic_eip),
        .exc_valid_o            (plic_exc_valid),
        .exc_code_o             (plic_exc_code)
    );

    trap_controller u_trap_controller (
        .clk                    (clk),
        .resetn                 (resetn),
        .trap_en_o              (trap_en),
        .flush_o                (tc_flush),
        .nxt_mepc_o             (nxt_mepc),
        .nxt_mcause_o           (nxt_mcause),
        .nxt_pc_o               (nxt_pc_trap),
        .exc_valid_i            (tc_exc_valid),
        .exc_code_i             (tc_exc_code),
        .mem_pc_i               (mem_pc_q),
        .if_pc_ready_i          (if_pc_ready),
        .if_pc_incr_i           (pc_incr),
        .mret_i                 (ctrl_mret),
        .mstatus_mie_i          (csr_mstatus_mie),
        .mie_ext_ire_i          (csr_mie_ext_ire),
        .mie_sw_ire_i           (csr_mie_sw_ire),
        .mie_timer_ire_i        (csr_mie_timer_ire),
        .mie_lcof_ire_i         (csr_mie_lcof_ire),
        .mie_ext_irp_i          (csr_mie_ext_irp),
        .mie_sw_irp_i           (csr_mie_sw_irp),
        .mie_timer_irp_i        (csr_mie_timer_irp),
        .mie_lcof_irp_i         (csr_mie_lcof_irp),
        .mtvec_i                (csr_mtvec),
        .mepc_i                 (csr_mepc)
    );

    always_comb begin
        mem_addr                =   (mem_alu_res_q >= 64'h0000_0000_8000_0000) & (mem_alu_res_q <= 64'h0000_0000_9FFF_FFFF);
        clint_addr              =   (mem_alu_res_q >= 64'h0000_0000_0200_0000) & (mem_alu_res_q <= 64'h0000_0000_0200_FFFF);
        plic_addr               =   (mem_alu_res_q >= 64'h0000_0000_0C00_0000) & (mem_alu_res_q <= 64'h0000_0000_0FFF_FFFF);

        mem_req                 =   mem_valid_q & ~mem_exc_valid_q & mem_data_req_q & mem_addr;
        clint_req               =   mem_valid_q & ~mem_exc_valid_q & mem_data_req_q & clint_addr;
        plic_req                =   mem_valid_q & ~mem_exc_valid_q & mem_data_req_q & plic_addr;

        mem_rd_data             =   ({64{clint_req}} & clint_rd_data)  | 
                                    ({64{plic_req}} & plic_rd_data);

        mem_oob_exc_valid       =   mem_valid_q & mem_data_req_q & ~(mem_addr | clint_addr | plic_addr);
        mem_oob_exc_code        =   mem_data_wr_q ? 5'd7 : 5'd5;

        oob_exc_priority        =   3'd6;
        mem_u_exc_priority      =   exc_priority_encode(mem_u_exc_code);
        clint_exc_priority      =   exc_priority_encode(clint_exc_code);
        plic_exc_priority       =   exc_priority_encode(plic_exc_code);

        mem_exc_valid_vec       =   {mem_oob_exc_valid, mem_u_exc_valid, clint_exc_valid, plic_exc_valid};
        mem_exc_priority_vec    =   {oob_exc_priority, mem_u_exc_priority, clint_exc_priority, plic_exc_priority};
        mem_exc_code_vec        =   {mem_oob_exc_code, mem_u_exc_code, clint_exc_code, plic_exc_code};

        mem_exc_valid           =   mem_valid_q & |mem_exc_valid_vec;

        mem_max_exc_priority    =   3'd7;
        mem_exc_code            =   5'd0;
        for (int i=0; i<4; i++) begin
            if (mem_exc_valid_vec[i] & (mem_exc_priority_vec[i*3 +: 3] < mem_max_exc_priority)) begin
                mem_max_exc_priority    =   mem_exc_priority_vec[i*3 +: 3];
                mem_exc_code            =   mem_exc_code_vec[i*5 +: 5];
            end
        end

        tc_exc_valid            =   mem_exc_valid_q | mem_exc_valid;
        tc_exc_code             =   mem_exc_valid_q ? mem_exc_code_q : mem_exc_code;

        nxt_wb_valid            =   mem_valid_q & ~tc_exc_valid & (~mem_data_req_q | (clint_resp_valid | plic_resp_valid));  
    end

    //valid register memory -> writeback
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            wb_valid_q      <= 1'b0;
        end else begin
            wb_valid_q      <= nxt_wb_valid;
        end
    end

    //pipeline registers memory -> writeback
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            wb_alu_res_q        <=  64'h0;
            wb_instr_imm_q      <=  64'h0;
            wb_mem_rd_data_q    <=  64'h0;
            wb_rd_q             <=  5'b0;
            wb_csr_instr_q      <=  1'b0;
            wb_csr_addr_q       <=  12'h0;
            wb_csr_wr_en_q      <=  1'b0;
            wb_rd_src_q         <=  ALU_SRC;
            wb_pc_incr_q        <=  64'h0;
            wb_rf_wr_en_q       <=  1'b0;
            wb_bypass_avail_q   <=  ALU_BYPASS;
            wb_mem_req_q        <=  1'b0;
        end else begin
            wb_alu_res_q        <=  mem_alu_res_q;
            wb_instr_imm_q      <=  mem_instr_imm_q;
            wb_mem_rd_data_q    <=  mem_rd_data;
            wb_rd_q             <=  mem_rd_q;
            wb_csr_instr_q      <=  mem_csr_instr_q;
            wb_csr_addr_q       <=  mem_csr_addr_q;
            wb_csr_wr_en_q      <=  mem_csr_wr_en_q;
            wb_rd_src_q         <=  mem_rd_src_q;
            wb_pc_incr_q        <=  mem_pc_incr_q;
            wb_rf_wr_en_q       <=  mem_rf_wr_en_q;
            wb_bypass_avail_q   <=  mem_bypass_avail_q;
            wb_mem_req_q        <=  mem_req;
        end
    end

    // WRITEBACK
    always_comb begin
        wb_valid_mem_resp           =   wb_mem_req_q & wb_data_mem_resp_valid;
        wb_valid                    =   wb_valid_q | wb_valid_mem_resp;

        wb_csr_wr_en                =   wb_valid & wb_csr_wr_en_q;
        minstret_incr               =   wb_valid;

        wb_rf_wr_en                 =   wb_rf_wr_en_q & wb_valid;

        wb_wr_data                  =   wb_data_mem_resp_valid ? wb_mem_rd_data : wb_mem_rd_data_q;

        case (wb_rd_src_q)
            ALU_SRC: wb_wr_data     =   wb_alu_res_q;
            MEM_SRC: wb_wr_data     =   wb_wr_data;
            IMM_SRC: wb_wr_data     =   wb_instr_imm_q;
            PC_SRC: wb_wr_data      =   wb_pc_incr_q;
            default: wb_wr_data     =   64'h0;
        endcase
    end

endmodule