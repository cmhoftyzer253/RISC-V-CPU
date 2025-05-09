module core #(
    parameter RESET_PC = 64'h0000_0000;     //TODO - placeholder value
    )(
    input logic clk,
    input logic reset,

    //instruction memory interface
    output logic        instr_mem_req_o,
    output logic [63:0] instr_mem_addr_o,
    input logic [63:0]  fetch_instr_i,

    //data memory interface
    output logic        data_mem_req_o,
    output logic [63:0] data_mem_addr_o,
    output logic [1:0]  data_mem_byte_en_o,
    output logic        data_mem_wr_o,
    output logic [63:0] data_mem_wr_data_o,
    input logic [63:0]  data_mem_rd_data_i

);

    import cpu_consts::*;

    //internal signals

    //pc
    logic [63:0] nxt_seq_pc;
    logic [63:0] pc_q;
    logic [63:0] nxt_pc;

    //instruction
    logic [31:0] imem_dec_instr;

    //decode signals
    logic [4:0]  dec_rf_rs1;
    logic [4:0]  dec_rf_rs2;
    logic [4:0]  dec_rf_rd;
    logic [6:0]  dec_ctl_opcode;
    logic [2:0]  dec_ctl_funct3;
    logic [6:0]  dec_ctl_funct7;
    logic        r_type_instr;
    logic        i_type_instr;
    logic        s_type_instr;
    logic        b_type_instr;
    logic        u_type_instr;
    logic        j_type_instr;
    logic [63:0] dec_instr_imm;

    //rf mux output
    logic [63:0] rf_wr_data;

    //rf output
    logic [63:0] rf_rs1_data;
    logic [63:0] rf_rs2_data;

    //control unit output
    logic       ctl_pc_sel;
    logic       ctl_op1_sel;
    logic       ctl_op2_sel;
    logic [3:0] ctl_alu_func_sel;
    logic [1:0] ctl_rf_wr_data_src;
    logic       ctl_data_req;
    logic [1:0] ctl_data_byte;
    logic       ctl_data_wr;
    logic       ctl_zero_extnd;
    logic       ctl_rf_wr_en;

    //branch control output
    logic branch_taken;

    //ALU 
    logic [63:0] alu_opr_a;
    logic [63:0] alu_opr_b;
    logic [63:0] alu_res;

    //data memory output
    logic [63:0] data_mem_rd_data_o;

    //captures first cycle out of reset
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            reset_seen_q <= 1'b0;
        end else begin
            reset_seen_q <= 1'b1;
        end
    end

    //pc update
    assign nxt_seq_pc = pc_q + 64'h4;
    assign nxt_pc = (branch_taken | ctl_pc_sel) ? {alu_res[63:1], 1'b0} :   
                                                    nxt_seq_pc;

    //pc register
    //reset_seen_q ensures pc updated starting on second cycle out of reset
    //so instruction at RESET_PC can be on first cycle out of reset
    always_ff(@posedge clk or posedge reset) begin
        if (reset) begin
            pc_q <= RESET_PC;
        end else (reset_seen_q) begin
            pc_q <= nxt_pc;
        end
    end

    //fetch
    fetch u_fetch (
        .clk                (clk), 
        .reset              (reset),
        .instr_mem_req_o    (instr_mem_req_o),
        .instr_mem_addr_o   (instr_mem_addr_o),
        .fetch_instr_i      (fetch_instr_i),
        .fetch_instr_o      (imem_dec_instr)
    );

    //decode
    decode u_decode (
        .isntr_i        (imem_dec_instr),
        .rs1_o          (dec_rf_rs1),
        .rs2_o          (dec_rf_rs1),
        .rd_o           (dec_rf_rd),
        .op_o           (dec_ctl_opcode),
        .funct3_o       (dec_ctl_funct3),
        .funct7_o       (dec_ctl_funct7),
        .r_type_instr_o (r_type_instr),
        .i_type_instr_o (i_type_instr),
        .s_type_instr_o (s_type_instr),
        .b_type_instr_o (b_type_instr),
        .u_type_instr_o (u_type_instr),
        .j_type_instr_o (j_type_instr),
        .instr_imm      (dec_instr_imm)
    );

    //register file
    //select rf input data

    regfile u_regfile (
        .clk            (clk),
        .reset          (reset),
        .rs1_addr_i     (dec_rf_rs1),
        .rs2_addr_i     (dec_rf_rs2),
        .rd_addr_i      (dec_rf_rd),
        .wr_en_i        (ctl_rf_wr_en),
        .wr_data_i      (rf_wr_data),
        .rs1_data_o     (rf_rs1_data),
        .rs2_data_o     (rf_rs2_data)
    );


    //control unit
    control u_control (
        .instr_funct3_i         (dec_ctl_funct3),
        .instr_funct7_bit5_i    (dec_ctl_funct7[5]),
        .instr_opcode_i         (dec_ctl_opcode),
        .is_r_type_i            (r_type_instr),
        .is_i_type_i            (i_type_instr),
        .is_s_type_i            (s_type_instr),
        .is_b_type_i            (b_type_instr),
        .is_u_type_i            (u_type_instr),
        .is_j_type_i            (j_type_instr),
        .pc_sel_o               (ctl_pc_sel),
        .op1_sel_o              (ctl_op1_sel),
        .op2_sel_o              (ctl_op2_sel),
        .alu_func_sel_o         (ctl_alu_func_sel),
        .rf_wr_data_src_o       (ctl_rf_wr_data_src),
        .data_req_o             (ctl_data_req),
        .data_byte_o            (ctl_data_byte),
        .data_wr_o              (ctl_data_wr),
        .zero_extnd_o           (ctl_zero_extnd),
        .rf_wr_en_o             (ctl_rf_wr_en)
    );

    //branch control
    branch_control u_branch_control (
        .opr_a_i        (rf_rs1_data),
        .opr_b_i        (rf_rs2_data),
        .is_b_type_i    (b_type_instr),
        .instr_funct3_i (dec_ctl_funct3),
        .branch_taken_o (branch_taken)
    );

    //ALU
    //select inputs
    assign alu_opr_a = ctl_op1_sel ? pc_q : rf_rs1_data;
    assign alu_opr_b = ctl_op2_sel ? dec_instr_imm : rf_rs2_data;

    execute u_execute (
        .opr_a_i    (alu_opr_a),
        .opr_b_i    (alu_opr_b),
        .op_sel_i   (ctl_alu_func_sel),
        .alu_res_o  (alu_res),
    );

    //MEM
    memory u_memory (
        .data_req_i         (ctl_data_req),
        .data_addr_i        (alu_res),
        .data_byte_en_i     (ctl_data_byte),
        .data_wr_i          (ctl_data_wr),
        .data_wr_data_i     (ctl_data_wr),
        .data_zero_extnd_i  (ctl_zero_extnd),
        .data_mem_req_o     (data_mem_req_o),
        .data_mem_addr_o    (data_mem_addr_o),
        .data_mem_byte_en_o (data_mem_byte_en_o),
        .data_mem_wr_o      (data_mem_wr_o),
        .data_mem_wr_data_o (data_mem_wr_data_o),
        .mem_rd_data_i      (data_mem_rd_data_i),
        .data_mem_rd_data_o (data_mem_rd_data),
    );

    //writeback
    writeback u_writeback (
        .alu_res_i          (alu_res),
        .data_mem_rd_i      (data_mem_rd_data),
        .instr_imm_i        (dec_instr_imm),
        .pc_val_i           (nxt_seq_pc),
        .rf_wr_data_src_i   (ctl_rf_wr_data_src),
        .rf_wr_data_o       (rf_wr_data),
    );


endmodule