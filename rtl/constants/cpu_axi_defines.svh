//AXI burst sizes
localparam logic [2:0] AMBA_BYTE                =   3'b000;
localparam logic [2:0] AMBA_HALF_WORD           =   3'b001;
localparam logic [2:0] AMBA_WORD                =   3'b010;
localparam logic [2:0] AMBA_DOUBLE_WORD         =   3'b011;
    
//AXI burst modes
localparam logic [1:0] AXI_FIXED                =   2'b00;
localparam logic [1:0] AXI_INCR                 =   2'b01;
localparam logic [1:0] AXI_WRAP                 =   2'b10;

localparam logic [3:0] CACHE_DEV_NONBUF         =   4'b0000;
localparam logic [3:0] CACHE_NONCACHEABLE       =   4'b0011;
localparam logic [3:0] CACHE_WB_RALLOC          =   4'b1111;

//AXI protection modes
localparam logic [2:0] PROT_IFU                 =   3'b101;
localparam logic [2:0] PROT_LSU                 =   3'b001;

//AXI ids 
localparam logic [3:0] ID_IFU                   =   4'b0000;
localparam logic [3:0] ID_LSU                   =   4'b0001;

//AXI response codes
localparam logic [1:0] OKAY                     =   2'b00;
localparam logic [1:0] EXOKAY                   =   2'b01;
localparam logic [1:0] SLVERR                   =   2'b10;
localparam logic [1:0] DECERR                   =   2'b11;

//AHB htrans codes
localparam logic [1:0] IDLE                     =   2'b00;
localparam logic [1:0] BUSY                     =   2'b10;
localparam logic [1:0] NONSEQ                   =   2'b10;
localparam logic [1:0] SEQ                      =   2'b11;

//AHB burst modes/length
localparam logic [2:0] SINGLE                   =   3'b000;
localparam logic [2:0] INCR                     =   3'b001;
localparam logic [2:0] WRAP4                    =   3'b010;
localparam logic [2:0] INCR4                    =   3'b011;
localparam logic [2:0] WRAP8                    =   3'b100;
localparam logic [2:0] INCR8                    =   3'b101;
localparam logic [2:0] WRAP16                   =   3'b110;
localparam logic [2:0] INCR16                   =   3'b111;