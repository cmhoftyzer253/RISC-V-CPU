module csr (
    input logic             clk,
    input logic             resetn,

    input logic             rd_en_i,
    input logic [11:0]      rd_addr_i,
    output logic [63:0]     rd_data_o,

    input logic             wr_en_i,
    input logic [11:0]      wr_addr_i,
    input logic [63:0]      wr_data_i,

    input logic             flush_i,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o,

    input logic [63:0]      mtime_i
);

    localparam logic [63:0] MISA_Q          =   64'h8000_0000_0000_1100;
    localparam logic [63:0] MVENDORID_Q     =   64'h0;
    localparam logic [63:0] MARCHID_Q       =   64'h0;
    localparam logic [63:0] MIMPID_Q        =   64'h0;
    localparam logic [63:0] MHARTID_Q       =   64'h0;

    logic [63:0]            mstatus_q;        //RW
    logic [63:0]            mie_q;            //RW
    logic [63:0]            mtvec_q;          //RW
    logic [63:0]            mcountinhibit_q;  //RW
    logic [63:0]            mscratch_q;       //RW
    logic [63:0]            mepc_q;           //RW
    logic [63:0]            mcause_q;         //RW
    logic [63:0]            mtval_q;          //RW
    logic [63:0]            mip_q;            //RO
    logic [63:0]            mcycle_q;         //RW
    logic [63:0]            minstret_q;       //RW
    logic [63:0]            cycle_q;          //RO
    logic [63:0]            time_q;           //RO
    logic [63:0]            instret_q;        //RO

    logic                   mstatus_wr_addr;
    logic                   mie_wr_addr;
    logic                   mtvec_wr_addr;
    logic                   mcountinhibit_wr_addr;
    logic                   mscratch_wr_addr;
    logic                   mepc_wr_addr;
    logic                   mcause_wr_addr;
    logic                   mtval_wr_addr;
    logic                   mcycle_wr_addr;
    logic                   minstret_wr_addr;

    logic [9:0]             wr_addr_vec;

    logic                   mstatus_rd_addr;
    logic                   misa_rd_addr;
    logic                   mie_rd_addr;
    logic                   mtvec_rd_addr;
    logic                   mcountinhibit_rd_addr;
    logic                   mscratch_rd_addr;
    logic                   mepc_rd_addr;
    logic                   mcause_rd_addr;
    logic                   mtval_rd_addr;
    logic                   mip_rd_addr;
    logic                   mcycle_rd_addr;
    logic                   minstret_rd_addr;
    logic                   cycle_rd_addr;
    logic                   time_rd_addr;
    logic                   instret_rd_addr;
    logic                   mvendorid_rd_addr;
    logic                   marchid_rd_addr;
    logic                   mimpid_rd_addr;
    logic                   mhartid_rd_addr;

    logic [18:0]            rd_addr_vec;

    logic [63:0]            mstatus_wr_mask;
    logic [63:0]            mstatus_one_mask;
    logic [63:0]            mie_wr_mask;
    logic [63:0]            mtvec_wr_mask;
    logic [63:0]            mepc_wr_mask;

    logic                   rd_fault;
    logic                   wr_fault;

    logic [63:0]            nxt_mstatus;
    logic [63:0]            mxt_mie;
    logic [63:0]            nxt_mtvec;
    logic [63:0]            nxt_mepc; 

    //TODO: hardware accesses later

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            mstatus_q               <=  64'h0000_0000_0000_1800;
            mie_q                   <=  64'h0; 
            mtvec_q                 <=  64'h0;
            mcountinhibit_q         <=  64'h0;
            mscratch_q              <=  64'h0;
            mepc_q                  <=  64'h0;
            mcause_q                <=  64'h0;
            mtval_q                 <=  64'h0;
            mip_q                   <=  64'h0;
            mcycle_q                <=  64'h0;
            minstret_q              <=  64'h0;
        end else begin
            if (mstatus_wr_addr)
                mstatus_q           <=  nxt_mstatus;
            else if (mie_wr_addr)
                mie_q               <=  nxt_mie;
            else if (mtvec_wr_addr)
                mtvec_q             <=  nxt_mtvec;
            else if (mcountinhibit_wr_addr)
                mcountinhibit_q     <=  wr_data_i;
            else if (mscratch_wr_addr)
                mscratch_q          <=  wr_data_i;
            else if (mepc_wr_addr)
                mepc_q              <=  nxt_mepc;
            else if (mcause_wr_addr)
                mcause_q            <=  wr_data_i;
            else if (mtval_wr_addr)
                mtval_q             <=  wr_data_i;
            else if (mcycle_wr_addr)
                mcycle_q            <=  wr_data_i;
            else if (minstret_wr_addr)
                minstret_q          <=  wr_data_i;
        end
    end

    always_comb begin
        rd_data_o               =   64'h0;

        cycle_q                 =   mcycle_q;  
        time_q                  =   mtime_i;
        instret_q               =   minstret_q;

        mstatus_wr_addr         =   wr_en_i & ~flush_i & (wr_addr_i == 12'h300);
        mie_wr_addr             =   wr_en_i & ~flush_i & (wr_addr_i == 12'h304);
        mtvec_wr_addr           =   wr_en_i & ~flush_i & (wr_addr_i == 12'h305);
        mcountinhibit_wr_addr   =   wr_en_i & ~flush_i & (wr_addr_i == 12'h320);
        mscratch_wr_addr        =   wr_en_i & ~flush_i & (wr_addr_i == 12'h340);
        mepc_wr_addr            =   wr_en_i & ~flush_i & (wr_addr_i == 12'h341);
        mcause_wr_addr          =   wr_en_i & ~flush_i & (wr_addr_i == 12'h342);
        mtval_wr_addr           =   wr_en_i & ~flush_i & (wr_addr_i == 12'h343);
        mcycle_wr_addr          =   wr_en_i & ~flush_i & (wr_addr_i == 12'hB00);
        minstret_wr_addr        =   wr_en_i & ~flush_i & (wr_addr_i == 12'hB02);

        mstatus_rd_addr         =   rd_en_i & ~flush_i & (rd_addr_i == 12'h300);
        misa_rd_addr            =   rd_en_i & ~flush_i & (rd_addr_i == 12'h301);
        mie_rd_addr             =   rd_en_i & ~flush_i & (rd_addr_i == 12'h304);
        mtvec_rd_addr           =   rd_en_i & ~flush_i & (rd_addr_i == 12'h305);
        mcountinhibit_rd_addr   =   rd_en_i & ~flush_i & (rd_addr_i == 12'h320);
        mscratch_rd_addr        =   rd_en_i & ~flush_i & (rd_addr_i == 12'h340);
        mepc_rd_addr            =   rd_en_i & ~flush_i & (rd_addr_i == 12'h341);
        mcause_rd_addr          =   rd_en_i & ~flush_i & (rd_addr_i == 12'h342);
        mtval_rd_addr           =   rd_en_i & ~flush_i & (rd_addr_i == 12'h343);
        mip_rd_addr             =   rd_en_i & ~flush_i & (rd_addr_i == 12'h344);
        mcycle_rd_addr          =   rd_en_i & ~flush_i & (rd_addr_i == 12'hB00);
        minstret_rd_addr        =   rd_en_i & ~flush_i & (rd_addr_i == 12'hB02);
        cycle_rd_addr           =   rd_en_i & ~flush_i & (rd_addr_i == 12'hC00);
        time_rd_addr            =   rd_en_i & ~flush_i & (rd_addr_i == 12'hC01);
        instret_rd_addr         =   rd_en_i & ~flush_i & (rd_addr_i == 12'hC02);
        mvendorid_rd_addr       =   rd_en_i & ~flush_i & (rd_addr_i == 12'hF11);
        marchid_rd_addr         =   rd_en_i & ~flush_i & (rd_addr_i == 12'hF12);
        mimpid_rd_addr          =   rd_en_i & ~flush_i & (rd_addr_i == 12'hF13);
        mhartid_rd_addr         =   rd_en_i & ~flush_i & (rd_addr_i == 12'hF14);

        rd_addr_vec             =   {mstatus_rd_addr,   misa_rd_addr,       mie_rd_addr,        mtvec_rd_addr,  mcountinhibit_rd_addr,
                                     mscratch_rd_addr,  mepc_rd_addr,       mcause_rd_addr,     mtval_rd_addr,  mip_rd_addr,
                                     mcycle_rd_addr,    minstret_rd_addr,   cycle_rd_addr,      time_rd_addr,   instret_rd_addr,
                                     mvendorid_rd_addr, marchid_rd_addr,    mimpid_rd_addr,     mhartid_rd_addr};

        wr_addr_vec             =   {mstatus_wr_addr, mie_wr_addr, mtvec_wr_addr, mcountinhibit_wr_addr, mscratch_wr_addr,
                                     mepc_wr_addr, mcause_wr_addr, mtval_wr_addr, mcycle_wr_addr, minstret_wr_addr};

        rd_fault                =   ~|rd_addr_vec & rd_en_i & ~flush_i;
        wr_fault                =   ~|wr_addr_vec & wr_en_i & ~flush_i;

        exc_valid_o             =   rd_fault | wr_fault;
        exc_code_o              =   5'd2;

        mstatus_wr_mask         =   64'h0000_0000_0000_0088;
        mstatus_one_mask        =   64'h0000_0000_0000_1800;
        mie_wr_mask             =   64'h0000_0000_0000_0888;
        mtvec_wr_mask           =   64'hFFFF_FFFF_FFFF_FFFD;
        mepc_wr_mask            =   64'hFFFF_FFFF_FFFF_FFFC;

        nxt_mstatus             =   (wr_data_i & mstatus_wr_mask) | mstatus_one_mask;
        nxt_mie                 =   wr_data_i & mie_wr_mask;
        nxt_mtvec               =   wr_data_i & mtvec_wr_mask;
        nxt_mepc                =   wr_data_i & mepc_wr_mask;
        
        if (rd_en_i & ~flush_i) begin
            case (rd_addr_i)
                12'h300: rd_data_o  =   mstatus_q;
                12'h301: rd_data_o  =   MISA_Q;
                12'h304: rd_data_o  =   mie_q;
                12'h305: rd_data_o  =   mtvec_q;
                12'h320: rd_data_o  =   mcountinhibit_q;
                12'h340: rd_data_o  =   mscratch_q;
                12'h341: rd_data_o  =   mepc_q;
                12'h342: rd_data_o  =   mcause_q;
                12'h343: rd_data_o  =   mtval_q;
                12'h344: rd_data_o  =   mip_q;
                12'hB00: rd_data_o  =   mcycle_q;
                12'hB02: rd_data_o  =   minstret_q;
                12'hC00: rd_data_o  =   cycle_q;
                12'hC01: rd_data_o  =   time_q;
                12'hC02: rd_data_o  =   instret_q;
                12'hF11: rd_data_o  =   MVENDORID_Q;
                12'hF12: rd_data_o  =   MARCHID_Q;
                12'hF13: rd_data_o  =   MIMPID_Q;
                12'hF14: rd_data_o  =   MHARTID_Q;
                default: rd_data_o  =   64'h0;
            endcase
        end
    end

endmodule;