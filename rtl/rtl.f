rtl/utils/cpu_defines.sv
rtl/utils/cpu_types.sv
rtl/utils/cpu_utils.sv

rtl/utils/fifo.sv
rtl/utils/gateway_level.sv
rtl/utils/clock_sync_2ff.sv
rtl/utils/resetn_sync.sv

rtl/top.sv

rtl/core/core.sv
rtl/core/pipeline.sv
rtl/core/arbitrate.sv

rtl/fetch/ifu.sv
rtl/fetch/i_cache.sv
rtl/fetch/i_pma.sv
rtl/fetch/i_pmp.sv

rtl/decode/decode.sv
rtl/decode/csr_addr_decode.sv
rtl/decode/register_file.sv

rtl/execute/alu.sv
rtl/execute/branch_control.sv
rtl/execute/mdu.sv
rtl/execute/multiply.sv
rtl/execute/divide.sv

rtl/mem/lsu.sv
rtl/mem/d_cache.sv
rtl/mem/d_pma.sv
rtl/mem/d_pmp.sv
rtl/mem/load_es_algn.sv
rtl/mem/store_es_algn.sv
rtl/mem/amo_alu.sv
rtl/mem/privileged.sv
rtl/mem/csr.sv
rtl/mem/trap_control.sv

rtl/bus/bus.sv
rtl/bus/axi_ctrl.sv
rtl/bus/ahb_ctrl.sv
rtl/bus/pin_arbitrate.sv
rtl/bus/ahb_boot_rom.sv

rtl/bus/clint.sv
rtl/bus/plic.sv
rtl/bus/uart.sv
rtl/bus/uart_rx.sv
rtl/bus/uart_tx.sv
rtl/bus/spi.sv
rtl/bus/spi_tx.sv
rtl/bus/gpio.sv