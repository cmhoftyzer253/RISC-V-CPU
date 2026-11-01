##################################################################
# CHECK VIVADO VERSION
##################################################################

set scripts_vivado_version 2024.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  catch {common::send_msg_id "IPS_TCL-100" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_ip_tcl to create an updated script."}
  return 1
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source ddr_mig_controller.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project mem_test mem_test -part xc7a200tsbg484-1
  set_property BOARD_PART digilentinc.com:nexys_video:part0:1.2 [current_project]
  set_property target_language Verilog [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:mig_7series:4.2 }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP ddr_mig_controller
##################################################################

set ddr_mig_controller [create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.2 -module_name ddr_mig_controller]

# User Parameters
set_property -dict [list \
  CONFIG.ARESETN.INSERT_VIP {0} \
  CONFIG.BOARD_MIG_PARAM {Custom} \
  CONFIG.C0_ARESETN.INSERT_VIP {0} \
  CONFIG.C0_CLOCK.INSERT_VIP {0} \
  CONFIG.C0_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C0_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C0_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C0_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C0_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C0_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C0_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C0_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C0_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C0_RESET.INSERT_VIP {0} \
  CONFIG.C0_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C0_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C0_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.C1_ARESETN.INSERT_VIP {0} \
  CONFIG.C1_CLOCK.INSERT_VIP {0} \
  CONFIG.C1_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C1_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C1_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C1_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C1_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C1_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C1_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C1_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C1_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C1_RESET.INSERT_VIP {0} \
  CONFIG.C1_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C1_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C1_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.C2_ARESETN.INSERT_VIP {0} \
  CONFIG.C2_CLOCK.INSERT_VIP {0} \
  CONFIG.C2_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C2_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C2_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C2_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C2_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C2_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C2_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C2_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C2_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C2_RESET.INSERT_VIP {0} \
  CONFIG.C2_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C2_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C2_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.C3_ARESETN.INSERT_VIP {0} \
  CONFIG.C3_CLOCK.INSERT_VIP {0} \
  CONFIG.C3_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C3_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C3_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C3_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C3_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C3_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C3_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C3_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C3_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C3_RESET.INSERT_VIP {0} \
  CONFIG.C3_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C3_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C3_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.C4_ARESETN.INSERT_VIP {0} \
  CONFIG.C4_CLOCK.INSERT_VIP {0} \
  CONFIG.C4_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C4_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C4_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C4_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C4_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C4_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C4_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C4_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C4_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C4_RESET.INSERT_VIP {0} \
  CONFIG.C4_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C4_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C4_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.C5_ARESETN.INSERT_VIP {0} \
  CONFIG.C5_CLOCK.INSERT_VIP {0} \
  CONFIG.C5_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C5_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C5_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C5_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C5_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C5_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C5_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C5_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C5_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C5_RESET.INSERT_VIP {0} \
  CONFIG.C5_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C5_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C5_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.C6_ARESETN.INSERT_VIP {0} \
  CONFIG.C6_CLOCK.INSERT_VIP {0} \
  CONFIG.C6_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C6_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C6_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C6_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C6_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C6_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C6_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C6_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C6_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C6_RESET.INSERT_VIP {0} \
  CONFIG.C6_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C6_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C6_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.C7_ARESETN.INSERT_VIP {0} \
  CONFIG.C7_CLOCK.INSERT_VIP {0} \
  CONFIG.C7_DDR2_RESET.INSERT_VIP {0} \
  CONFIG.C7_DDR3_RESET.INSERT_VIP {0} \
  CONFIG.C7_LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.C7_MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.C7_MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.C7_MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.C7_MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.C7_MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.C7_QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.C7_RESET.INSERT_VIP {0} \
  CONFIG.C7_RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.C7_RLDII_RESET.INSERT_VIP {0} \
  CONFIG.C7_SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.CLK_REF_I.INSERT_VIP {0} \
  CONFIG.CLOCK.INSERT_VIP {0} \
  CONFIG.DDR2_RESET.INSERT_VIP {0} \
  CONFIG.DDR3_RESET.INSERT_VIP {0} \
  CONFIG.LPDDR2_RESET.INSERT_VIP {0} \
  CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
  CONFIG.MMCM_CLKOUT0.INSERT_VIP {0} \
  CONFIG.MMCM_CLKOUT1.INSERT_VIP {0} \
  CONFIG.MMCM_CLKOUT2.INSERT_VIP {0} \
  CONFIG.MMCM_CLKOUT3.INSERT_VIP {0} \
  CONFIG.MMCM_CLKOUT4.INSERT_VIP {0} \
  CONFIG.QDRIIP_RESET.INSERT_VIP {0} \
  CONFIG.RESET.INSERT_VIP {0} \
  CONFIG.RESET_BOARD_INTERFACE {Custom} \
  CONFIG.RLDIII_RESET.INSERT_VIP {0} \
  CONFIG.RLDII_RESET.INSERT_VIP {0} \
  CONFIG.S0_AXI.INSERT_VIP {0} \
  CONFIG.S0_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.S1_AXI.INSERT_VIP {0} \
  CONFIG.S1_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.S2_AXI.INSERT_VIP {0} \
  CONFIG.S2_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.S3_AXI.INSERT_VIP {0} \
  CONFIG.S3_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.S4_AXI.INSERT_VIP {0} \
  CONFIG.S4_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.S5_AXI.INSERT_VIP {0} \
  CONFIG.S5_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.S6_AXI.INSERT_VIP {0} \
  CONFIG.S6_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.S7_AXI.INSERT_VIP {0} \
  CONFIG.S7_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.SYSTEM_RESET.INSERT_VIP {0} \
  CONFIG.SYS_CLK_I.INSERT_VIP {0} \
  CONFIG.S_AXI.INSERT_VIP {0} \
  CONFIG.S_AXI_CTRL.INSERT_VIP {0} \
  CONFIG.XML_INPUT_FILE [file normalize ip/mig.prj] \
] [get_ips ddr_mig_controller]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $ddr_mig_controller

##################################################################

