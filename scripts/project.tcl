set repo_root [file normalize [file join [file dirname [info script]] ..]]
cd $repo_root

set proj_name riscv_cpu
set proj_dir build/vivado

create_project $proj_name $proj_dir -part xc7a200tsbg484-1 -force
set_property target_language Verilog [current_project]

set rtl_files {}
set fh [open rtl/rtl.f r]
foreach line [split [read $fh] "\n"] {
    regsub {//.*$} $line "" line 
    set line [string trim $line]
    if {$line ne ""} {
        lappend rtl_files $line
    }
}
close $fh

add_files $rtl_files  
set_property include_dirs [list [file join $repo_root rtl/utils]] [current_fileset]

add_files fpga/boot_rom.mem

foreach ip {clk_gen axi_cdc axi_ahb_bridge ddr_mig_controller} {
    source ip/$ip.tcl
}
generate_target all [get_ips]

add_files -fileset constrs_1 {fpga/nexys_video.xdc fpga/timing.xdc fpga/implementation.xdc}
set_property USED_IN_SYNTHESIS false [get_files fpga/implementation.xdc]

set_property top top [current_fileset]
update_compile_order -fileset sources_1
