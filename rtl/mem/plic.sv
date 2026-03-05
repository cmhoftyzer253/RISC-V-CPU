import cpu_utils::*;

module plic (
    input logic                 clk,
    input logic                 resetn,

    input logic                 req_valid_i,
    input logic [63:0]          req_addr_i,
    input mem_access_size_t     req_byte_en_i,
    input logic                 req_wr_i,
    input logic [63:0]          req_wr_data_i,

    output logic [63:0]         plic_rd_data_o,
    output logic                plic_resp_valid_o,

    input logic                 signal1_i,
    input logic                 signal2_i,
    input logic                 signal3_i,
    input logic                 signal4_i,
    input logic                 signal5_i,
    input logic                 signal6_i,
    input logic                 signal7_i,
    input logic                 signal8_i,

    output logic                eip_o,

    output logic                exc_valid_o,
    output logic [4:0]          exc_code_o

);

    localparam PRIORITY_IRQ1_ADDR           =   64'h0000_0000_0C00_0004;
    localparam PRIORITY_IRQ2_ADDR           =   64'h0000_0000_0C00_0008;
    localparam PRIORITY_IRQ3_ADDR           =   64'h0000_0000_0C00_000C;
    localparam PRIORITY_IRQ4_ADDR           =   64'h0000_0000_0C00_0010;
    localparam PRIORITY_IRQ5_ADDR           =   64'h0000_0000_0C00_0014;
    localparam PRIORITY_IRQ6_ADDR           =   64'h0000_0000_0C00_0018;
    localparam PRIORITY_IRQ7_ADDR           =   64'h0000_0000_0C00_001C;
    localparam PRIORITY_IRQ8_ADDR           =   64'h0000_0000_0C00_0020;
    localparam IP_ADDR                      =   64'h0000_0000_0C00_1000;
    localparam ENABLE_IRQ_ADDR              =   64'h0000_0000_0C00_2000;
    localparam PRIORITY_THRESHOLD_ADDR      =   64'h0000_0000_0C20_0000;
    localparam CLAIM_COMPLETE_ADDR          =   64'h0000_0000_0C20_0004;

    logic                       gw_irq1;
    logic                       gw_irq2;
    logic                       gw_irq3;
    logic                       gw_irq4;
    logic                       gw_irq5;
    logic                       gw_irq6;
    logic                       gw_irq7;
    logic                       gw_irq8;

    logic [2:0]                 priority_irq1_q;      
    logic [2:0]                 priority_irq2_q;      
    logic [2:0]                 priority_irq3_q;      
    logic [2:0]                 priority_irq4_q;      
    logic [2:0]                 priority_irq5_q;     
    logic [2:0]                 priority_irq6_q;    
    logic [2:0]                 priority_irq7_q;      
    logic [2:0]                 priority_irq8_q;     

    logic [7:0]                 ip_q; 
    logic [7:0]                 enable_irq_q;    
    logic [2:0]                 priority_threshold_q; 
    logic [3:0]                 claim_complete;     

    logic [7:0]                 gw_valid;

    logic                       irq_ongoing_q;
    logic [3:0]                 irq_ongoing_id_q;    
    
    logic                       unaligned_addr;
    logic                       acc_fault_size;
    logic                       acc_fault_addr_wr;
    logic                       acc_fault_addr_rd;
    logic                       acc_fault;

    logic [2:0]                 priority_irq_mask [7:0];

    logic [3:0]                 stg1_idx [3:0];
    logic [2:0]                 stg1_priority [3:0];

    logic [3:0]                 stg2_idx [1:0];
    logic [2:0]                 stg2_priority [1:0];

    logic [3:0]                 claim_complete_raw;
    logic [2:0]                 claim_complete_priority;

    logic [7:0]                 nxt_ip;
    logic [7:0]                 ip_valid;

    logic                       claim_irq1;
    logic                       claim_irq2;
    logic                       claim_irq3;
    logic                       claim_irq4;
    logic                       claim_irq5;
    logic                       claim_irq6;
    logic                       claim_irq7;
    logic                       claim_irq8;

    irq_gw u_irq_sw_gw1 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal1_i),
        .gw_irq_o   (gw_irq1)
    );

    irq_gw u_irq_sw_gw2 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal2_i),
        .gw_irq_o   (gw_irq2)
    );

    irq_gw u_irq_sw_gw3 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal3_i),
        .gw_irq_o   (gw_irq3)
    );

    irq_gw u_irq_sw_gw4 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal4_i),
        .gw_irq_o   (gw_irq4)
    );

    irq_gw u_irq_sw_gw5 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal5_i),
        .gw_irq_o   (gw_irq5)
    );

    irq_gw u_irq_sw_gw6 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal6_i),
        .gw_irq_o   (gw_irq6)
    );

    irq_gw u_irq_sw_gw7 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal7_i),
        .gw_irq_o   (gw_irq7)
    );

    irq_gw u_irq_sw_gw8 (
        .clk        (clk),
        .resetn     (resetn),
        .val_i      (signal8_i),
        .gw_irq_o   (gw_irq8)
    );

    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            priority_irq1_q         <=  3'b0;
            priority_irq2_q         <=  3'b0;
            priority_irq3_q         <=  3'b0;
            priority_irq4_q         <=  3'b0;
            priority_irq5_q         <=  3'b0;
            priority_irq6_q         <=  3'b0;
            priority_irq7_q         <=  3'b0;
            priority_irq8_q         <=  3'b0;

            ip_q                    <=  8'b0;
            irq_ongoing_q           <=  1'b0;
            irq_ongoing_id_q        <=  4'b0;

            enable_irq_q            <=  8'b0;
            priority_threshold_q    <=  3'b0;
        end else begin
            ip_q                    <=  nxt_ip;

            if (req_valid_i & req_wr_i & ~exc_valid_o) begin
                case (req_addr_i)
                    PRIORITY_IRQ1_ADDR: priority_irq1_q             <=  req_wr_data_i[2:0];
                    PRIORITY_IRQ2_ADDR: priority_irq2_q             <=  req_wr_data_i[2:0];
                    PRIORITY_IRQ3_ADDR: priority_irq3_q             <=  req_wr_data_i[2:0];
                    PRIORITY_IRQ4_ADDR: priority_irq4_q             <=  req_wr_data_i[2:0];
                    PRIORITY_IRQ5_ADDR: priority_irq5_q             <=  req_wr_data_i[2:0];
                    PRIORITY_IRQ6_ADDR: priority_irq6_q             <=  req_wr_data_i[2:0];
                    PRIORITY_IRQ7_ADDR: priority_irq7_q             <=  req_wr_data_i[2:0];
                    PRIORITY_IRQ8_ADDR: priority_irq8_q             <=  req_wr_data_i[2:0];
                    ENABLE_IRQ_ADDR: enable_irq_q                   <=  req_wr_data_i[7:0];
                    PRIORITY_THRESHOLD_ADDR: priority_threshold_q   <=  req_wr_data_i[2:0];
                    CLAIM_COMPLETE_ADDR: begin
                        if (req_wr_data_i[3:0] == irq_ongoing_id_q) begin
                            irq_ongoing_q                           <=  1'b0;
                            irq_ongoing_id_q                        <=  4'b0;
                        end
                    end
                endcase
            end else if (req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR)) begin
                irq_ongoing_q       <=  |claim_complete[3:0];
                irq_ongoing_id_q    <=  claim_complete[3:0];
            end
        end
    end

    always_comb begin
        plic_rd_data_o                  =   64'h0;
        plic_resp_valid_o               =   1'b0;

        acc_fault_addr_rd               =   1'b0;
        
        unaligned_addr                  =   |req_addr_i[1:0];
        acc_fault_size                  =   (req_byte_en_i == BYTE) | (req_byte_en_i == HALF_WORD) | (req_byte_en_i == DOUBLE_WORD);
        acc_fault_addr_wr               =   req_wr_i & ~(
                                            (req_addr_i == PRIORITY_IRQ1_ADDR)      | 
                                            (req_addr_i == PRIORITY_IRQ2_ADDR)      | 
                                            (req_addr_i == PRIORITY_IRQ3_ADDR)      |
                                            (req_addr_i == PRIORITY_IRQ4_ADDR)      |
                                            (req_addr_i == PRIORITY_IRQ5_ADDR)      |
                                            (req_addr_i == PRIORITY_IRQ6_ADDR)      |
                                            (req_addr_i == PRIORITY_IRQ7_ADDR)      |
                                            (req_addr_i == PRIORITY_IRQ8_ADDR)      |
                                            (req_addr_i == ENABLE_IRQ_ADDR)         |
                                            (req_addr_i == PRIORITY_THRESHOLD_ADDR) |
                                            (req_addr_i == CLAIM_COMPLETE_ADDR));

        //loads
        if (~req_wr_i & req_valid_i & ~(unaligned_addr | acc_fault_size)) begin
            case (req_addr_i)
                PRIORITY_IRQ1_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq1_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_IRQ2_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq2_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_IRQ3_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq3_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_IRQ4_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq4_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_IRQ5_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq5_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_IRQ6_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq6_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_IRQ7_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq7_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_IRQ8_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_irq8_q};
                    plic_resp_valid_o   =   1'b1;
                end
                IP_ADDR: begin
                    plic_rd_data_o      =   {56'h0, ip_q};
                    plic_resp_valid_o   =   1'b1;
                end
                ENABLE_IRQ_ADDR: begin
                    plic_rd_data_o      =   {56'h0, enable_irq_q};
                    plic_resp_valid_o   =   1'b1;
                end
                PRIORITY_THRESHOLD_ADDR: begin
                    plic_rd_data_o      =   {61'h0, priority_threshold_q};
                    plic_resp_valid_o   =   1'b1;
                end
                CLAIM_COMPLETE_ADDR: begin
                    plic_rd_data_o      =   {60'h0, claim_complete};
                    plic_resp_valid_o   =   1'b1;
                end
                default: begin
                    plic_rd_data_o      =   64'h0;
                    plic_resp_valid_o   =   1'b1;

                    acc_fault_addr_rd   =   1'b1;
                end
            endcase
        end else if (req_wr_i & req_valid_i & ~(unaligned_addr | acc_fault_size | acc_fault_addr_wr)) begin
            plic_resp_valid_o           =   1'b1;
        end

        acc_fault       =   acc_fault_size | acc_fault_addr_rd | acc_fault_addr_wr;

        exc_valid_o     =   req_valid_i & (unaligned_addr | acc_fault_size | acc_fault_addr_rd | acc_fault_addr_wr); 
        exc_code_o      =   ({5{unaligned_addr & ~acc_fault & ~req_wr_i}} & 5'd4)   | 
                            ({5{unaligned_addr & ~acc_fault &  req_wr_i}} & 5'd6)   |
                            ({5{acc_fault & ~req_wr_i}} & 5'd5)                     |
                            ({5{acc_fault &  req_wr_i}} & 5'd7);     

        //highest priority arbiter
        //set priorities to 0 if masked
        priority_irq_mask[0]    =   {3{enable_irq_q[0] & ip_q[0]}} & priority_irq1_q;
        priority_irq_mask[1]    =   {3{enable_irq_q[1] & ip_q[1]}} & priority_irq2_q;
        priority_irq_mask[2]    =   {3{enable_irq_q[2] & ip_q[2]}} & priority_irq3_q;
        priority_irq_mask[3]    =   {3{enable_irq_q[3] & ip_q[3]}} & priority_irq4_q;
        priority_irq_mask[4]    =   {3{enable_irq_q[4] & ip_q[4]}} & priority_irq5_q;
        priority_irq_mask[5]    =   {3{enable_irq_q[5] & ip_q[5]}} & priority_irq6_q;
        priority_irq_mask[6]    =   {3{enable_irq_q[6] & ip_q[6]}} & priority_irq7_q;
        priority_irq_mask[7]    =   {3{enable_irq_q[7] & ip_q[7]}} & priority_irq8_q;

        //arbitration stage 1
        for (int i=0; i<4; i++) begin
            if (priority_irq_mask[2*i + 1] > priority_irq_mask[2*i]) begin
                stg1_idx[i]         =   2*i + 1;
                stg1_priority[i]    =   priority_irq_mask[2*i + 1];
            end else begin
                stg1_idx[i]         =   2*i;
                stg1_priority[i]    =   priority_irq_mask[2*i];
            end
        end

        //arbitration stage 2
        for (int i=0; i<2; i++) begin
            if (stg1_priority[2*i + 1] > stg1_priority[2*i]) begin
                stg2_idx[i]         =   stg1_idx[2*i + 1];
                stg2_priority[i]    =   stg1_priority[2*i + 1];
            end else begin
                stg2_idx[i]         =   stg1_idx[2*i];
                stg2_priority[i]    =   stg1_priority[2*i];
            end
        end 

        //arbitration final stage
        claim_complete_raw          =   (stg2_priority[1] > stg2_priority[0]) ? stg2_idx[1] : stg2_idx[0];  
        claim_complete_priority     =   (stg2_priority[1] > stg2_priority[0]) ? stg2_priority[1] : stg2_priority[0];
        claim_complete              =   (claim_complete_raw + 4'b1) & {4{claim_complete_priority > priority_threshold_q}};

        gw_valid[0]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd1));
        gw_valid[1]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd2));
        gw_valid[2]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd3));
        gw_valid[3]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd4));
        gw_valid[4]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd5));
        gw_valid[5]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd6));
        gw_valid[6]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd7));
        gw_valid[7]     =   ~(irq_ongoing_q & (irq_ongoing_id_q == 4'd8));

        claim_irq1      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd1);
        claim_irq2      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd2);
        claim_irq3      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd3);
        claim_irq4      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd4);
        claim_irq5      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd5);
        claim_irq6      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd6);
        claim_irq7      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd7);
        claim_irq8      =   req_valid_i & ~req_wr_i & ~exc_valid_o & (req_addr_i == CLAIM_COMPLETE_ADDR) & (claim_complete == 4'd8);

        nxt_ip[0]       =   ~claim_irq1 & ((gw_irq1 & gw_valid[0]) | ip_q[0]);
        nxt_ip[1]       =   ~claim_irq2 & ((gw_irq2 & gw_valid[1]) | ip_q[1]);
        nxt_ip[2]       =   ~claim_irq3 & ((gw_irq3 & gw_valid[2]) | ip_q[2]);
        nxt_ip[3]       =   ~claim_irq4 & ((gw_irq4 & gw_valid[3]) | ip_q[3]);
        nxt_ip[4]       =   ~claim_irq5 & ((gw_irq5 & gw_valid[4]) | ip_q[4]);
        nxt_ip[5]       =   ~claim_irq6 & ((gw_irq6 & gw_valid[5]) | ip_q[5]);
        nxt_ip[6]       =   ~claim_irq7 & ((gw_irq7 & gw_valid[6]) | ip_q[6]);
        nxt_ip[7]       =   ~claim_irq8 & ((gw_irq8 & gw_valid[7]) | ip_q[7]);

        ip_valid[0]     =   nxt_ip[0] & enable_irq_q[0] & (priority_irq1_q > priority_threshold_q);
        ip_valid[1]     =   nxt_ip[1] & enable_irq_q[1] & (priority_irq2_q > priority_threshold_q);
        ip_valid[2]     =   nxt_ip[2] & enable_irq_q[2] & (priority_irq3_q > priority_threshold_q);
        ip_valid[3]     =   nxt_ip[3] & enable_irq_q[3] & (priority_irq4_q > priority_threshold_q);
        ip_valid[4]     =   nxt_ip[4] & enable_irq_q[4] & (priority_irq5_q > priority_threshold_q);
        ip_valid[5]     =   nxt_ip[5] & enable_irq_q[5] & (priority_irq6_q > priority_threshold_q);
        ip_valid[6]     =   nxt_ip[6] & enable_irq_q[6] & (priority_irq7_q > priority_threshold_q);
        ip_valid[7]     =   nxt_ip[7] & enable_irq_q[7] & (priority_irq8_q > priority_threshold_q);

        eip_o           =   |ip_valid;
    end 

endmodule