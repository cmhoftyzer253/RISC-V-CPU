create_project riscv_cpu vivado_proj -part xc7a200tsbg484-1 -force
set_property target_language        Verilog [current_project]
set_property simulator_language     Verilog [current_project]

# RTL sources
add_files rtl/constants/cpu_consts.sv
add_files rtl/constants/cpu_utils.sv

add_files rtl/core/core.sv

add_files rtl/decode/control.sv
add_files rtl/decode/csr.sv
add_files rtl/decode/decode.sv
add_files rtl/decode/register_file.sv

add_files rtl/execute/alu.sv
add_files rtl/execute/branch_control.sv
add_files rtl/execute/divide.sv
add_files rtl/execute/multiply.sv

add_files rtl/fetch/fetch.sv
add_files rtl/fetch/i_cache.sv

add_files rtl/mem/clint.sv
add_files rtl/mem/d_cache.sv
add_files rtl/mem/memory.sv
add_files rtl/mem/plic.sv
add_files rtl/mem/trap_controller.sv

add_files rtl/top.sv   

set_property top core [current_fileset]
update_compile_order -fileset [current_fileset]