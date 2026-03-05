module csr (
    input logic             clk,
    input logic             resetn,

    //software loads/stores
    input logic             rd_en_i,
    input logic [11:0]      rd_addr_i,
    output logic [63:0]     rd_data_o,

    input logic             wr_en_i,
    input logic [11:0]      wr_addr_i,
    input logic [63:0]      wr_data_i,

    //trap controller interface
    input logic             trap_en_i,
    input logic             mret_i,

    input logic [63:0]      nxt_mepc_i,
    input logic [5:0]       nxt_mcause_i,

    output logic            mstatus_mie_o,
    output logic            mie_ext_ire_o,
    output logic            mie_sw_ire_o,
    output logic            mie_timer_ire_o,
    output logic            mie_lcof_ire_o,

    output logic            mie_ext_irp_o,
    output logic            mie_sw_irp_o,
    output logic            mie_timer_irp_o,
    output logic            mie_lcof_irp_o,

    input logic             eip_i,
    input logic             msip_i,
    input logic             mtip_i,

    output logic [63:0]     mtvec_o,
    output logic [63:0]     mepc_o,

    input logic [63:0]      mtime_i,
    input logic             minstret_incr_i,

    //id wfi interface
    output logic            wfi_end_o,
    output logic            wfi_fetch_flush_o,

    output logic            exc_valid_o,
    output logic [4:0]      exc_code_o
);  

    localparam MSTATUS_ADDR         =   12'h300;
    localparam MISA_ADDR            =   12'h301;
    localparam MIE_ADDR             =   12'h304;
    localparam MTVEC_ADDR           =   12'h305;
    localparam MCOUNTINHIBIT_ADDR   =   12'h320;
    localparam MSCRATCH_ADDR        =   12'h340;
    localparam MEPC_ADDR            =   12'h341;
    localparam MCAUSE_ADDR          =   12'h342;
    localparam MTVAL_ADDR           =   12'h343;
    localparam MIP_ADDR             =   12'h344;
    localparam MCOUNTOVF_ADDR       =   12'h7E8;
    localparam MCYCLE_ADDR          =   12'hB00;
    localparam MINSTRET_ADDR        =   12'hB02;
    localparam CYCLE_ADDR           =   12'hC00;
    localparam TIME_ADDR            =   12'hC01;
    localparam INSTRET_ADDR         =   12'hC02;
    localparam MVENDORID_ADDR       =   12'hF11;
    localparam MARCHID_ADDR         =   12'hF12;
    localparam MIMPID_ADDR          =   12'hF13;
    localparam MHARTID_ADDR         =   12'hF14;
        
    localparam MISA_Q               =   64'h8000_0000_0000_1100;
    localparam MVENDORID_Q          =   64'h0;
    localparam MARCHID_Q            =   64'h0;
    localparam MIMPID_Q             =   64'h0;
    localparam MHARTID_Q            =   64'h0;  

    logic [63:0]            mstatus_q;        
    logic [13:0]            mie_q;            
    logic [63:0]            mtvec_q;          
    logic [63:0]            mcountinhibit_q;  
    logic [63:0]            mscratch_q;       
    logic [63:0]            mepc_q;           
    logic [63:0]            mcause_q;         
    logic [63:0]            mtval_q;          
    logic [13:0]            mip_q;            
    logic [64:0]            mcycle_q;
    logic [64:0]            minstret_q; 
    logic [2:0]             mcountovf_q;

    logic [63:0]            cycle_q;
    logic [63:0]            time_q;
    logic [63:0]            instret_q;

    logic [63:0]            nxt_mstatus;
    logic [13:0]            nxt_mip;
    logic [13:0]            nxt_mie;
    logic [63:0]            nxt_mtvec;
    logic [63:0]            nxt_mcountinhibit;
    logic [63:0]            nxt_mepc;
    logic [2:0]             nxt_mcountovf;

    logic [2:0]             mcountovf_pulse;

    logic [63:0]            mstatus_wr_mask;
    logic [63:0]            mstatus_one_mask;
    logic [13:0]            mie_wr_mask; 
    logic [63:0]            mtvec_wr_mask;
    logic [63:0]            mcountinhibit_mask;
    logic [63:0]            mepc_wr_mask;
    logic [2:0]             mcountovf_wr_mask;

    logic                   mcycle_ovf_2q;
    logic                   minstret_ovf_2q;
    
    logic                   lcof;

    logic                   acc_fault_addr_rd;
    logic                   acc_fault_addr_wr;

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            mstatus_q               <=  64'h0000_0000_0000_1800;
            mie_q                   <=  14'h0;
            mtvec_q                 <=  64'h0000_0000_8000_0000;
            mcountinhibit_q         <=  64'h0;
            mscratch_q              <=  64'h0;
            mepc_q                  <=  64'h0;
            mcause_q                <=  64'h0;
            mtval_q                 <=  64'h0;
            mip_q                   <=  14'h0;
            mcycle_q                <=  65'h0;
            minstret_q              <=  65'h0;
            mcountovf_q             <=  3'h0;
        end else begin
            mip_q                   <=  nxt_mip;
            mcountovf_q             <=  mcountovf_pulse | mcountovf_q;

            if (~mcountinhibit_q[0]) begin
                mcycle_q            <=  mcycle_q + 65'b1;
            end
            
            if (~mcountinhibit_q[2]) begin
                minstret_q          <=  minstret_q + {64'h0, minstret_incr_i};
            end
            
            if (trap_en_i) begin
                mepc_q              <=  nxt_mepc_i;
                mcause_q            <=  {nxt_mcause_i[5], 58'h0, nxt_mcause_i[4:0]};
                mstatus_q[7]        <=  mstatus_q[3];
                mstatus_q[3]        <=  1'b0;
                mstatus_q[12:11]    <=  2'b11;
            end else if (mret_i) begin
                mstatus_q[3]        <=  mstatus_q[7];
                mstatus_q[7]        <=  1'b1;
                mstatus_q[12:11]    <=  2'b11;
            end else if (wr_en_i) begin
                case (wr_addr_i)
                    MSTATUS_ADDR:           mstatus_q           <= nxt_mstatus;
                    MIE_ADDR:               mie_q               <= nxt_mie;
                    MTVEC_ADDR:             mtvec_q             <= nxt_mtvec;
                    MCOUNTINHIBIT_ADDR:     mcountinhibit_q     <= nxt_mcountinhibit;
                    MSCRATCH_ADDR:          mscratch_q          <= wr_data_i;
                    MEPC_ADDR:              mepc_q              <= nxt_mepc;
                    MCAUSE_ADDR:            mcause_q            <= wr_data_i;
                    MTVAL_ADDR:             mtval_q             <= wr_data_i;
                    MCYCLE_ADDR:            mcycle_q            <= {1'b0, wr_data_i};
                    MINSTRET_ADDR:          minstret_q          <= {1'b0, wr_data_i};
                    MCOUNTOVF_ADDR:         mcountovf_q         <= nxt_mcountovf | mcountovf_pulse;
                endcase
            end
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            mcycle_ovf_2q       <= 1'b0;
            minstret_ovf_2q     <= 1'b0;
        end else begin
            mcycle_ovf_2q       <= mcycle_q[64];
            minstret_ovf_2q     <= minstret_q[64];
        end
    end

    always_comb begin
        rd_data_o           =   64'h0;
        acc_fault_addr_rd   =   1'b0;

        mstatus_mie_o       =   mstatus_q[3];
        mie_ext_ire_o       =   nxt_mie[11];
        mie_lcof_ire_o      =   nxt_mie[13];
        mie_sw_ire_o        =   nxt_mie[3];
        mie_timer_ire_o     =   nxt_mie[7];

        mie_ext_irp_o       =   nxt_mip[11];
        mie_lcof_irp_o      =   nxt_mip[13];
        mie_sw_irp_o        =   nxt_mip[3];
        mie_timer_irp_o     =   nxt_mip[7];

        mtvec_o             =   mtvec_q;
        mepc_o              =   mepc_q;

        wfi_end_o           =   (mie_ext_ire_o & mie_ext_irp_o)     |
                                (mie_lcof_ire_o & mie_lcof_irp_o)   |
                                (mie_sw_ire_o & mie_sw_irp_o)       |
                                (mie_timer_ire_o & mie_timer_irp_o);

        wfi_fetch_flush_o   =   wfi_end_o & mstatus_mie_o;

        mcountovf_pulse[0]    =   ~mcycle_ovf_2q & mcycle_q[64];
        mcountovf_pulse[1]    =   1'b0;
        mcountovf_pulse[2]    =   ~minstret_ovf_2q & minstret_q[64];

        lcof                =   mcountovf_q[2] | mcountovf_q[0] | mcountovf_pulse[2] | mcountovf_pulse[0];

        nxt_mip             =   {lcof, 1'b0, eip_i, 3'b0, mtip_i, 3'b0, msip_i, 3'b0};

        cycle_q             =   mcycle_q[63:0];
        time_q              =   mtime_i;
        instret_q           =   minstret_q[63:0];  

        acc_fault_addr_wr   =   wr_en_i & ~trap_en_i & ~(
                                (wr_addr_i == MSTATUS_ADDR)         | 
                                (wr_addr_i == MIE_ADDR)             | 
                                (wr_addr_i == MTVEC_ADDR)           | 
                                (wr_addr_i == MCOUNTINHIBIT_ADDR)   |
                                (wr_addr_i == MSCRATCH_ADDR)        | 
                                (wr_addr_i == MEPC_ADDR)            | 
                                (wr_addr_i == MCAUSE_ADDR)          | 
                                (wr_addr_i == MTVAL_ADDR)           | 
                                (wr_addr_i == MIP_ADDR)             |
                                (wr_addr_i == MCOUNTOVF_ADDR)       |
                                (wr_addr_i == MCYCLE_ADDR)          |
                                (wr_addr_i == MINSTRET_ADDR));

        mstatus_wr_mask     =   64'h0000_0000_0000_0088;
        mstatus_one_mask    =   64'h0000_0000_0000_1800;

        nxt_mstatus         =   (wr_data_i & mstatus_wr_mask) | mstatus_one_mask;

        mie_wr_mask         =   14'h2888;
        mtvec_wr_mask       =   64'hFFFF_FFFF_FFFF_FFFD;
        mepc_wr_mask        =   64'hFFFF_FFFF_FFFF_FFFC;
        mcountovf_wr_mask   =   3'b101;
        mcountinhibit_mask  =   64'h0000_0000_FFFF_FFFD;

        nxt_mie             =   wr_data_i[13:0] & mie_wr_mask;
        nxt_mtvec           =   wr_data_i & mtvec_wr_mask;
        nxt_mepc            =   wr_data_i & mepc_wr_mask;
        nxt_mcountovf       =   wr_data_i[2:0] & mcountovf_wr_mask;
        nxt_mcountinhibit   =   wr_data_i & mcountinhibit_mask;

        if (rd_en_i & ~trap_en_i) begin
            case (rd_addr_i)
                MSTATUS_ADDR: rd_data_o         =   mstatus_q;
                MISA_ADDR: rd_data_o            =   MISA_Q;
                MIE_ADDR: rd_data_o             =   mie_q;
                MTVEC_ADDR: rd_data_o           =   mtvec_q;
                MCOUNTINHIBIT_ADDR: rd_data_o   =   mcountinhibit_q;
                MSCRATCH_ADDR: rd_data_o        =   mscratch_q;
                MEPC_ADDR: rd_data_o            =   mepc_q;
                MCAUSE_ADDR: rd_data_o          =   mcause_q;
                MTVAL_ADDR: rd_data_o           =   mtval_q;
                MIP_ADDR: rd_data_o             =   {50'h0, mip_q};
                MCOUNTOVF_ADDR: rd_data_o       =   {61'h0, mcountovf_q};
                MCYCLE_ADDR: rd_data_o          =   mcycle_q[63:0];
                MINSTRET_ADDR: rd_data_o        =   minstret_q[63:0];
                CYCLE_ADDR: rd_data_o           =   cycle_q;
                TIME_ADDR: rd_data_o            =   time_q;
                INSTRET_ADDR: rd_data_o         =   instret_q;
                MVENDORID_ADDR: rd_data_o       =   MVENDORID_Q;
                MARCHID_ADDR: rd_data_o         =   MARCHID_Q;
                MIMPID_ADDR: rd_data_o          =   MIMPID_Q;
                MHARTID_ADDR: rd_data_o         =   MHARTID_Q;
                default: begin
                    rd_data_o                   =   64'h0;
                    acc_fault_addr_rd           =   1'b1;
                end         
            endcase
        end

        exc_valid_o         =   acc_fault_addr_wr | acc_fault_addr_rd;
        exc_code_o          =   5'd2;
    end

endmodule