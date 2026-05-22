#include <stdint.h>

void rf_golden (
    uint32_t resetn, 
    uint32_t rs1_addr_i, uint32_t rs2_addr_i, uint64_t *rs1_data_o, uint64_t *rs2_data_o,
    uint32_t rd_addr_i, uint32_t wr_en_i, uint64_t wr_data_i
) {

    static uint64_t reg_file[32] = {0};

    uint32_t rs1_addr = rs1_addr_i & 0x1F;
    uint32_t rs2_addr = rs2_addr_i & 0x1F;

    if (!resetn) {
        for (int i=0; i<32; i++) {
            reg_file[i] = 0;
        } 

        *rs1_data_o = 0;
        *rs2_data_o = 0;
    } else {
        *rs1_data_o = (rs1_addr_i == 0) ? 0 : reg_file[rs1_addr_i];
        *rs2_data_o = (rs2_addr_i == 0) ? 0 : reg_file[rs2_addr_i];

        if (wr_en_i && (rd_addr_i != 0)) {
            reg_file[rd_addr_i] = wr_data_i;
        }
    }
}