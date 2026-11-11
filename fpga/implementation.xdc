set_false_path -hold -to [get_pins -filter {REF_PIN_NAME == D} -of_objects \
    [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/device_temp_sync_r1_reg[*]}]]

create_waiver -type METHODOLOGY -id {SYNTH-10} -user Chris \
    -objects [get_cells -hier -filter {NAME =~ u_core/u_mdu/u_multiply/p*_q*}] \
    -description "32x32 partial products decomposed into DSP48s; expected"
create_waiver -type METHODOLOGY -id {LUTAR-1} -user Chris \
    -objects [get_cells -hier -filter {NAME =~ *u_ddr_mig_controller_mig/u_iodelay_ctrl/*}] \
    -description "MIG-internal reset combining logic"
create_waiver -type METHODOLOGY -id {REQP-1959} -user Chris \
    -objects [get_cells -hier -filter {NAME =~ *u_ddr_mig_controller_mig/*iserdes_dq_.iserdesdq}] \
    -description "MIG PHY ISERDES reset structure"
create_waiver -type METHODOLOGY -id {XDCB-5} -user Chris \
    -description "Inefficient query is in the generated MIG XDC"