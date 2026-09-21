
//CSR addresses
localparam logic [11:0] SSTATUS_ADDR            =   12'h100;
localparam logic [11:0] SIE_ADDR                =   12'h104;
localparam logic [11:0] STVEC_ADDR              =   12'h105;
localparam logic [11:0] SCOUNTEREN_ADDR         =   12'h106;
localparam logic [11:0] SENVCFG_ADDR            =   12'h10A;
localparam logic [11:0] SSCRATCH_ADDR           =   12'h140;
localparam logic [11:0] SEPC_ADDR               =   12'h141;
localparam logic [11:0] SCAUSE_ADDR             =   12'h142;
localparam logic [11:0] STVAL_ADDR              =   12'h143;
localparam logic [11:0] SIP_ADDR                =   12'h144;
localparam logic [11:0] SATP_ADDR               =   12'h180;

localparam logic [11:0] MSTATUS_ADDR            =   12'h300;
localparam logic [11:0] MISA_ADDR               =   12'h301;
localparam logic [11:0] MEDELEG_ADDR            =   12'h302;
localparam logic [11:0] MIDELEG_ADDR            =   12'h303;
localparam logic [11:0] MIE_ADDR                =   12'h304;
localparam logic [11:0] MTVEC_ADDR              =   12'h305;
localparam logic [11:0] MCOUNTEREN_ADDR         =   12'h306;
localparam logic [11:0] MENVCFG_ADDR            =   12'h30A;
localparam logic [11:0] MCOUNTINHIBIT_ADDR      =   12'h320;

localparam logic [11:0] MHPMEVENT3_ADDR         =   12'h323;
localparam logic [11:0] MHPMEVENT4_ADDR         =   12'h324;
localparam logic [11:0] MHPMEVENT5_ADDR         =   12'h325;
localparam logic [11:0] MHPMEVENT6_ADDR         =   12'h326;
localparam logic [11:0] MHPMEVENT7_ADDR         =   12'h327;
localparam logic [11:0] MHPMEVENT8_ADDR         =   12'h328;
localparam logic [11:0] MHPMEVENT9_ADDR         =   12'h329;
localparam logic [11:0] MHPMEVENT10_ADDR        =   12'h32A;
localparam logic [11:0] MHPMEVENT11_ADDR        =   12'h32B;
localparam logic [11:0] MHPMEVENT12_ADDR        =   12'h32C;
localparam logic [11:0] MHPMEVENT13_ADDR        =   12'h32D;
localparam logic [11:0] MHPMEVENT14_ADDR        =   12'h32E;
localparam logic [11:0] MHPMEVENT15_ADDR        =   12'h32F;
localparam logic [11:0] MHPMEVENT16_ADDR        =   12'h330;
localparam logic [11:0] MHPMEVENT17_ADDR        =   12'h331;
localparam logic [11:0] MHPMEVENT18_ADDR        =   12'h332;
localparam logic [11:0] MHPMEVENT19_ADDR        =   12'h333;
localparam logic [11:0] MHPMEVENT20_ADDR        =   12'h334;
localparam logic [11:0] MHPMEVENT21_ADDR        =   12'h335;
localparam logic [11:0] MHPMEVENT22_ADDR        =   12'h336;
localparam logic [11:0] MHPMEVENT23_ADDR        =   12'h337;
localparam logic [11:0] MHPMEVENT24_ADDR        =   12'h338;
localparam logic [11:0] MHPMEVENT25_ADDR        =   12'h339;
localparam logic [11:0] MHPMEVENT26_ADDR        =   12'h33A;
localparam logic [11:0] MHPMEVENT27_ADDR        =   12'h33B;
localparam logic [11:0] MHPMEVENT28_ADDR        =   12'h33C;
localparam logic [11:0] MHPMEVENT29_ADDR        =   12'h33D;
localparam logic [11:0] MHPMEVENT30_ADDR        =   12'h33E;
localparam logic [11:0] MHPMEVENT31_ADDR        =   12'h33F;

localparam logic [11:0] MSCRATCH_ADDR           =   12'h340;
localparam logic [11:0] MEPC_ADDR               =   12'h341;
localparam logic [11:0] MCAUSE_ADDR             =   12'h342;
localparam logic [11:0] MTVAL_ADDR              =   12'h343;
localparam logic [11:0] MIP_ADDR                =   12'h344;

localparam logic [11:0] PMPCFG0_ADDR            =   12'h3A0;
localparam logic [11:0] PMPCFG2_ADDR            =   12'h3A2;
localparam logic [11:0] PMPADDR0_ADDR           =   12'h3B0;
localparam logic [11:0] PMPADDR1_ADDR           =   12'h3B1;
localparam logic [11:0] PMPADDR2_ADDR           =   12'h3B2;
localparam logic [11:0] PMPADDR3_ADDR           =   12'h3B3;
localparam logic [11:0] PMPADDR4_ADDR           =   12'h3B4;
localparam logic [11:0] PMPADDR5_ADDR           =   12'h3B5;
localparam logic [11:0] PMPADDR6_ADDR           =   12'h3B6;
localparam logic [11:0] PMPADDR7_ADDR           =   12'h3B7;
localparam logic [11:0] PMPADDR8_ADDR           =   12'h3B8;
localparam logic [11:0] PMPADDR9_ADDR           =   12'h3B9;
localparam logic [11:0] PMPADDR10_ADDR          =   12'h3BA;
localparam logic [11:0] PMPADDR11_ADDR          =   12'h3BB;
localparam logic [11:0] PMPADDR12_ADDR          =   12'h3BC;
localparam logic [11:0] PMPADDR13_ADDR          =   12'h3BD;
localparam logic [11:0] PMPADDR14_ADDR          =   12'h3BE;
localparam logic [11:0] PMPADDR15_ADDR          =   12'h3BF;

localparam logic [11:0] MCYCLE_ADDR             =   12'hB00;
localparam logic [11:0] MINSTRET_ADDR           =   12'hB02;
localparam logic [11:0] MHPMCOUNTER3_ADDR       =   12'hB03;
localparam logic [11:0] MHPMCOUNTER4_ADDR       =   12'hB04;
localparam logic [11:0] MHPMCOUNTER5_ADDR       =   12'hB05;
localparam logic [11:0] MHPMCOUNTER6_ADDR       =   12'hB06;
localparam logic [11:0] MHPMCOUNTER7_ADDR       =   12'hB07;
localparam logic [11:0] MHPMCOUNTER8_ADDR       =   12'hB08;
localparam logic [11:0] MHPMCOUNTER9_ADDR       =   12'hB09;
localparam logic [11:0] MHPMCOUNTER10_ADDR      =   12'hB0A;
localparam logic [11:0] MHPMCOUNTER11_ADDR      =   12'hB0B;
localparam logic [11:0] MHPMCOUNTER12_ADDR      =   12'hB0C;
localparam logic [11:0] MHPMCOUNTER13_ADDR      =   12'hB0D;
localparam logic [11:0] MHPMCOUNTER14_ADDR      =   12'hB0E;
localparam logic [11:0] MHPMCOUNTER15_ADDR      =   12'hB0F;
localparam logic [11:0] MHPMCOUNTER16_ADDR      =   12'hB10;
localparam logic [11:0] MHPMCOUNTER17_ADDR      =   12'hB11;
localparam logic [11:0] MHPMCOUNTER18_ADDR      =   12'hB12;
localparam logic [11:0] MHPMCOUNTER19_ADDR      =   12'hB13;
localparam logic [11:0] MHPMCOUNTER20_ADDR      =   12'hB14;
localparam logic [11:0] MHPMCOUNTER21_ADDR      =   12'hB15;
localparam logic [11:0] MHPMCOUNTER22_ADDR      =   12'hB16;
localparam logic [11:0] MHPMCOUNTER23_ADDR      =   12'hB17;
localparam logic [11:0] MHPMCOUNTER24_ADDR      =   12'hB18;
localparam logic [11:0] MHPMCOUNTER25_ADDR      =   12'hB19;
localparam logic [11:0] MHPMCOUNTER26_ADDR      =   12'hB1A;
localparam logic [11:0] MHPMCOUNTER27_ADDR      =   12'hB1B;
localparam logic [11:0] MHPMCOUNTER28_ADDR      =   12'hB1C;
localparam logic [11:0] MHPMCOUNTER29_ADDR      =   12'hB1D;
localparam logic [11:0] MHPMCOUNTER30_ADDR      =   12'hB1E;
localparam logic [11:0] MHPMCOUNTER31_ADDR      =   12'hB1F;

localparam logic [11:0] CYCLE_ADDR              =   12'hC00;
localparam logic [11:0] TIME_ADDR               =   12'hC01;
localparam logic [11:0] INSTRET_ADDR            =   12'hC02;
localparam logic [11:0] HPMCOUNTER3_ADDR        =   12'hC03;
localparam logic [11:0] HPMCOUNTER4_ADDR        =   12'hC04;
localparam logic [11:0] HPMCOUNTER5_ADDR        =   12'hC05;
localparam logic [11:0] HPMCOUNTER6_ADDR        =   12'hC06;
localparam logic [11:0] HPMCOUNTER7_ADDR        =   12'hC07;
localparam logic [11:0] HPMCOUNTER8_ADDR        =   12'hC08;
localparam logic [11:0] HPMCOUNTER9_ADDR        =   12'hC09;
localparam logic [11:0] HPMCOUNTER10_ADDR       =   12'hC0A;
localparam logic [11:0] HPMCOUNTER11_ADDR       =   12'hC0B;
localparam logic [11:0] HPMCOUNTER12_ADDR       =   12'hC0C;
localparam logic [11:0] HPMCOUNTER13_ADDR       =   12'hC0D;
localparam logic [11:0] HPMCOUNTER14_ADDR       =   12'hC0E;
localparam logic [11:0] HPMCOUNTER15_ADDR       =   12'hC0F;
localparam logic [11:0] HPMCOUNTER16_ADDR       =   12'hC10;
localparam logic [11:0] HPMCOUNTER17_ADDR       =   12'hC11;
localparam logic [11:0] HPMCOUNTER18_ADDR       =   12'hC12;
localparam logic [11:0] HPMCOUNTER19_ADDR       =   12'hC13;
localparam logic [11:0] HPMCOUNTER20_ADDR       =   12'hC14;
localparam logic [11:0] HPMCOUNTER21_ADDR       =   12'hC15;
localparam logic [11:0] HPMCOUNTER22_ADDR       =   12'hC16;
localparam logic [11:0] HPMCOUNTER23_ADDR       =   12'hC17;
localparam logic [11:0] HPMCOUNTER24_ADDR       =   12'hC18;
localparam logic [11:0] HPMCOUNTER25_ADDR       =   12'hC19;
localparam logic [11:0] HPMCOUNTER26_ADDR       =   12'hC1A;
localparam logic [11:0] HPMCOUNTER27_ADDR       =   12'hC1B;
localparam logic [11:0] HPMCOUNTER28_ADDR       =   12'hC1C;
localparam logic [11:0] HPMCOUNTER29_ADDR       =   12'hC1D;
localparam logic [11:0] HPMCOUNTER30_ADDR       =   12'hC1E;
localparam logic [11:0] HPMCOUNTER31_ADDR       =   12'hC1F;

localparam logic [11:0] MVENDORID_ADDR          =   12'hF11;
localparam logic [11:0] MARCHID_ADDR            =   12'hF12;
localparam logic [11:0] MIMPID_ADDR             =   12'hF13;
localparam logic [11:0] MHARTID_ADDR            =   12'hF14;
localparam logic [11:0] MCONFIGPTR_ADDR         =   12'hF15;


//CSR RO values
localparam logic [63:0] MISA_RO                 =   64'h8000_0000_0014_1101;

//CSR reset values
localparam logic [63:0] MSTATUS_RESET           =   64'h0000_000A_0000_1800;
localparam logic [63:0] MTVEC_RESET             =   RESET_PC;

//CSR S mode read masks - masks bits not visible to S mode
localparam logic [63:0] SSTATUS_RDMASK          =   64'h8000_0003_000C_0122;

//CSR write masks
//  WMASK: write mask - 1 if bit is writeable, 0 if not 
//  HMASK: high mask - 1 if bit is hardwired to 1'b1
localparam logic [63:0] SSTATUS_WMASK           =   64'h0000_0000_0008_0122;
localparam logic [63:0] STVEC_WMASK             =   64'hFFFF_FFFF_FFFF_FFFD;
localparam logic [63:0] SEPC_WMASK              =   64'hFFFF_FFFF_FFFF_FFFC;
localparam logic [63:0] SCAUSE_WMASK            =   64'h8000_0000_0000_001F;
localparam logic [11:0] SIP_WMASK               =   12'h002;

localparam logic [63:0] MSTATUS_WMASK           =   64'h0000_0030_007A_19EA;
localparam logic [63:0] MSTATUS_HMASK           =   64'h0000_000A_0000_0000;
localparam logic [15:0] MEDELEG_WMASK           =   16'h03FFF;
localparam logic [63:0] MIDELEG_WMASK           =   12'222;
localparam logic [11:0] MIE_WMASK               =   12'hAAA;
localparam logic [63:0] MTVEC_WMASK             =   64'hFFFF_FFFF_FFFF_FFFD;
localparam logic [63:0] MENVCFG_WMASK           =   64'h8000_0000_0000_0001;
localparam logic [63:0] MCOUNTINHIBIT_WMASK     =   32'h0000_0005;    
localparam logic [63:0] MEPC_WMASK              =   64'hFFFF_FFFF_FFFF_FFFC;
localparam logic [63:0] MCAUSE_WMASK            =   64'h8000_0000_0000_001F;
localparam logic [11:0] MIP_WMASK               =   12'h222;

          



