import cpu_consts::*;
import cpu_modules::*;

module core #(
    parameter logic [63:0] RESET_PC = 64'h0000_0000_0000_0000      //TODO - placeholder value for now
    )(
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
    output logic            ic_arvalid_o

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
    output logic [127:0]    dc_awid_o,
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

    logic [63:0] pc_q;
    logic [63:0] nxt_pc;

    // FETCH

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            pc_q <= 64'h0;
        end else if (if_pc_ready) begin
            pc_q <= nxt_pc;
        end
    end

    always_comb begin
        pc_incr = pc_q + 64'd4;
    end

    fetch u_fetch (
        .clk                (clk),
        .resetn             (resetn),
        .pc_i               (pc_q),
        .pc_ready_o         (if_pc_ready),
        .flush_i            (),
        .exc_valid_o        (if_cache_exc_valid),
        .exc_code_o         (if_cache_exc_code),
        .instr_valid_i      (if_cache_instr_valid),
        .instr_i            (if_cache_instr),
        .instr_ready_o      (if_fetch_ready),
        .exc_valid_i        (if_exc_valid),
        .exc_code_i         (if_exc_code),
        .instr_mem_ready_i  (if_cache_ready),
        .instr_mem_req_o    (if_cache_req),
        .instr_mem_addr_o   (if_cache_req_addr),
        .flush_o            (if_cache_flush),
        .decode_ready_i     (decode_ready),
        .instr_valid_o      (if_instr_valid),
        .fetch_instr_o      (if_instr),
    );

    i_cache #(.ID_W(1))u_i_cache (
        .clk                (clk),
        .resetn             (resetn),
        .instr_mem_req_i    (if_cache_req),
        .instr_mem_addr_i   (if_cache_req_addr),
        .instr_mem_ready_o  (if_cache_ready),
        .instr_ready_i      (if_fetch_ready),
        .instr_o            (if_cache_instr),
        .instr_valid_o      (if_cache_instr_valid),
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
        .flush_i            (if_cache_flush),
        .exc_valid_o        (if_cache_exc_valid),
        .exc_code_o         (if_cache_exc_code)
    );

    //valid register fetch -> decode
    always_ff @(posedge clk or negedge reset) begin
        if (~resetn) begin
            id_valid_q          <=  1'b0;
        end else if (decode_ready) begin
            id_valid_q          <=  if_instr_valid & ~if_exc_valid;
        end
    end

    //pipeline registers fetch -> decode 
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            id_instr_q          <=  64'h0;
            id_pc_q             <=  64'h0;
            id_pc_incr_q        <=  64'h0;
        end else if (decode_ready) begin
            id_instr_q          <=  if_instr;
            id_pc_q             <=  pc_q;
            id_pc_incr_q        <=  pc_incr;
        end
    end

    //exception registers fetch -> decode
    always_ff @(posedge clk or negedge reset) begin
        if (~resetn) begin
            id_exc_valid_q      <=  1'b0;
            id_exc_code_q       <=  5'b0;
        end else if (decode_ready) begin
            id_exc_valid_q      <=  if_exc_valid;
            id_exc_code_q       <=  if_exc_code;
        end 
    end

    // DECODE 

    decode u_decode (
        .instr_i            (id_pc_q),
        .rs1_o              (id_rs1),
        .rs2_o              (id_rs2),
        .rd_o               (id_rd),
        .op_o               (id_opcode),
        .funct3_o           (id_funct3),
        .funct7_o           (id_funct7),
        .csr_addr_o         (id_csr_addr),
        .r_type_o           (id_r_type),
        .i_type_o           (id_i_type),
        .s_type_o           (id_s_type),
        .b_type_o           (id_b_type),
        .u_type_o           (id_u_type),
        .j_type_o           (id_j_type),
        .zicsr_type_o       (id_zicsr_type),
        .imm_o              (id_imm),
        .exc_valid_o        (decode_exc_valid),
        .exc_code_o         (decode_exc_code)
    );

    control u_control (
        .r_type_i           (id_r_type),
        .i_type_i           (id_i_type),
        .s_type_i           (id_s_type),
        .b_type_i           (id_b_type),
        .u_type_i           (id_u_type),
        .j_type_i           (id_j_type),
        .zicsr_type_i       (id_zicsr_type),
        .instr_funct3_i     (id_funct3),
        .instr_funct7_i     (id_funct7),
        .instr_opcode_i     (id_opcode),
        .pc_sel_o           (ctrl_pc_sel),
        .opa_sel_o          (ctrl_opa_sel),
        .opb_sel_o          (ctrl_opb_sel),
        .exu_func_sel_o     (ctrl_exu_func_sel),
        .rd_src_o           (ctrl_rd_src),
        .csr_en_o           (ctrl_csr_en),
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
        .exc_valid_o        (ctrl_exc_valid),
        .exc_code_o         (ctrl_exc_code)
    );

    register_file u_register_file (
        .clk                (clk),
        .resetn             (resetn),
        .rs1_addr_i         (id_rs1),
        .rs2_addr_i         (id_rs2),
        .rs1_data_o         (id_rs1_fetch),
        .rs2_data_o         (id_rs2_fetch),
        .rd_addr_i          (),
        .wr_en_i            (),
        .wr_data_i          ()
    );

    csr u_csr (
        .clk                (clk),
        .resetn             (resetn),
        .rd_en_i            (ctrl_csr_en),
        .rd_addr_i          (id_csr_addr),
        .rd_data_o          (id_csr_fetch),
        .wr_en_i            (),
        .wr_addr_i          (),
        .wr_data_i          (),
        .flush_i            (),
        .exc_valid_o        (csr_exc_valid),
        .exc_code_o         (csr_exc_code),
        .mtime_i            ()
    );

    // bypassing logic 
    always_comb begin
        rd_exu_rs1_bypass_sel   =   (id_rs1_q == exu_rd_q) & |exu_rd_q & (exu_bypass_avail_q == ALU_BYPASS) & id_valid_q & exu_valid_q;
        rd_exu_rs2_bypass_sel   =   (id_rs2_q == exu_rd_q) & |exu_rd_q & (exu_bypass_avail_q == ALU_BYPASS) & id_valid_q & exu_valid_q;
        rd_mem_rs1_bypass_sel   =   (id_rs1_q == mem_rd_q) & |mem_rd_q & id_valid_q & mem_valid_q;
        rd_mem_rs2_bypass_sel   =   (id_rs2_q == mem_rd_q) & |mem_rd_q & id_valid_q & mem_valid_q;
        rd_wb_rs1_bypass_sel    =   (id_rs1_q == wb_rd_q)  & |wb_rd_q  & id_valid_q & wb_valid_q;
        rd_wb_rs2_bypass_sel    =   (id_rs2_q == wb_rd_q)  & |wb_rd_q  & id_valid_q & wb_valid_q;
        
        csr_exu_bypass_sel      =   (id_csr_addr == exu_csr_addr_q) & |exu_csr_addr_q & ctrl_csr_en & exu_csr_instr_q;
        csr_mem_bypass_sel      =   (id_csr_addr == mem_csr_addr_q) & |mem_csr_addr_q & ctrl_csr_en & mem_csr_instr_q;
        csr_wb_bypass_sel       =   (id_csr_addr == wb_csr_addr_q)  & |mem_csr_addr_q & ctrl_csr_en & wb_csr_instr_q;

        //TODO: assign these signals when we name them (memory output, writeback data)
        if (rd_exu_rs1_bypass_sel) begin
            id_rs1_data         =   exu_res;
        end else if (rd_mem_rs1_bypass_sel) begin
            id_rs1_data         =   ;
        end else if (rd_wb_rs1_bypass_sel) begin
            id_rs1_data         =   ;
        end else begin
            id_rs1_data         =   id_rs1_fetch;
        end

        if (rd_exu_rs2_bypass_sel) begin
            id_rs2_data         =   exu_res;
        end else if (rd_mem_rs2_bypass_sel) begin
            id_rs2_data         =   ;
        end else if (rd_wb_rs2_bypass_sel) begin
            id_rs2_data         =   ;
        end else begin
            id_rs2_data         =   id_rs2_fetch;
        end

        if (csr_exu_bypass_sel) begin
            id_csr_data         =   exu_res;
        end else if (csr_mem_bypass_sel) begin
            id_csr_data         =   ;
        end else if (csr_wb_bypass_sel) begin
            id_csr_data         =   ;
        end else begin
            id_csr_data         =   id_csr_fetch;
        end

        id_stall                =   ((id_rs1 == exu_rd_q) | (id_rs2 == exu_rd_q)) & (exu_bypass_avail_q == MEM) & |exu_rd_q & id_valid_q & exu_valid_q;

        decode_exc_priority     =   exc_priority_encode(decode_exc_code);
        ctrl_exc_priority       =   exc_priority_encode(ctrl_exc_code);
        csr_exc_priority        =   exc_priority_encode(csr_exc_code);

        id_exc_valid_vec        =   {decode_exc_valid, ctrl_exc_valid, csr_exc_valid};
        id_exc_priority_vec     =   {decode_exc_priority, ctrl_exc_priority, csr_exc_priority};
        id_exc_code_vec         =   {decode_exc_code, ctrl_exc_code, csr_exc_code};

        id_exc_valid            =   |id_exc_vec;

        id_max_priority         =   3'd6;
        for (int i=0; i<3; i++) begin
            if (id_exc_valid_vec[i] & (id_exc_priority_vec[i*3 +: 3] < id_max_priority)) begin
                id_max_priority =   id_exc_priority_vec[i*3 +: 3];
                id_exc_code     =   id_exc_code_vec[i*5 +: 5];
            end
        end
    end

    //TODO: check registers we need to update for exceptions

    assign id_exc_valid     =   decode_exc_valid | ctrl_exc_valid | csr_exc_valid;
    assign decode_exc_code      =   ({5{decode_exc_valid}} & decode_exc_code)   | 
                                    ({5{ctrl_exc_valid}}   & ctrl_exc_code)     | 
                                    ({5{csr_exc_valid}}    & csr_exc_code);

    //valid register decode -> execute
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            exu_valid_q         <=  1'b0;
        end else if (exu_ready & ~decode_stall) begin
            exu_valid_q         <=  id_valid_q & ~id_exc_valid;
        end
    end

    //pipeline registers decode -> execute
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            exu_b_type_q        <=  1'b0;
            exu_funct3_q        <=  3'b0;
            exu_rd_q            <=  1'b0;
            exu_csr_addr_q      <=  12'h0;
            exu_csr_data_q      <=  64'h0;
            exu_csr_instr_q     <=  1'b0;
            exu_pc_sel_q        <=  1'b0;
            exu_rs1_data_q      <=  64'h0;
            exu_rs2_data_q      <=  64'h0;
            exu_instr_imm_q     <=  64'h0;
            exu_opr_a_sel_q     <=  RS1_OPERAND_A;
            exu_opr_b_sel_q     <=  RS2_OPERAND_B;
            exu_alu_func_q      <=  OP_ADD;
            exu_rd_src_q        <=  ALU_SRC;
            exu_data_req_q      <=  1'b0;
            exu_data_byte_q     <=  BYTE;
            exu_bypass_avail_q  <=  ALU_BYPASS;
            exu_data_wr_q       <=  1'b0;
            exu_zero_extnd_q    <=  1'b0;
            exu_rf_wr_en_q      <=  1'b0;
            exu_word_op_q       <=  1'b0;
            exu_alu_instr_q     <=  1'b0;
            exu_mul_instr_q     <=  1'b0;
            exu_div_instr_q     <=  1'b0;
            exu_pc_q            <=  32'h0;
            exu_pc_incr_q       <=  32'h0;
        end else if (exu_ready & ~decode_stall) begin
            exu_b_type_q        <=  id_b_type;
            exu_funct3_q        <=  id_funct3;
            exu_rd_q            <=  id_rd;
            exu_csr_addr_q      <=  id_csr_addr;
            exu_csr_data_q      <=  id_csr_data;
            exu_csr_instr_q     <=  ctrl_csr_en;
            exu_pc_sel_q        <=  ctrl_pc_sel;
            exu_rs1_data_q      <=  id_rs1_data;
            exu_rs2_data_q      <=  id_rs2_data;
            exu_instr_imm_q     <=  id_imm;
            exu_opr_a_sel_q     <=  ctrl_opa_sel;
            exu_opr_b_sel_q     <=  ctrl_opb_sel;
            exu_alu_func_q      <=  ctrl_exu_func_sel;
            exu_rd_src_q        <=  ctrl_rd_src;
            exu_data_req_q      <=  ctrl_data_req;
            exu_data_byte_q     <=  ctrl_data_req;
            exu_bypass_avail_q  <=  ctrl_bypass_avail;
            exu_data_wr_q       <=  ctrl_data_wr;
            exu_zero_extnd_q    <=  ctrl_zero_extnd;
            exu_rf_wr_en_q      <=  ctrl_rf_wr_en;
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
            exu_exc_code_q      <= 5'b0;
        end else if (exu_ready & ~decode_stall) begin
            exu_exc_valid_q     <= id_exc_valid_q | id_exc_valid;
            exu_exc_code_q      <= id_exc_valid_q ? id_exc_code_q : id_exc_code;
        end 
    end

    // EXECUTE

    //select operands
    always_comb begin
        case (exu_opr_a_sel_q)
            RS1_OPERAND_A: exu_opr_a    =   exu_rs1_data_q;
            PC_OPERAND_A: exu_opr_a     =   exu_pc_q;
            CSR_OPERAND_A: exu_opr_a    =   exu_csr_data_q; 
        endcase

        case (exu_opr_b_sel_q)
            RS2_OPERAND_B: exu_opr_b    =   exu_rs2_data_q;
            IMM_OPERAND_B: exu_opr_b    =   exu_instr_imm_q;
            RS1_OPERAND_B: exu_opr_b    =   exu_rs1_data_q;
        endcase
    end

    execute u_execute (
        .clk                (clk),
        .resetn             (resetn),
        .valid_instr_i      (exu_valid_q),
        .exu_ready_o        (exu_ready),
        .flush_i            (),
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
        .branch_taken_o     (exu_branch_taken)
    );

    //valid register execute -> memory
    always_ff @(posedge clk or negedge reset) begin
        if (~resetn) begin
            mem_valid_q         <=  1'b0;
        end else if (mem_ready) begin
            mem_valid_q         <=  exu_valid_q;
        end
    end

    //pipeline registers execute -> memory
    always_ff @(posedge clk or posedge reset) begin
        if (~resetn) begin
            mem_rs2_data_q      <=  64'h0;
            mem_instr_imm_q     <=  64'h0;
            mem_rd_q            <=  5'b0;
            mem_csr_addr_q      <=  12'h0;
            mem_csr_data_q      <=  64'h0;
            mem_csr_instr_q     <=  1'b0;
            mem_pc_incr_q       <=  64'h0;
            mem_rd_src_q        <=  ALU_SRC;
            mem_data_req_q      <=  1'b0;
            mem_data_byte_q     <=  BYTE;
            mem_data_wr_q       <=  1'b0;
            mem_zero_extnd_q    <=  1'b0;
            mem_alu_res_q       <=  64'h0;
        end else if (mem_ready) begin
            mem_rs2_data_q      <=  exu_rs2_data_q;
            mem_instr_imm_q     <=  exu_instr_imm_q;
            mem_rd_q            <=  exu_rd_q;
            mem_csr_addr_q      <=  exu_csr_addr_q;
            mem_csr_data_q      <=  exu_csr_data_q;
            mem_csr_instr_q     <=  exu_csr_instr_q;
            mem_pc_incr_q       <=  exu_pc_incr_q;
            mem_rd_src_q        <=  exu_rd_src_q;
            mem_data_req_q      <=  exu_data_req_q;
            mem_data_byte_q     <=  exu_data_byte_q;
            mem_data_wr_q       <=  exu_data_wr_q;
            mem_zero_extnd_q    <=  exu_zero_extnd_q;
            mem_alu_res_q       <=  exu_res;
        end
    end

    //exception registers execute -> memory
    always_ff @(posedge clk or posedge reset) begin
        if (~resetn) begin
            mem_exc_valid_q     <=  1'b0;
            mem_exc_code_q      <=  32'h0;
        end else if (mem_ready) begin
            mem_exc_valid_q     <=  exu_exc_valid_q;
            mem_exc_code_q      <=  exu_exc_code_q;
        end
    end

    // MEMORY

    always_comb begin
        mem_addr                =   (mem_alu_res_q >= 64'h0000_0000_8000_0000) & (mem_alu_res_q <= 64'h0000_0000_9FFF_FFFF);
        clint_addr              =   (mem_alu_res_q >= 64'h0000_0000_0200_0000) & (mem_alu_res_q <= 64'h0000_0000_0200_FFFF);
        plic_addr               =   (mem_alu_res_q >= 64'h0000_0000_0C00_0000) & (mem_alu_res_q <= 64'h0000_0000_0FFF_FFFF);

        oob_exc                 =   mem_valid_q & mem_data_req_q & ~mem_addr & ~clint_addr & ~plic_addr;

        memory_valid            =   mem_valid_q & mem_addr & mem_data_req_q;
        clint_valid             =   mem_valid_q & clint_addr & mem_data_req_q;
        plic_valid              =   mem_valid_q & plic_addr & mem_data_req_q; 
    end
    
    memory u_memory (
        .clk                    (clk),
        .resetn                 (resetn),
        .req_valid_i            (),
        .req_addr_i             (),
        .req_byte_en_i          (),
        .req_wr_i               (),
        .req_zero_extnd_i       (),
        .req_wr_data_i          (),
        .req_ready_o            (mem_ready),
        .data_mem_resp_valid_o  (),
        .data_mem_rd_data_o     (),
        .data_mem_ready_i       (dc_ready),
        .data_mem_req_o         (data_mem_req),
        .data_mem_addr_o        (data_mem_addr),
        .data_mem_wr_o          (data_mem_wr),
        .data_mem_wr_data_o     (data_mem_wr_data),
        .data_mem_mask_o        (data_mem_mask),
        .req_resp_valid_o       (req_resp_valid),
        .req_rd_data_i          (req_rd_data),
        .req_resp_ready_o       (mem_resp_ready),
        .exc_valid_i            (dc_exc_valid),
        .exc_code_i             (dc_exc_code),
        .exc_valid_o            (memory_exc_valid),
        .exc_code_o             (memory_exc_code)
    );

    d_cache #(.ID_W(1)) u_d_cache (
        .clk                    (clk),
        .resetn                 (resetn),
        .data_mem_req_i         (data_mem_req),
        .data_mem_addr_i        (data_mem_addr),
        .data_mem_wr_i          (data_mem_wr),
        .data_mem_wr_data_i     (data_mem_wr_data),
        .data_mem_mask_i        (data_mem_mask),
        .data_mem_ready_o       (dc_ready),
        .req_rd_ready_i         (mem_resp_ready),
        .req_resp_valid_o       (req_resp_valid),
        .req_rd_data_o          (req_rd_data),
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
        .awready_i              (dc_awready_o),
        .wready_i               (dc_wready_o),
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
        .req_valid_i            (),
        .req_addr_i             (),
        .req_byte_en_i          (),
        .req_wr_i               (),
        .req_wr_data_i          (),
        .clint_rd_data_o        (),
        .clint_resp_valid_o     (),
        .msip_irq_o             (),
        .mtip_irq_o             (),
        .exc_valid_o            (),
        .exc_code_o             ()
    );

    plic u_plic (
        .clk                    (clk),
        .resetn                 (resetn),
        .req_valid_i            (),
        .req_addr_i             (),
        .req_byte_en_i          (),
        .req_wr_i               (),
        .req_wr_data_i          (),
        .plic_rd_data_o         (),
        .plic_resp_valid_o      (),
        .signal1_i              (),
        .signal2_i              (),
        .signal3_i              (),
        .signal4_i              (),
        .signal5_i              (),
        .signal6_i              (),
        .signal7_i              (),
        .signal8_i              (),
        .eip_o                  (),
        .exc_valid_o            (),
        .exc_code_o             ()
    );

    //valid register memory -> writeback
    always_ff @(posedge clk or negedge resetn) begin
    end

    //pipeline registers memory -> writeback
    always_ff @(posedge clk or negedge resetn) begin
    end

    //exception registers memory -> writeback
    always_ff @(posedge clk or negedge resetn) begin
    end

endmodule