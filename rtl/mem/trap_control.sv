module trap_control (
    //csr interface
    input logic [1:0]       priv_level_i,

    output logic            trap_en_o,
    output logic            trap_delegate_o,
    output logic [5:0]      trap_cause_o,
    output logic [63:0]     trap_xepc_o,
    output logic [63:0]     trap_xtval_o,

    input logic             mstatus_mie_i,
    input logic             mstatus_sie_i,
    input logic [11:0]      mip_i,
    input logic [11:0]      mie_i,
    input logic [11:0]      mideleg_i,
    input logic [15:0]      medeleg_i,

    //pipeline interface
    input logic             validM_i,
    input logic             stallW_i,
    input logic             committedM_i,
    input logic             flushM_i,

    input logic             exc_validM_i,
    input logic [4:0]       exc_codeM_i,
    input logic [63:0]      pcM_i,
    input logic [63:0]      nxt_pcM_i,
    input logic [63:0]      exc_xtvalM_i
);

    logic                   s_interrupt_en;
    logic                   m_interrupt_en;

    logic [11:0]            m_int_en;
    logic [11:0]            s_int_en;
    logic [11:0]            int_en;

    logic                   interrupt;
    logic                   int_deleg;
    logic [5:0]             int_cause;
    logic [63:0]            int_xepc;

    logic                   exc;
    logic                   exc_deleg;
    logic [5:0]             exc_cause;
    logic [63:0]            exc_xepc;
    logic [63:0]            exc_xtval;

    always_comb begin : interrupts
        s_interrupt_en  =   (priv_level_i == U_MODE) || ((priv_level_i == S_MODE) && mstatus_sie_i);
        m_interrupt_en  =   mstatus_mie_i || (priv_level_i == U_MODE) || (priv_level_i == S_MODE);

        m_int_en        =   mip_i & mie_i & ~mideleg_i & {12{m_interrupt_en}};
        s_int_en        =   mip_i & mie_i &  mideleg_i & {12{s_interrupt_en}};

        int_en          =   m_int_en | s_int_en;

        interrupt       =   |int_en && validM_i && !stallW_i && !committedM_i && !flushM_i && !exc_validM_i;
        int_xepc        =   nxt_pcM_i;

        if (int_en[11]) begin
            int_cause   =   {1'b1, 5'd11};
            int_deleg   =   mideleg_i[11];
        end else if (int_en[3]) begin
            int_cause   =   {1'b1, 5'd3};
            int_deleg   =   mideleg_i[3];
        end else if (int_en[7]) begin
            int_cause   =   {1'b1, 5'd7};
            int_deleg   =   mideleg_i[7];
        end else if (int_en[9]) begin
            int_cause   =   {1'b1, 5'd9};
            int_deleg   =   mideleg_i[9];
        end else if (int_en[1]) begin
            int_cause   =   {1'b1, 5'd1};
            int_deleg   =   mideleg_i[1];
        end else if (int_en[5]) begin
            int_cause   =   {1'b1, 5'd5};
            int_deleg   =   mideleg_i[5];
        end else begin
            int_cause   =   6'd0;
            int_deleg   =   1'b0;
        end
    end

    always_comb begin : exceptions
        exc             =   exc_validM_i && validM_i && !flushM_i && !stallW_i;
        exc_cause       =   {1'b0, exc_codeM_i};
        exc_xepc        =   pcM_i;
        exc_xtval       =   exc_xtvalM_i;

        exc_deleg       =   (priv_level_i != M_MODE) && medeleg_i[exc_codeM_i];
    end

    always_comb begin : output_sel
        trap_en_o       =   exc || interrupt;   

        if (exc) begin
            trap_delegate_o     =   exc_deleg;
            trap_cause_o        =   exc_cause;
            trap_xepc_o         =   exc_xepc;
            trap_xtval_o        =   exc_xtval;
        end else if (interrupt) begin
            trap_delegate_o     =   int_deleg;
            trap_cause_o        =   int_cause;
            trap_xepc_o         =   int_xepc;
            trap_xtval_o        =   64'h0;
        end else begin
            trap_delegate_o     =   1'b0;
            trap_cause_o        =   6'd0;
            trap_xepc_o         =   64'h0;
            trap_xtval_o        =   64'h0;
        end
    end

endmodule