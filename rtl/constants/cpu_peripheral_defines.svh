    //clint addresses
    localparam logic [15:0] CLINT_MSIP_OFFSET               =   16'h0000;
    localparam logic [15:0] CLINT_MTIMECMP_OFFSET           =   16'h4000;
    localparam logic [15:0] CLINT_MTIME_OFFSET              =   16'hBFF8;

    //plic addresses 
    localparam logic [25:0] PLIC_SRC1_PRIORITY_OFFSET       =   26'h000_0004;
    localparam logic [25:0] PLIC_SRC2_PRIORITY_OFFSET       =   26'h000_0008;
    localparam logic [25:0] PLIC_SRC3_PRIORITY_OFFSET       =   26'h000_000C;
    localparam logic [25:0] PLIC_PENDING_OFFSET             =   26'h000_1000;
    localparam logic [25:0] PLIC_M_ENABLE_OFFSET            =   26'h000_2000;
    localparam logic [25:0] PLIC_S_ENABLE_OFFSET            =   26'h000_2080;
    localparam logic [25:0] PLIC_M_THRESHOLD_OFFSET         =   26'h020_0000;
    localparam logic [25:0] PLIC_M_CLAIM_COMPLETE_OFFSET    =   26'h020_0004;
    localparam logic [25:0] PLIC_S_THRESHOLD_OFFSET         =   26'h020_1000;
    localparam logic [25:0] PLIC_S_CLAIM_COMPLETE_OFFSET    =   26'h020_1004;

    localparam logic [3:0] PLIC_M_ENABLE_WR_MASK            =   4'b1110;
    localparam logic [3:0] PLIC_S_ENABLE_WR_MASK            =   4'b1110;

    localparam logic [1:0] PLIC_UART_SOURCE_ID              =   2'b01;
    localparam logic [1:0] PLIC_SPI_SOURCE_ID               =   2'b10;
    localparam logic [1:0] PLIC_GPIO_SOURCE_ID              =   2'b11;

    //gpio addresses
    localparam logic [11:0] GPIO_INPUT_VAL_OFFSET           =   12'h000;
    localparam logic [11:0] GPIO_INPUT_EN_OFFSET            =   12'h004;
    localparam logic [11:0] GPIO_OUTPUT_EN_OFFSET           =   12'h008;
    localparam logic [11:0] GPIO_OUTPUT_VAL_OFFSET          =   12'h00C;
    localparam logic [11:0] GPIO_RISE_IE_OFFSET             =   12'h018;
    localparam logic [11:0] GPIO_RISE_IP_OFFSET             =   12'h01C;
    localparam logic [11:0] GPIO_FALL_IE_OFFSET             =   12'h020;
    localparam logic [11:0] GPIO_FALL_IP_OFFSET             =   12'h024;
    localparam logic [11:0] GPIO_HIGH_IE_OFFSET             =   12'h028;
    localparam logic [11:0] GPIO_HIGH_IP_OFFSET             =   12'h02C;
    localparam logic [11:0] GPIO_LOW_IE_OFFSET              =   12'h030;
    localparam logic [11:0] GPIO_LOW_IP_OFFSET              =   12'h034;
    localparam logic [11:0] GPIO_IOF_EN_OFFSET              =   12'h038;
    localparam logic [11:0] GPIO_IOF_SEL_OFFSET             =   12'h03C;
    localparam logic [11:0] GPIO_OUT_XOR_OFFSET             =   12'h040;

    //uart addresses
    localparam logic [11:0] UART_TXDATA_OFFSET              =   12'h000;
    localparam logic [11:0] UART_RXDATA_OFFSET              =   12'h004;
    localparam logic [11:0] UART_TXCTRL_OFFSET              =   12'h008;
    localparam logic [11:0] UART_RXCTRL_OFFSET              =   12'h00C;
    localparam logic [11:0] UART_IE_OFFSET                  =   12'h010;
    localparam logic [11:0] UART_IP_OFFSET                  =   12'h014;
    localparam logic [11:0] UART_DIV_OFFSET                 =   12'h018;

    localparam logic [18:0] UART_TXCTRL_WMASK               =   19'h70003;
    localparam logic [18:0] UART_TXCTRL_WMASK               =   19'h70001;

    //spi addresses
    localparam logic [11:0] SPI_SCKDIV_OFFSET               =   12'h000;
    localparam logic [11:0] SPI_SCKMODE_OFFSET              =   12'h004;
    localparam logic [11:0] SPI_CSID_OFFSET                 =   12'h010;
    localparam logic [11:0] SPI_CSDEF_OFFSET                =   12'h014;
    localparam logic [11:0] SPI_CSMODE_OFFSET               =   12'h018;
    localparam logic [11:0] SPI_DELAY0_OFFSET               =   12'h028;
    localparam logic [11:0] SPI_DELAY1_OFFSET               =   12'h02C;
    localparam logic [11:0] SPI_FMT_OFFSET                  =   12'h040;
    localparam logic [11:0] SPI_TXDATA_OFFSET               =   12'h048;
    localparam logic [11:0] SPI_RXDATA_OFFSET               =   12'h04C;
    localparam logic [11:0] SPI_TXMARK_OFFSET               =   12'h050;
    localparam logic [11:0] SPI_RXMARK_OFFSET               =   12'h054;
    localparam logic [11:0] SPI_IE_OFFSET                   =   12'h070;
    localparam logic [11:0] SPI_IP_OFFSET                   =   12'h074;

    localparam logic [23:0] SPI_DELAY0_WMASK                =   24'hFF00FF;
    localparam logic [23:0] SPI_DELAY1_WMASK                =   24'hFF00FF;
    localparam logic [19:0] SPI_FMT_WMASK                   =   20'hF000C;

    //spi modes
    localparam logic [1:0] SPI_AUTO_CSMODE                  =   2'b00;
    localparam logic [1:0] SPI_HOLD_CSMODE                  =   2'b10;
    localparam logic [1:0] SPI_OFF_CSMODE                   =   2'b11;