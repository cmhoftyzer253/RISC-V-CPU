import cpu_defines::*;

module pipeline (
    input logic             clk,
    input logic             resetn,

    input logic             ifu_ready_i,
    output logic [63:0]     nxt_pcF_o,

    //F interface
    input logic [31:0]      instrF_i,
    input logic             instr_validF_i,

    output logic            ic_invalidateF_o,
    input logic             ic_invalidate_doneF_i,

    input logic [63:0]      pcF_i,

    input logic             exc_validF_i,
    input logic [4:0]       exc_codeF_i,

    //D interface
    output logic [31:0]     instrD_o,

    input logic [4:0]       rs1D_i,
    input logic [4:0]       rs2D_i,
    input logic [4:0]       rdD_i,
    input logic [63:0]      immD_i,
    input logic [11:0]      csr_addrD_i,

    input logic [2:0]       pc_selD_i,
    input logic [1:0]       opa_selD_i,
    input logic             opb_selD_i,
    input logic             rs1_usedD_i,
    input logic             rs2_usedD_i,
    input logic             word_opD_i,
    input logic             alu_enD_i,
    input logic             md_enD_i,
    input logic [3:0]       exu_opD_i,
    input logic [2:0]       branch_opD_i,
    input logic             csr_wr_enD_i,
    input logic [1:0]       csr_opD_i,
    input logic             mctrl_enD_i,
    input logic [1:0]       mctrl_opD_i,
    input logic             lsu_enD_i,
    input logic [1:0]       lsu_lsD_i,
    input logic [1:0]       lsu_sizeD_i,
    input logic [4:0]       atomic_opD_i,
    input logic             lsu_seD_i,
    input logic             rf_wr_enD_i,
    input logic [2:0]       rf_selD_i,

    input logic             exc_validD_i,
    input logic [4:0]       exc_codeD_i,

    input logic [63:0]      rs1_dataD_i,
    input logic [63:0]      rs2_dataD_i,

    output logic [63:0]     opr_aD_o,
    output logic [63:0]     opr_bD_o,
    output logic            md_enD_o,
    output logic [3:0]      exu_opD_o,
    output logic            word_opD_o,
    input logic             mdu_readyD_i,

    //E interface
    output logic [63:0]     opr_aE_o,
    output logic [63:0]     opr_bE_o,
    output logic            word_opE_o,
    output logic            branch_enE_o,
    output logic [3:0]      exu_opE_o,
    output logic [2:0]      branch_opE_o,
    
    input logic [63:0]      alu_resE_i,
    input logic             branch_takenE_i,
    input logic             mdu_res_validE_i,
    input logic [63:0]      mdu_resE_i,    

    output logic            lsu_validE_o,
    output logic [63:0]     lsu_dataE_o,
    output logic [1:0]      lsu_lsE_o,
    output logic [63:0]     lsu_addrE_o,
    output logic [1:0]      lsu_sizeE_o,
    output logic            lsu_seE_o,
    input logic             lsu_readyE_i,

    output logic [4:0]      atomic_opE_o,

    //M interface
    output logic            csr_wr_enM_o,
    output logic [11:0]     csr_addrM_o,
    output logic [63:0]     csr_wr_dataM_o,
    output logic [1:0]      csr_opM_o,
    input logic [63:0]      csr_dataM_i,

    output logic [63:0]     rs2_dataM_o,

    input logic [63:0]      lsu_ldataM_i,

    input logic [63:0]      addrM_i,

    output logic            mretM_o,
    output logic            sretM_o,
    output logic            validM_o,

    output logic            dc_cleanM_o,
    input logic             dc_clean_doneM_i,

    input logic             exc_validM_i,
    input logic [4:0]       exc_codeM_i,

    output logic            exc_validM_o,
    output logic [4:0]      exc_codeM_o,
    output logic [63:0]     pcM_o,
    output logic [63:0]     nxt_pcM_o,
    output logic [63:0]     exc_xtvalM_o,

    input logic             trap_en_i,
    input logic [63:0]      trap_pc_i,
    input logic [63:0]      mepc_i,
    input logic [63:0]      sepc_i,

    input logic             mstatus_tw_i,

    input logic [1:0]       priv_level_i,
    input logic             wfi_wakeup_i,

    //W interface
    output logic [4:0]      rdW_o,
    output logic            rf_wr_enW_o,
    output logic [63:0]     rf_wr_dataW_o,

    output logic            stallD_o,
    output logic            stallE_o,
    output logic            stallM_o,

    output logic            flushF_o,
    output logic            flushE_o,

    output logic            retire_o
);

    logic                   validD;
    logic                   validE;
    logic                   validM;
    logic                   validW;

    logic                   stallF;
    logic                   stallD;
    logic                   stallE;
    logic                   stallM;

    logic                   flushF;
    logic                   flushD;
    logic                   flushE;

    logic                   bubbleE;
    logic                   bubbleM;

    logic                   nxt_validW;

    logic [63:0]            nxt_pcF;
    
    logic [63:0]            pc_incrF;
    logic [63:0]            pc_incrD;
    logic [63:0]            pc_incrE;
    logic [63:0]            pc_incrM;

    logic [63:0]            pcD;
    logic [63:0]            pcE;
    logic [63:0]            pcM;

    logic [63:0]            nxt_pcM;

    logic [31:0]            instrD;
    logic [31:0]            instrE;
    logic [31:0]            instrM;

    logic                   redirect_trap;
    logic                   redirect_bjE;
    logic                   redirect_misaligned;
    logic                   redirect_serialize;

    logic                   redirect_en;
    logic                   redirect_pending;
    logic                   redirect_pending_clear;
    logic [63:0]            redirect_pending_pc;

    logic                   exc_validD;
    logic [4:0]             exc_codeD;
    logic [63:0]            exc_xtvalD;

    logic                   rs1_wait;
    logic                   rs2_wait;

    logic                   rs1_forwardE;
    logic                   rs1_forwardM;
    logic                   rs1_forwardW;
    
    logic                   rs2_forwardE;
    logic                   rs2_forwardM;
    logic                   rs2_forwardW;

    logic [63:0]            forward_dataE;
    logic [63:0]            forward_dataM;
    logic [63:0]            forward_dataW;

    logic                   rf_sel_availableE;

    logic [63:0]            rs1_dataD;
    logic [63:0]            rs2_dataD;

    logic [63:0]            immE;

    logic [4:0]             rs1E;
    logic [4:0]             rs2E;
    logic [4:0]             rdE;

    logic [11:0]            csr_addrE;

    logic [2:0]             pc_selE;
    logic [1:0]             opa_selE;
    logic                   opb_selE;

    logic                   rs1_usedE;
    logic                   rs2_usedE;

    logic                   word_opE;
    logic                   alu_enE;
    logic                   md_enE;

    logic [3:0]             exu_opE;
    logic [2:0]             branch_opE;

    logic                   csr_wr_enE;
    logic [1:0]             csr_opE;

    logic                   mctrl_enE;
    logic [1:0]             mctrl_opE;

    logic                   lsu_enE;
    logic [1:0]             lsu_lsE;
    logic [1:0]             lsu_sizeE;
    logic [4:0]             atomic_opE;
    logic                   lsu_seE;

    logic                   rf_wr_enE;
    logic [2:0]             rf_selE;
    
    logic [63:0]            rs1_dataE;
    logic [63:0]            rs2_dataE;

    logic                   exc_validE;
    logic [4:0]             exc_codeE;
    logic [63:0]            exc_xtvalE;

    logic                   nxt_exc_validE;
    logic [4:0]             nxt_exc_codeE;
    logic [63:0]            nxt_exc_xtvalE;

    logic                   jumpE;
    logic                   branchE;
    logic                   branch_takenE;

    logic [4:0]             rdM;

    logic [2:0]             pc_selM;

    logic [11:0]            csr_addrM;
    logic                   csr_wr_enM;
    logic [1:0]             csr_opM;

    logic                   mctrl_enM;
    logic [1:0]             mctrl_opM;

    logic                   lsu_enM;

    logic                   rf_wr_enM;
    logic [2:0]             rf_selM;

    logic [63:0]            exu_resM;
    logic [63:0]            csr_wr_dataM;
    logic [63:0]            rs2_dataM;

    logic [63:0]            rf_wr_dataM;

    logic                   exc_validM;
    logic [4:0]             exc_codeM;
    logic [63:0]            exc_xtvalM;

    logic                   nxt_exc_validM;
    logic [4:0]             nxt_exc_codeM;
    logic [63:0]            nxt_exc_xtvalM;

    logic                   mretM;
    logic                   sretM;
    logic                   csr_wrM;

    logic                   wfiM;
    logic                   fenceiM;

    logic                   stall_wfiM;
    logic                   stall_fenceiM;

    logic                   wfi_timer_en;
    logic                   wfi_timeout;
    logic [16:0]            wfi_timer;

    logic                   fencei_start;
    logic                   fencei_done;
    logic                   fencei_started;
    
    logic                   ic_invalidate_wait;
    logic                   ic_invalidate_wait_ff;

    logic                   dc_clean_wait;
    logic                   dc_clean_wait_ff;

    logic [4:0]             rdW;
    logic                   rf_wr_enW;
    logic [63:0]            rf_wr_dataW;

    //next PC
    always_comb begin
        if (!resetn)
            nxt_pcF     =   RESET_PC;
        else if (redirect_trap)
            nxt_pcF     =   trap_pc_i;
        else if (mretM)
            nxt_pcF     =   mepc_i;
        else if (sretM)
            nxt_pcF     =   sepc_i;
        else if (redirect_serialize)
            nxt_pcF     =   pc_incrM;
        else if (redirect_bjE)
            nxt_pcF     =   alu_resE_i;
        else if (redirect_pending)
            nxt_pcF     =   redirect_pending_pc;
        else
            nxt_pcF     =   pc_incrF;
    end

    assign stallF                   =   !ifu_ready_i || stallD;
    assign redirect_en              =   (redirect_trap || mretM || sretM || redirect_serialize || redirect_bjE) && stallF;
    assign redirect_pending_clear   =   redirect_pending && !stallF;

    assign nxt_pcF_o                =   nxt_pcF;

    //handle pc redirects during backpressure
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            redirect_pending        <= 1'b0;
            redirect_pending_pc     <= 64'h0;
        end else if (redirect_en) begin
            redirect_pending        <= 1'b1;
            redirect_pending_pc     <= nxt_pcF;
        end else if (redirect_pending_clear) begin
            redirect_pending        <= 1'b0;
            redirect_pending_pc     <= 64'h0;
        end
    end

    assign pc_incrF     =   pcF_i + 64'h4;

    assign stallD       =   stallE || rs1_wait || rs2_wait;
    assign stallD_o     =   stallD;

    assign flushF       =   trap_en_i || mretM || sretM || redirect_serialize || redirect_bjE;
    assign flushF_o     =   flushF;

    //F -> D registers
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            validD      <=  1'b0;
            instrD      <=  32'h0;
            pcD         <=  64'h0;
            pc_incrD    <=  64'h0;
        end else if (flushD) begin
            validD      <=  1'b0;
        end else if (!stallD) begin
            validD      <=  instr_validF_i;
            instrD      <=  instrF_i;
            pcD         <=  pcF_i;
            pc_incrD    <=  pc_incrF;
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            exc_validD  <=  1'b0;
            exc_codeD   <=  5'd0;
            exc_xtvalD  <=  64'h0;
        end else if (!stallD) begin
            exc_validD  <=  exc_validF_i;
            exc_codeD   <=  exc_codeF_i;
            exc_xtvalD  <=  pcF_i;
        end
    end

    assign stallE       = stallM || !mdu_readyD_i;
    assign stallE_o     =   stallE;

    //forwarding logic 
    always_comb begin
        rf_sel_availableE   =   (rf_selE == RF_ALU_SRC) || (rf_selE == RF_PC_INCR_SRC) || ((rf_selE == RF_MDU_SRC) && mdu_res_validE_i);

        rs1_wait            =   validD && validE && rs1_usedD_i && (rs1D_i == rdE) && (rs1D_i != 5'd0) && rf_wr_enE && !rf_sel_availableE;
        rs2_wait            =   validD && validE && rs2_usedD_i && (rs2D_i == rdE) && (rs2D_i != 5'd0) && rf_wr_enE && !rf_sel_availableE;
        bubbleE             =   rs1_wait || rs2_wait || flushD;

        case (rf_selE)
            RF_ALU_SRC: forward_dataE       =   alu_resE_i;
            RF_PC_INCR_SRC: forward_dataE   =   pc_incrE;
            RF_MDU_SRC: forward_dataE       =   mdu_resE_i;
            default: forward_dataE          =   64'h0;
        endcase

        forward_dataM   =   rf_wr_dataM;
        forward_dataW   =   rf_wr_dataW;

        rs1_forwardE    =   validD && validE && !exc_validE && rf_wr_enE && (rs1D_i != 5'd0) && (rs1D_i == rdE) && rf_sel_availableE;
        rs1_forwardM    =   validD && validM && !exc_validM && rf_wr_enM && (rs1D_i != 5'd0) && (rs1D_i == rdM);
        rs1_forwardW    =   validD && validW && rf_wr_enW && (rs1D_i != 5'd0) && (rs1D_i == rdW);

        rs2_forwardE    =   validD && validE && !exc_validE && rf_wr_enE && (rs2D_i != 5'd0) && (rs2D_i == rdE) && rf_sel_availableE;
        rs2_forwardM    =   validD && validM && !exc_validM && rf_wr_enM && (rs2D_i != 5'd0) && (rs2D_i == rdM);
        rs2_forwardW    =   validD && validW && rf_wr_enW && (rs2D_i != 5'd0) && (rs2D_i == rdW);

        if (rs1_forwardE)
            rs1_dataD   =   forward_dataE;
        else if (rs1_forwardM)
            rs1_dataD   =   forward_dataM;
        else if (rs1_forwardW)
            rs1_dataD   =   forward_dataW;
        else
            rs1_dataD   =   rs1_dataD_i;

        if (rs2_forwardE)
            rs2_dataD   =   forward_dataE;
        else if (rs2_forwardM)
            rs2_dataD   =   forward_dataM;
        else if (rs2_forwardW)
            rs2_dataD   =   forward_dataW;
        else
            rs2_dataD   =   rs2_dataD_i;
    end

    assign opr_aD_o     =   rs1_dataD;
    assign opr_bD_o     =   rs2_dataD;
    assign md_enD_o     =   validD && !exc_validD && !exc_validD_i && !flushD && !rs1_wait && !rs2_wait && md_enD_i;
    assign exu_opD_o    =   exu_opD_i;
    assign word_opD_o   =   word_opD_i;

    assign instrD_o     =   instrD;

    assign flushD       =   trap_en_i || mretM || sretM || redirect_serialize || redirect_bjE;

    //D -> E registers
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            validE      <=  1'b0;
            instrE      <=  32'h0;
            pcE         <=  64'h0;
            pc_incrE    <=  64'h0;
            rs1E        <=  5'd0;
            rs2E        <=  5'd0;
            rdE         <=  5'd0;
            immE        <=  64'h0;
            csr_addrE   <=  12'h0;
            pc_selE     <=  3'b0;
            opa_selE    <=  2'b0;
            opb_selE    <=  1'b0;
            rs1_usedE   <=  1'b0;
            rs2_usedE   <=  1'b0;
            word_opE    <=  1'b0;
            alu_enE     <=  1'b0;
            md_enE      <=  1'b0;
            exu_opE     <=  4'b0;
            branch_opE  <=  3'b0;
            csr_wr_enE  <=  1'b0;
            csr_opE     <=  2'b0;
            mctrl_enE   <=  1'b0;
            mctrl_opE   <=  2'b0;
            lsu_enE     <=  1'b0;
            lsu_lsE     <=  2'b0;
            lsu_sizeE   <=  2'b0;
            atomic_opE  <=  5'b0;
            lsu_seE     <=  1'b0;
            rf_wr_enE   <=  1'b0;
            rf_selE     <=  3'b0;
            rs1_dataE   <=  64'h0;
            rs2_dataE   <=  64'h0;
        end else if (flushE) begin
            validE      <=  1'b0;
        end else if (!stallE) begin
            validE      <=  bubbleE ? 1'b0 : validD;
            instrE      <=  instrD;
            pcE         <=  pcD;
            pc_incrE    <=  pc_incrD;
            rs1E        <=  rs1D_i;
            rs2E        <=  rs2D_i;
            rdE         <=  rdD_i;
            immE        <=  immD_i;
            csr_addrE   <=  csr_addrD_i;
            pc_selE     <=  pc_selD_i;
            opa_selE    <=  opa_selD_i;
            opb_selE    <=  opb_selD_i;
            rs1_usedE   <=  rs1_usedD_i;
            rs2_usedE   <=  rs2_usedD_i;
            word_opE    <=  word_opD_i;
            alu_enE     <=  alu_enD_i;
            md_enE      <=  md_enD_i;
            exu_opE     <=  exu_opD_i;
            branch_opE  <=  branch_opD_i;
            csr_wr_enE  <=  csr_wr_enD_i;
            csr_opE     <=  csr_opD_i;
            mctrl_enE   <=  mctrl_enD_i;
            mctrl_opE   <=  mctrl_opD_i;
            lsu_enE     <=  lsu_enD_i;
            lsu_lsE     <=  lsu_lsD_i;
            lsu_sizeE   <=  lsu_sizeD_i;
            atomic_opE  <=  atomic_opD_i;
            lsu_seE     <=  lsu_seD_i;
            rf_wr_enE   <=  rf_wr_enD_i;
            rf_selE     <=  rf_selD_i;
            rs1_dataE   <=  rs1_dataD;
            rs2_dataE   <=  rs2_dataD;
        end
    end

    assign nxt_exc_validE   =   exc_validD || exc_validD_i;
    assign nxt_exc_codeE    =   exc_validD ? exc_codeD : exc_codeD_i;

    always_comb begin
        if (exc_validD) begin
            nxt_exc_xtvalE  =   exc_xtvalD;
        end else begin
            case (exc_codeD_i)
                ILLEGAL_INSTR: nxt_exc_xtvalE   =   {32'h0, instrD};
                EBREAK: nxt_exc_xtvalE          =   pcD;
                default: nxt_exc_xtvalE         =   64'h0;
            endcase
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            exc_validE  <=  1'b0;
            exc_codeE   <=  5'd0;
            exc_xtvalE  <=  64'h0;
        end else if (!stallE) begin
            exc_validE  <=  nxt_exc_validE;
            exc_codeE   <=  nxt_exc_codeE;
            exc_xtvalE  <=  nxt_exc_xtvalE;
        end
    end

    //jump/branch redirect logic 
    always_comb begin
        jumpE                   =   validE && !exc_validE && (pc_selE == ALU_RES);
        branchE                 =   validE && !exc_validE && (pc_selE == BRANCH);
        branch_takenE           =   branchE && branch_takenE_i;

        redirect_misaligned     =   (jumpE || branch_takenE) && |alu_resE_i[1:0];
        redirect_bjE            =   (jumpE || branch_takenE) && !redirect_misaligned;
    end

    assign bubbleM  =   (validE && !exc_validE && md_enE && !mdu_res_validE_i) || flushE;

    //outputs to E
    always_comb begin
        case (opa_selE)
            RS1: opr_aE_o   =   rs1_dataE;
            PC: opr_aE_o    =   pcE;
            ZERO: opr_aE_o  =   64'h0;
            UIMM: opr_aE_o  =   immE;
        endcase

        opr_bE_o        =   (opb_selE == RS2) ? rs2_dataE : immE;
        word_opE_o      =   word_opE;
        branch_enE_o    =   validE && !exc_validE && (pc_selE == BRANCH);
        exu_opE_o       =   exu_opE;
        branch_opE_o    =   branch_opE;

        lsu_validE_o    =   validE && !exc_validE && !flushE && !stall_wfiM && !stall_fenceiM && lsu_enE;
        lsu_dataE_o     =   rs2_dataE;
        lsu_lsE_o       =   lsu_lsE;
        lsu_addrE_o     =   (lsu_lsE == LSU_ATOMIC) ? rs1_dataE : alu_resE_i;
        lsu_sizeE_o     =   lsu_sizeE;
        lsu_seE_o       =   lsu_seE;

        atomic_opE_o    =   atomic_opE;
    end

    assign flushE       =   trap_en_i || mretM || sretM || redirect_serialize;
    assign flushE_o     =   flushE;

    //E -> M registers
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            validM          <=  1'b0;
            instrM          <=  32'h0;
            pcM             <=  64'h0;
            pc_incrM        <=  64'h0;
            nxt_pcM         <=  64'h0;
            rdM             <=  5'd0;
            csr_addrM       <=  12'h0;
            pc_selM         <=  3'b0;
            csr_wr_enM      <=  1'b0;
            csr_opM         <=  2'b0;
            mctrl_enM       <=  1'b0;
            mctrl_opM       <=  2'b0;
            lsu_enM         <=  1'b0;
            rf_wr_enM       <=  1'b0;
            rf_selM         <=  3'b0;            
            exu_resM        <=  64'h0;
            csr_wr_dataM    <=  64'h0;
            rs2_dataM       <=  64'h0;       
        end else if (!stallM) begin
            validM          <=  bubbleM ? 1'b0 : validE;
            instrM          <=  instrE;
            pcM             <=  pcE;
            pc_incrM        <=  pc_incrE;
            nxt_pcM         <=  redirect_bjE ? alu_resE_i : pc_incrE;
            rdM             <=  rdE;
            csr_addrM       <=  csr_addrE;
            pc_selM         <=  pc_selE;
            csr_wr_enM      <=  csr_wr_enE;
            csr_opM         <=  csr_opE;
            mctrl_enM       <=  mctrl_enE;
            mctrl_opM       <=  mctrl_opE;
            lsu_enM         <=  lsu_enE;
            rf_wr_enM       <=  rf_wr_enE;
            rf_selM         <=  rf_selE;
            exu_resM        <=  md_enE ? mdu_resE_i : alu_resE_i;
            csr_wr_dataM    <=  (opa_selE == UIMM) ? immE : rs1_dataE;
            rs2_dataM       <=  rs2_dataE;
        end
    end
    
    assign nxt_exc_validM   =   exc_validE || redirect_misaligned;
    assign nxt_exc_codeM    =   exc_validE ? exc_codeE : I_ADDR_MISALIGNED;
    assign nxt_exc_xtvalM   =   exc_validE ? exc_xtvalE : alu_resE_i;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            exc_validM  <=  1'b0;
            exc_codeM   <=  5'd0;
            exc_xtvalM  <=  64'h0;
        end else if (!stallM) begin
            exc_validM  <=  nxt_exc_validM;
            exc_codeM   <=  nxt_exc_codeM;
            exc_xtvalM  <=  nxt_exc_xtvalM;
        end
    end

    //outputs to M
    always_comb begin
        csr_wr_enM_o    =   validM && !exc_validM && csr_wr_enM;
        csr_addrM_o     =   csr_addrM;
        csr_wr_dataM_o  =   csr_wr_dataM;
        csr_opM_o       =   csr_opM;
        
        rs2_dataM_o     =   rs2_dataM;

        exc_validM_o    =   validM && (exc_validM || exc_validM_i || wfi_timeout);
        exc_codeM_o     =   exc_validM ? exc_codeM : (exc_validM_i ? exc_codeM_i : ILLEGAL_INSTR);

        pcM_o           =   pcM;
        nxt_pcM_o       =   mretM ? mepc_i : (sretM ? sepc_i : nxt_pcM);
        exc_xtvalM_o    =   exc_validM ? exc_xtvalM : (exc_validM_i ? addrM_i : instrM);

        mretM_o         =   mretM;
        sretM_o         =   sretM;
        validM_o        =   validM;
    end

    //Rf writeback mux
    always_comb begin
        case (rf_selM)
            RF_ALU_SRC,
            RF_MDU_SRC: rf_wr_dataM         =   exu_resM;
            RF_LSU_SRC: rf_wr_dataM         =   lsu_ldataM_i;
            RF_PC_INCR_SRC: rf_wr_dataM     =   pc_incrM;
            RF_CSR_SRC: rf_wr_dataM         =   csr_dataM_i;
            default: rf_wr_dataM            =   64'h0;
        endcase
    end

    //M flush behind/stall logic
    always_comb begin
        mretM               =   validM && !exc_validM && mctrl_enM && (mctrl_opM == MRET_OP);
        sretM               =   validM && !exc_validM && mctrl_enM && (mctrl_opM == SRET_OP);

        csr_wrM             =   validM && !exc_validM && csr_wr_enM;
        redirect_serialize  =   csr_wrM || fencei_done;

        redirect_trap       =   trap_en_i;

        wfiM                =   validM && !exc_validM && mctrl_enM && (mctrl_opM == WFI_OP);
        fenceiM             =   validM && !exc_validM && mctrl_enM && (mctrl_opM == FENCE_I);

        stall_wfiM          =   wfiM && !wfi_wakeup_i && !wfi_timeout;
        stall_fenceiM       =   fenceiM && !fencei_done;
    end                      

    //WFI logic
    always_comb begin
        wfi_timer_en = wfiM && (priv_level_i == S_MODE) && mstatus_tw_i;
        wfi_timeout = wfi_timer_en && wfi_timer[16];
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            wfi_timer <= 17'h0;
        end else if (wfi_timeout || wfi_wakeup_i) begin
            wfi_timer <= 17'h0;
        end else if (wfi_timer_en) begin
            wfi_timer <= wfi_timer + 17'd1;
        end
    end

    //FENCE.I logic
    always_comb begin
        ic_invalidate_wait  =   ic_invalidate_wait_ff && !ic_invalidate_doneF_i;
        dc_clean_wait       =   dc_clean_wait_ff && !dc_clean_doneM_i;

        fencei_start        =   fenceiM && !fencei_started;
        fencei_done         =   fencei_started && !dc_clean_wait && !ic_invalidate_wait;

        ic_invalidateF_o    =   fencei_start;
        dc_cleanM_o         =   fencei_start;
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            fencei_started  <= 1'b0;
        else if (fencei_start)
            fencei_started  <= 1'b1;
        else if (fencei_done) 
            fencei_started  <= 1'b0;
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            ic_invalidate_wait_ff       <= 1'b0;
            dc_clean_wait_ff            <= 1'b0;
        end else if (fencei_start) begin
            ic_invalidate_wait_ff       <= !ic_invalidate_doneF_i;
            dc_clean_wait_ff            <= 1'b1;
        end else begin
            if (ic_invalidate_doneF_i)
                ic_invalidate_wait_ff   <= 1'b0;

            if (dc_clean_doneM_i)
                dc_clean_wait_ff        <= 1'b0;
        end
    end

    assign stallM       =   !lsu_readyE_i || stall_wfiM || stall_fenceiM;
    assign stallM_o     =   stallM;

    assign nxt_validW   =   validM && !stallM && !exc_validM_o;

    //M -> W registers
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            validW          <=  1'b0;
            rdW             <=  5'd0;
            rf_wr_enW       <=  1'b0;
            rf_wr_dataW     <=  64'h0;
        end else begin
            validW          <=  nxt_validW;
            rdW             <=  rdM;
            rf_wr_enW       <=  rf_wr_enM;
            rf_wr_dataW     <=  rf_wr_dataM;
        end
    end 

    assign rdW_o            =   rdW;
    assign rf_wr_enW_o      =   validW && rf_wr_enW;
    assign rf_wr_dataW_o    =   rf_wr_dataW;

    assign retire_o         =   validW;

endmodule